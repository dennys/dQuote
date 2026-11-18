import 'package:flutter/foundation.dart';

import '../core/clock.dart';
import '../core/models.dart';
import '../core/symbol.dart';
import '../data/repositories/quote_repository.dart';

/// 匯率表。所有「外幣 → 基礎貨幣」的換算都問這裡，**沒有匯率就回 null，不硬猜**。
///
/// 匯率本身就是一档「商品」（`fxSymbol('USD')` → `USDTWD=X`），所以不另開資料源、不另開表，
/// 直接用 [QuoteRepository] 的報價快取 —— 少一套機制，還自動獲得「離線也看得到最後匯率」。
///
/// 是 [ChangeNotifier]：匯率常常比頁面慢到（開機沒網、後來才有），不是 ChangeNotifier 的話
/// UI 就永遠停在「—」，要等其他東西變動才重畫（`core/app_format.dart` 靠這個 select）。
class FxService extends ChangeNotifier {
  FxService(this._quotes,
      {this.baseCcy = 'TWD', this.clock = nowUtc, this.ttl = const Duration(minutes: 5)});

  final QuoteRepository _quotes;
  final String baseCcy;

  /// 匯率的保存年限。**只靠「記憶體裡有沒有」判斷會錯**：一個幣別抓過一次就永遠不重抓，
  /// 長時間開著的 app 會用早上的匯率算傍晚的總資產。跟 K 線一樣走 TTL。
  final Duration ttl;
  final Clock clock;
  final _rates = <String, double>{};
  final _fetchedAt = <String, DateTime>{};
  Map<String, double> _snapshot = const {};

  /// 給 UI `context.select` 用的**穩定快照**：內容沒變就回同一個實例。
  /// 直接回 `_rates` 的 `Map.unmodifiable` 每次都是新物件，select 會一直判定「變了」→ 無限重建。
  Map<String, double> get snapshot => _snapshot;

  void _set(String ccy, double rate) {
    if (_rates[ccy] == rate) return;
    _rates[ccy] = rate;
    _snapshot = Map.unmodifiable(Map.of(_rates));
    notifyListeners();
  }

  bool _isBase(String ccy) => ccy.toUpperCase() == baseCcy.toUpperCase();

  /// 每 1 個 [ccy] = ? [baseCcy]。本幣回 1；不知道回 null。
  double? rateOf(String ccy) => _isBase(ccy) ? 1 : _rates[ccy.toUpperCase()];

  Map<String, double> get rates => Map.unmodifiable(_rates);

  String symbolOf(String ccy) => fxSymbol(ccy, baseCcy).yahooSymbol;

  /// 在用的幣別對應到哪些匯率 symbol（心跳抓報價時要一併抓進去）。
  Set<String> symbolsFor(Iterable<String> ccys) =>
      {for (final c in ccys) if (!_isBase(c)) symbolOf(c)};

  /// 確保這些幣別的匯率有值；缺的或過期的去抓。抓失敗不丟出來 —— 讀不到就保持 null，
  /// 由 UI 顯示 `—`，不讓一個匯率拖垮整個載入流程。
  /// [force]（使用者按重新整理）不管過期與否都重抓。
  Future<void> ensureRates(Iterable<String> ccys, {bool force = false}) async {
    final wanted = {for (final c in ccys) c.toUpperCase()}..removeWhere(_isBase);
    if (wanted.isEmpty) return;

    final now = clock();
    final symbols = {for (final c in wanted) symbolOf(c)};
    final stale = wanted.any((c) =>
        _rates[c] == null || now.difference(_fetchedAt[c] ?? DateTime(0)) > ttl);
    if (stale || force) {
      try {
        final batch = await _quotes.refresh(symbols);
        // 只標「真的有回報」的幣別。整批失敗（斷網、被擋）也標成剛抓過的話，TTL 內不會重試 ——
        // 網路恢復之後總資產還要继续用舊匯率（或顯示 —）撐完這 5 分鐘。
        final got = {for (final s in batch.quotes.keys) _ccyOf(s)}.whereType<String>().toSet();
        for (final c in wanted) {
          if (got.contains(c)) _fetchedAt[c] = now;
        }
      } on Object {
        // 網路壞掉時還是讀得到快取，繼續往下
      }
    }
    final cached = await _quotes.cached(symbols);
    for (final e in cached.entries) {
      final ccy = _ccyOf(e.key);
      if (ccy != null) _set(ccy, e.value.price);
    }
  }

  /// 心跳抓完一批報價後直接吸收，省一次讀庫。
  void absorb(Map<String, Quote> quotes) {
    final now = clock();
    for (final e in quotes.entries) {
      final ccy = _ccyOf(e.key);
      if (ccy != null) {
        _fetchedAt[ccy] = now; // 剛從線上批次來的，當場就是新的
        _set(ccy, e.value.price);
      }
    }
  }

  static String? _ccyOf(String symbol) {
    if (!symbol.endsWith('=X')) return null;
    final body = symbol.substring(0, symbol.length - 2);
    return body.length == 6 ? body.substring(0, 3) : null;
  }
}
