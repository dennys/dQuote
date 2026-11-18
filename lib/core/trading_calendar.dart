/// 交易時段判斷。**純函式**，所以在 test/ 裡可完全決定。
///
/// ## 時區設計（重要，改這支之前先讀）
/// 1. 所有判斷一律從**絕對時刻**出發：台北時間用 `UTC+8`（台澎金馬無夏令）自己推，美東時間
///    用下面的 DST 規則自己推 → **判斷結果與裝置時區無關**，使用者到國外旅遊也不會誤判
///    開盤/收盤。
/// 2. Dart 的 `DateTime.now()` 回的是「本地」DateTime，它的 `hour` 是裝置牆鐘。把
///    `DateTime.now()` 直接傳進來就會差 8 小時 —— 這種錯不會報錯，只會「通知怪怪的」。
///    所以每個入口都先過 [_u] 正規化：傳 UTC 進來是恒等變換，傳 local 進來會被正確換算，
///    兩種呼叫方式都安全。
/// 3. 要顯示「幾點了」給使用者看時，一律 `.toLocal()`（裝置時區）；這裡 `tst()`／`et()`
///    回傳的牆鐘時間只拿來比較數字，不要直接拿去顯示。
/// 4. Yahoo 回的 `marketTime` 與 K 線 `timestamp` 是 epoch seconds（絕對時刻）→ 存 int、
///    顯示時 `.toLocal()`。日 K 的時間戳是「開盤時刻」，台/美股換算到台北都落在同一個
///    日曆日，所以 x 軸用本地日期標籤不會錯日（美國冬令時 09:30 EST = 台北 22:30，仍是当天）。
///
/// 美國 DST 自己算（一年兩次規則固定），不為這個拉 `timezone` 套件。
///
/// shortcut: 只排除週末，未處理台股固定例假日／美股休市／半日市；錯的後果只是「多發一次
///           日報」或「少發一次」，不會損壞資料。之後要做再補行事曆表。
class TradingCalendar {
  const TradingCalendar();

  static const tstOffset = Duration(hours: 8); // Asia/Taipei 固定 UTC+8，無夏令

  /// 入口正規化：容許呼叫端傳 local 或 UTC 進來（見「時區設計」第 2 點）。
  static DateTime _u(DateTime t) => t.isUtc ? t : t.toUtc();

  /// 絕對時刻 → 台北牆鐘時間（回傳 UTC DateTime，但其欄位就是台北的時間讀值）。
  DateTime tst(DateTime now) => _u(now).add(tstOffset);

  /// 絕對時刻 → 美東牆鐘時間（含夏令時間）。
  DateTime et(DateTime now) =>
      _u(now).add(isUsDst(now) ? const Duration(hours: -4) : const Duration(hours: -5));

  /// 美國夏令時間：3 月第二個周日 02:00 EST（=07:00Z）起，11 月第一個周日 02:00 EDT（=06:00Z）止。
  bool isUsDst(DateTime now) {
    final t = _u(now);
    final y = t.year;
    final start = DateTime.utc(y, 3, _nthWeekday(y, 3, DateTime.sunday, 2), 7);
    final end = DateTime.utc(y, 11, _nthWeekday(y, 11, DateTime.sunday, 1), 6);
    return !t.isBefore(start) && t.isBefore(end);
  }

  /// 該年該月的第 n 個星期幾（1 起算）。
  static int _nthWeekday(int year, int month, int weekday, int n) {
    final first = DateTime.utc(year, month).weekday; // 1=Mon..7=Sun
    return 1 + ((weekday - first + 7) % 7) + (n - 1) * 7;
  }

  bool _isWeekday(DateTime wall) => wall.weekday <= DateTime.friday;

  int _minutes(DateTime wall) => wall.hour * 60 + wall.minute;

  /// 台股盤中 09:00–13:30（台時）。盤前 08:30–09:00 不算。
  bool twOpenAt(DateTime now) {
    final t = tst(now);
    if (!_isWeekday(t)) return false;
    final m = _minutes(t);
    return m >= 9 * 60 && m < 13 * 60 + 30;
  }

  /// 美股盤中 09:30–16:00 美東。
  bool usOpenAt(DateTime now) {
    final e = et(now);
    if (!_isWeekday(e)) return false;
    final m = _minutes(e);
    return m >= 9 * 60 + 30 && m < 16 * 60;
  }

  /// 任一市場開盤（決定這一次 heartbeat 值不值得去抓報價）。
  /// 加密貨幣 24/7，不受時段限制，由呼叫端另判。
  bool anyMarketOpenAt(DateTime now) => twOpenAt(now) || usOpenAt(now);

  /// 台股收盤日報：收盤後 13:35 起、限同一個交易日內發（被 Doze 延後也能補發）。
  /// 回傳去重用的 key（`TW-2026-11-20`），不可發時回 null。
  String? twDigestKey(DateTime now) {
    final t = tst(now);
    if (!_isWeekday(t)) return null;
    if (_minutes(t) < 13 * 60 + 35) return null;
    // 上限 22:00（2026-11-21 拍板）：被 Doze 延後到很晚才補上的話，那時候發一條「今日收盤」
    // 看起來像壞掉，而且是在使用者早就不看手機的時段轟人。代價是那天就漏掉那份日報 ——
    // 收盤價本身在自選股與個股頁都還看得到，只是不主動推。
    // （美報那側的窗是 05:00–12:00，因為它的收盤落在台北凌晨。）
    if (_minutes(t) >= 22 * 60) return null;
    return 'TW-${_date(t)}';
  }

  /// 美股收盤日報：收盤後、且落在台北 05:00–12:00（不要在半夜打擾使用者）。
  /// key 用 **ET 交易日**，所以夏/冬令時間（台北 04:00／05:00 收盤）都只会發一次。
  String? usDigestKey(DateTime now) {
    final e = et(now);
    if (!_isWeekday(e)) return null;
    if (_minutes(e) < 16 * 60 + 5) return null;
    final t = tst(now);
    if (t.hour < 5 || t.hour >= 12) return null;
    return 'US-${_date(e)}';
  }

  static String _date(DateTime w) =>
      '${w.year.toString().padLeft(4, '0')}-${w.month.toString().padLeft(2, '0')}-${w.day.toString().padLeft(2, '0')}';
}
