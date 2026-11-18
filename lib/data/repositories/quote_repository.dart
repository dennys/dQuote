import 'package:drift/drift.dart';

import '../../core/models.dart';
import '../datasources/yahoo_datasource.dart';
import '../db/database.dart' hide Candle; // Candle 在 core/models.dart 才是我們用的形狀

/// 報價的讀寫口。**永遠先給快取、再補網路**，這樣：
/// * 開機不會白畫面（先顯示最後-known 的數字 + 「更新於 HH:mm」）
/// * 資料源壞掉時 UI 還有東西可顯示（這是規畫時就承諾的行為，不是事後補的）
class QuoteRepository {
  QuoteRepository(this._db, this._source);

  final AppDatabase _db;
  final QuoteDataSource _source;

  /// 抓一批報價並落庫。單檔失敗不讓整批失敗 —— 回傳成功的部分，失敗的代號丟進
  /// [QuoteBatch.failed] 讓 UI 標示（不要整頁空白）。
  Future<QuoteBatch> refresh(Iterable<String> symbols) async {
    final wanted = symbols.toSet();
    if (wanted.isEmpty) return const QuoteBatch({}, {});

    final results = await Future.wait(<Future<(String, Quote?, Object?)>>[
      for (final s in wanted)
        _source
            .quote(s)
            .then<(String, Quote?, Object?)>((q) => (s, q, null))
            .catchError((Object e) => (s, null, e)),
    ]);

    final ok = <String, Quote>{};
    final failed = <String, Object>{};
    await _db.batch((b) {
      for (final (symbol, quote, error) in results) {
        if (quote == null) {
          failed[symbol] = error!;
          continue;
        }
        ok[symbol] = quote;
        putQuote(b, quote);
      }
    });
    return QuoteBatch(ok, failed);
  }

  /// 一列報價進快取（insert-or-update）。給 [refresh] 與 [history] 共用 —— 兩條路拿到的
  /// 都是同一個 `Quote` 形狀，寫法不該分兩份。
  void putQuote(Batch b, Quote quote, {DateTime? at}) {
    final row = QuoteCacheCompanion.insert(
      symbol: quote.symbol,
      price: quote.price,
      previousClose: Value(quote.previousClose),
      marketTime: Value(quote.marketTime),
      volume: Value(quote.volume),
      name: Value(quote.name),
      currency: Value(quote.currency),
      market: Value(quote.market.name),
      updatedAt: at ?? DateTime.now(),
    );
    b.insert(_db.quoteCache, row, onConflict: DoUpdate((_) => row));
  }

  /// 只讀快取（不打網路）：開機、widget 重建、離線時用。
  Future<Map<String, Quote>> cached([Iterable<String>? symbols]) async {
    final q = _db.select(_db.quoteCache);
    if (symbols != null) q.where((t) => t.symbol.isIn(symbols.toSet()));
    return {for (final row in await q.get()) row.symbol: _fromRow(row)};
  }

  /// 快取變動就推一份新的。**直接用 stream 給的行**，不要再 `.map((_) => cached(...))`
  /// 回爐查一次 —— 那樣每個事件都打兩次查詢（心跳寫一次庫就是 2N 次）。
  Stream<Map<String, Quote>> watchCached([Iterable<String>? symbols]) {
    final q = _db.select(_db.quoteCache);
    final wanted = symbols?.toSet();
    if (wanted != null) q.where((t) => t.symbol.isIn(wanted));
    return q.watch().map((rows) => {for (final row in rows) row.symbol: _fromRow(row)});
  }

  static Quote _fromRow(QuoteCacheData row) => Quote(
        symbol: row.symbol,
        name: row.name,
        currency: row.currency,
        market: Market.values.firstWhere((e) => e.name == row.market, orElse: () => Market.america),
        price: row.price,
        previousClose: row.previousClose,
        marketTime: row.marketTime,
        volume: row.volume,
      );

  /// 一批抓完後的最新更新時間（顯示「更新於」）。沒有任何快取 → null。
  Future<DateTime?> lastUpdated() async {
    final rows = await _db.select(_db.quoteCache).get();
    if (rows.isEmpty) return null;
    return rows.map((r) => r.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// 走勢：**快取優先**，過期才抓網路。
  /// 過期門檻按區間分：日內 5 分鐘就該重抓，長期線 6 小時才抓一次（省 request 也省電）。
  Future<List<Candle>> history(String symbol, QuoteRange range, {bool force = false}) async {
    final key = '${range.range}/${range.interval}';
    final cached = await (_db.select(_db.candles)
          ..where((t) => t.symbol.equals(symbol) & t.rangeKey.equals(key))
          ..orderBy([(t) => OrderingTerm.asc(t.time)]))
        .get();

    List<Candle> fromCache() => [
          for (final c in cached)
            Candle(time: c.time, open: c.open, high: c.high, low: c.low, close: c.close, volume: c.volume),
        ];

    if (!force && cached.isNotEmpty && !_stale(cached.first.fetchedAt, range)) {
      return fromCache();
    }

    final CandleSeries fetched;
    try {
      fetched = await _source.candles(symbol, range);
    } on Object {
      // 過期 + 網路壞掉 → 還是給最後抓到的圖（README 承諾「資料源壞掉時 UI 還有東西可顯示」，
      // 不該把一張畫得出來的圖換成錯誤頁）。從來沒抓過才把錯誤丟給 UI。
      if (cached.isEmpty) rethrow;
      return fromCache();
    }
    final now = DateTime.now();
    // 先清同 symbol+range 的舊資料，免得圖裡混進不同 interval 的點
    await (_db.delete(_db.candles)
          ..where((t) => t.symbol.equals(symbol) & t.rangeKey.equals(key)))
        .go();
    await _db.batch((b) {
      // 走勢批次本來就附了一張最新報價（`CandleSeries.quote`）。以前直接丟掉，個股頁頂部那個
      // 大數字就還讀著舊快取 —— 下拉更新後「圖是新的、價格是舊的」，而對不在自選股裡的代號
      // （從提醒通知點進來的那種）會一路舊到下次心跳。同一批資料已在手上，寫起來是免費的。
      putQuote(b, fetched.quote, at: now);
      for (final c in fetched.candles) {
        b.insert(
          _db.candles,
          CandlesCompanion.insert(
            symbol: symbol,
            rangeKey: key,
            time: c.time,
            open: c.open,
            high: c.high,
            low: c.low,
            close: c.close,
            volume: Value(c.volume),
            fetchedAt: now,
          ),
          onConflict: DoUpdate((_) => CandlesCompanion.insert(
                symbol: symbol,
                rangeKey: key,
                time: c.time,
                open: c.open,
                high: c.high,
                low: c.low,
                close: c.close,
                volume: Value(c.volume),
                fetchedAt: now,
              )),
        );
      }
    });
    return fetched.candles;
  }

  bool _stale(DateTime fetchedAt, QuoteRange range) {
    final ttl = switch (range) {
      QuoteRange.d1 || QuoteRange.d5 => const Duration(minutes: 5),
      _ => const Duration(hours: 6),
    };
    return DateTime.now().difference(fetchedAt) > ttl;
  }
}

class QuoteBatch {
  const QuoteBatch(this.quotes, this.failed);
  final Map<String, Quote> quotes;
  final Map<String, Object> failed;
  bool get hasFailures => failed.isNotEmpty;
}
