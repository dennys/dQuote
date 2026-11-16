import 'package:dquote/core/trading_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

/// 時區/DST 的回歸測試。
///
/// 這支測試的存在理由：時間判斷錯時**不會報錯**，只會「通知怪怪的」，是最難查的一類 bug。
void main() {
  const cal = TradingCalendar();

  group('DST 邊界（2026：3/8 進入、11/1 離開）', () {
    test('2026-03-08 07:00Z 是 switching moment', () {
      expect(cal.isUsDst(DateTime.utc(2026, 3, 8, 6, 59)), isFalse);
      expect(cal.isUsDst(DateTime.utc(2026, 3, 8, 7, 0)), isTrue);
    });

    test('2026-11-01 06:00Z 離開 DST', () {
      expect(cal.isUsDst(DateTime.utc(2026, 11, 1, 5, 59)), isTrue);
      expect(cal.isUsDst(DateTime.utc(2026, 11, 1, 6, 0)), isFalse);
    });

    test('1 月與 12 月都不在 DST（跨年邊界誤判的防呆）', () {
      expect(cal.isUsDst(DateTime.utc(2026, 1, 15)), isFalse);
      expect(cal.isUsDst(DateTime.utc(2026, 12, 15)), isFalse);
    });
  });

  group('台股盤中 09:00–13:30 台時', () {
    // 2026-11-20 是星期五
    test('08:59 未開 / 09:00 開 / 13:29 開 / 13:30 收', () {
      expect(cal.twOpenAt(DateTime.utc(2026, 11, 20, 0, 59)), isFalse);
      expect(cal.twOpenAt(DateTime.utc(2026, 11, 20, 1, 0)), isTrue);
      expect(cal.twOpenAt(DateTime.utc(2026, 11, 20, 5, 29)), isTrue);
      expect(cal.twOpenAt(DateTime.utc(2026, 11, 20, 5, 30)), isFalse);
    });

    test('週末不開盤', () {
      expect(cal.twOpenAt(DateTime.utc(2026, 11, 21, 2, 0)), isFalse); // 週六
      expect(cal.twOpenAt(DateTime.utc(2026, 11, 22, 2, 0)), isFalse); // 週日
    });

    /// 這是最容易寫錯的一類：把 `DateTime.now()`（local）傳進來。
    /// 只有在「主機的時區不是 UTC」時這條才有鑑別力；本開發機是 UTC+8，所以有效。
    test('傳 local DateTime 進來不會差 8 小時', () {
      final utc = DateTime.utc(2026, 11, 20, 1, 0); // 台北 09:00，開盤中
      expect(utc.toLocal().isUtc, isFalse, reason: '確認這台主機不是 UTC，測試才有意義');
      expect(cal.twOpenAt(utc.toLocal()), isTrue);
      expect(cal.tst(utc.toLocal()).hour, 9);
    });
  });

  group('美股盤中 09:30–16:00 美東（含 DST 換算）', () {
    test('夏令：開盤 13:30Z、收盤 20:00Z', () {
      expect(cal.usOpenAt(DateTime.utc(2026, 8, 5, 13, 29)), isFalse); // 週三 09:29 EDT
      expect(cal.usOpenAt(DateTime.utc(2026, 8, 5, 13, 30)), isTrue);
      expect(cal.usOpenAt(DateTime.utc(2026, 8, 5, 19, 59)), isTrue);
      expect(cal.usOpenAt(DateTime.utc(2026, 8, 5, 20, 0)), isFalse);
    });

    test('冬令：開盤 14:30Z、收盤 21:00Z', () {
      expect(cal.usOpenAt(DateTime.utc(2026, 12, 2, 14, 29)), isFalse); // 週三 09:29 EST
      expect(cal.usOpenAt(DateTime.utc(2026, 12, 2, 14, 30)), isTrue);
      expect(cal.usOpenAt(DateTime.utc(2026, 12, 2, 20, 59)), isTrue);
      expect(cal.usOpenAt(DateTime.utc(2026, 12, 2, 21, 0)), isFalse);
    });
  });

  group('收盤日報的時窗與去重 key', () {
    test('台報：13:34 不發、13:35 起發，key 帶交易日', () {
      expect(cal.twDigestKey(DateTime.utc(2026, 11, 20, 5, 34)), isNull);
      expect(cal.twDigestKey(DateTime.utc(2026, 11, 20, 5, 35)), 'TW-2026-11-20');
      expect(cal.twDigestKey(DateTime.utc(2026, 11, 20, 15, 0)), 'TW-2026-11-20',
          reason: '被 Doze 延後到晚上仍能補發');
      expect(cal.twDigestKey(DateTime.utc(2026, 11, 21, 5, 40)), isNull, reason: '週六');
    });

    test('美報：收盤後立刻還是不發（台北 04–05 點，不要吵人），05:00 後才發', () {
      // 夏令收盤 20:00Z
      expect(cal.usDigestKey(DateTime.utc(2026, 8, 5, 20, 6)), isNull, reason: '台北 04:06');
      expect(cal.usDigestKey(DateTime.utc(2026, 8, 5, 21, 30)), 'US-2026-08-05',
          reason: '台北 05:30');
      // 冬令收盤 21:00Z
      expect(cal.usDigestKey(DateTime.utc(2026, 12, 2, 21, 10)), 'US-2026-12-02');
      expect(cal.usDigestKey(DateTime.utc(2026, 12, 2, 4, 0)), isNull, reason: '台北 12:00 以後不補發');
    });

    test('美股星期五的日報落在台北星期六，key 仍是星期五的 ET 交易日', () {
      expect(cal.usDigestKey(DateTime.utc(2026, 11, 20, 21, 30)), 'US-2026-11-20');
      expect(cal.tst(DateTime.utc(2026, 11, 20, 21, 30)).weekday, DateTime.saturday);
    });

    test('同一個交易日內重複問都給同一個 key（心跳重复跑不會重發）', () {
      final a = cal.usDigestKey(DateTime.utc(2026, 8, 5, 21, 30));
      final b = cal.usDigestKey(DateTime.utc(2026, 8, 5, 23, 59));
      expect(a, b);
    });
  });
}
