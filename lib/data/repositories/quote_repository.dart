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
    final now = DateTime.now();
    await _db.batch((b) {
      for (final (symbol, quote, error) in results) {
        if (quote == null) {
          failed[symbol] = error!;
          continue;
        }
        ok[symbol] = quote;
        b.insert(
          _db.quoteCache,
          QuoteCacheCompanion.insert(
            symbol: symbol,
            price: quote.price,
            previousClose: Value(quote.previousClose),
            marketTime: Value(quote.marketTime),
            volume: Value(quote.volume),
            name: Value(quote.name),
            currency: Value(quote.currency),
            market: Value(quote.market.name),
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (old) => QuoteCacheCompanion.insert(
              symbol: symbol,
              price: quote.price,
              previousClose: Value(quote.previousClose),
              marketTime: Value(quote.marketTime),
              volume: Value(quote.volume),
              name: Value(quote.name),
              currency: Value(quote.currency),
              market: Value(quote.market.name),
              updatedAt: now,
            ),
          ),
        );
      }
    });
    return QuoteBatch(ok, failed);
  }

  /// 只讀快取（不打網路）：開機、widget 重建、離線時用。
  Future<Map<String, Quote>> cached([Iterable<String>? symbols]) async {
    final q = _db.select(_db.quoteCache);
    final list = symbols == null ? await q.get() : await (q..where((t) => t.symbol.isIn(symbols.toSet()))).get();
    return {
      for (final row in list)
        row.symbol: Quote(
          symbol: row.symbol,
          name: row.name,
          currency: row.currency,
          market: Market.values.firstWhere((e) => e.name == row.market, orElse: () => Market.america),
          price: row.price,
          previousClose: row.previousClose,
          marketTime: row.marketTime,
          volume: row.volume,
        ),
    };
  }

  Stream<Map<String, Quote>> watchCached([Iterable<String>? symbols]) =>
      _db.select(_db.quoteCache).watch().map((_) => cached(symbols)).asyncMap((f) => f);

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

    final List<Candle> series;
    try {
      series = (await _source.candles(symbol, range)).candles;
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
      for (final c in series) {
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
    return series;
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
