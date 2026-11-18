import 'package:dquote/core/models.dart';
import 'package:dquote/data/db/database.dart';
import 'package:dquote/data/repositories/quote_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late AppDatabase db;
  late FakeQuoteSource source;
  late QuoteRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    source = FakeQuoteSource({
      '2330.TW': quoteOf('2330.TW', 2415, prev: 2400),
      'TSM': quoteOf('TSM', 400, prev: 390, ccy: 'USD', market: Market.america),
    });
    repo = QuoteRepository(db, source);
  });

  tearDown(() async => db.close());

  group('refresh', () {
    test('抓到的報價會落庫，可從快取讀回（開機先顯示上次數字的基礎）', () async {
      final batch = await repo.refresh(['2330.TW', 'TSM']);
      expect(batch.quotes.keys, containsAll(<String>['2330.TW', 'TSM']));

      final cached = await repo.cached();
      expect(cached['2330.TW']!.price, 2415);
      expect(cached['TSM']!.currency, 'USD');
      expect(await repo.lastUpdated(), isNotNull);
    });

    test('查無的代號回報在 failed，**不影響其他档**', () async {
      final batch = await repo.refresh(['2330.TW', 'BOGUS']);
      expect(batch.quotes.keys, ['2330.TW']);
      expect(batch.failed.keys, ['BOGUS']);
      expect(batch.hasFailures, isTrue);
      expect((await repo.cached()).keys, ['2330.TW']);
    });

    test('漲跌是自己用 previousClose 算的（Yahoo 不提供 regularMarketChange）', () async {
      final batch = await repo.refresh(['2330.TW']);
      final q = batch.quotes['2330.TW']!;
      expect(q.change, closeTo(15, 1e-9));
      expect(q.changePct, closeTo(0.625, 1e-9));
      expect(q.isUp, isTrue);
    });

    test('沒有 previousClose 時漲跌為 null，不會當成 0（誤導成「沒漲跌」）', () async {
      source.quotes['X'] = const Quote(
          symbol: 'X', name: 'x', currency: 'TWD', market: Market.taiwan, price: 10, previousClose: null, marketTime: 1);
      final q = (await repo.refresh(['X'])).quotes['X']!;
      expect(q.change, isNull);
      expect(q.changePct, isNull);
      expect(q.isUp, isFalse);
    });

    test('空清單不打網路', () async {
      await repo.refresh([]);
      expect(source.requested, isEmpty);
    });
  });

  group('走勢快取', () {
    test('第一次抓、第二次讀快取（不打網路，省 request 也省電）', () async {
      final first = await repo.history('2330.TW', QuoteRange.m1);
      expect(first.length, 20);
      expect(source.requested.where((s) => s == '2330.TW'), hasLength(1));

      final second = await repo.history('2330.TW', QuoteRange.m1);
      expect(second.length, 20);
      expect(source.requested.where((s) => s == '2330.TW'), hasLength(1), reason: '第二次不該再打網路');
    });

    test('force = true 一定重抓（下拉更新要用）', () async {
      await repo.history('2330.TW', QuoteRange.m1);
      await repo.history('2330.TW', QuoteRange.m1, force: true);
      expect(source.requested.where((s) => s == '2330.TW'), hasLength(2));
    });

    test('不同區間各自快取，不會混在一起', () async {
      await repo.history('2330.TW', QuoteRange.d1);
      await repo.history('2330.TW', QuoteRange.y5);
      final rows = await db.select(db.candles).get();
      expect(rows.map((r) => r.rangeKey).toSet(), {'1d/5m', '5y/1wk'});
    });

    test('走勢依時間順序回傳（圖表依賴順序，亂序會畫出鋸齒）', () async {
      final candles = await repo.history('2330.TW', QuoteRange.m1);
      final times = candles.map((c) => c.time).toList();
      final sorted = [...times]..sort();
      expect(times, sorted);
    });

    test('快取過期但網路壞掉 → 還是給最後抓到的圖（不換成錯誤頁）', () async {
      await repo.history('2330.TW', QuoteRange.d1);
      source.failing.add('2330.TW');
      final again = await repo.history('2330.TW', QuoteRange.d1, force: true);
      expect(again, hasLength(20),
          reason: 'README 承諾資料源壞掉時 UI 還有東西可顯示，不能把畫得出來的圖換掉');
    });

    test('從來沒抓過又沒網路 → 照樣把錯誤丟給 UI（不裝成「無資料」）', () async {
      source.failing.add('TSM');
      expect(() => repo.history('TSM', QuoteRange.d1), throwsA(anything));
    });
  });

  group('走勢與快取的互動', () {
    test('history() 要把走勢批次附帶的最新報價寫進快取', () async {
      // 只打過 candles、從不打 quote：快取裡還是必須出現這档，否則個股頁會出現
      // 「圖是新的、頂部價格是舊的」（不在自選股裡的代號最明顯 —— 前景輪詢不會抓它）。
      await repo.history('TSM', QuoteRange.d5, force: true);
      final cached = await repo.cached(['TSM']);
      expect(cached['TSM'], isNotNull, reason: '走勢批次本來就附了報價，丟掉就是白丟');
      expect(cached['TSM']!.price, 400);
      expect(cached['TSM']!.previousClose, 390, reason: '前收盤也要一起寫，漲跌才算得出來');
    });

    test('watchCached(符號清單) 只推那些符號（改成直接用 stream 的行之後行為不變）', () async {
      await repo.refresh(['2330.TW', 'TSM']);
      final map = await repo.watchCached(['2330.TW']).first;
      expect(map.keys, ['2330.TW']);
      expect(map['2330.TW']!.price, 2415);
    });
  });
}