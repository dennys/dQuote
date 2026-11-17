import 'package:dquote/core/models.dart';
import 'package:dquote/data/db/database.dart';
import 'package:dquote/data/repositories/instrument_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// 自選股的兩條容易悄悄壞掉的路：**市場歸屬（seed 的 market 字串要合法）**與**手動排序**。
void main() {
  test('seed 寫進去的 market 必須是合法的 Market 名字（打錯字 → 那档會被當成未知市場）', () async {
    final db = AppDatabase.memory();
    await db.seedIfEmpty();
    final rows = await db.select(db.instruments).get();
    expect(rows, isNotEmpty);
    final legal = Market.values.map((e) => e.name).toSet();
    for (final r in rows) {
      expect(legal, contains(r.market), reason: '${r.symbol} 的 market="${r.market}" 不是 Market 的名字');
    }
    await db.close();
  });

  group('拖曳排序', () {
    late AppDatabase db;
    late InstrumentRepository repo;

    setUp(() async {
      db = AppDatabase.memory();
      repo = InstrumentRepository(db);
      for (final (i, s) in ['2330.TW', '0050.TW', '2317.TW'].indexed) {
        await repo.add(
            symbol: s, name: 'n$i', currency: 'TWD', market: Market.taiwan);
      }
    });

    tearDown(() async => db.close());

    test('reorder 之後 watchAll 的順序照新的排', () async {
      expect((await repo.all()).map((e) => e.symbol), ['2330.TW', '0050.TW', '2317.TW']);

      await repo.reorder(['2317.TW', '2330.TW', '0050.TW']);

      expect((await repo.all()).map((e) => e.symbol), ['2317.TW', '2330.TW', '0050.TW']);
    });

    test('sortOrder 一律重排成 0..n-1（不跳號，跨分頁也不會互相插隊）', () async {
      await repo.reorder(['0050.TW', '2317.TW', '2330.TW']);
      final rows = await repo.all();
      expect(rows.map((e) => e.sortOrder), [0, 1, 2]);
    });

    test('只排清單上的代號，不會動到別人', () async {
      await repo.add(symbol: 'TSM', name: 'TSMC ADR', currency: 'USD', market: Market.america);
      await repo.reorder(['0050.TW', '2330.TW', '2317.TW']);
      expect((await repo.all()).map((e) => e.sortOrder), [0, 1, 2, 1000],
          reason: 'TSM 不在重排清單裡，sortOrder 不該被動到');
    });
  });
}
