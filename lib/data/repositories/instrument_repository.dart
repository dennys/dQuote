import 'package:drift/drift.dart';

import '../../core/models.dart';
import '../db/database.dart';

/// 自選股清單。清單本身走 drift 的 `watch()` Stream，
/// 所以 UI 不需要 ChangeNotifier 也不會出現「增删後忘記刷新」。
class InstrumentRepository {
  InstrumentRepository(this._db);
  final AppDatabase _db;

  Stream<List<Instrument>> watchAll() =>
      (_db.select(_db.instruments)..orderBy(_ordering)).watch();

  Future<List<Instrument>> all() =>
      (_db.select(_db.instruments)..orderBy(_ordering)).get();

  /// 桌面小工具要顯示的那幾档（`in_widget` + 排序 + 上限）
  Future<List<Instrument>> forWidget({int limit = 6}) async {
    final q = _db.select(_db.instruments)
      ..where((t) => t.inWidget.equals(true))
      ..orderBy(_ordering)
      ..limit(limit);
    return q.get();
  }

  Future<Instrument?> find(String symbol) =>
      (_db.select(_db.instruments)..where((t) => t.symbol.equals(symbol))).getSingleOrNull();

  Future<void> add({
    required String symbol,
    required String name,
    required String currency,
    required Market market,
    bool inWidget = false,
  }) {
    return _db.into(_db.instruments).insertOnConflictUpdate(InstrumentsCompanion.insert(
          symbol: symbol,
          name: Value(name),
          currency: Value(currency),
          market: Value(market.name),
          sortOrder: const Value(_nextSortOrder),
          addedAt: Value(DateTime.now()),
          inWidget: Value(inWidget),
        ));
  }

  /// 拖曳排序。一律重排成 `0..n-1`，不在舊值上疊加 —— 免得多次操作後順序跳號、
  /// 也免得不同分頁之間互相插隊（傳進來的就是這個分頁的完整順序）。
  Future<void> reorder(List<String> symbols) => _db.transaction(() async {
        for (var i = 0; i < symbols.length; i++) {
          await (_db.update(_db.instruments)..where((t) => t.symbol.equals(symbols[i])))
              .write(InstrumentsCompanion(sortOrder: Value(i)));
        }
      });

  /// 名稱由來源給（Yahoo 沒中文名，部分台股只給 longName），使用者可覆寫成自己看得懂的。
  Future<void> setAlias(String symbol, String? alias) =>
      (_db.update(_db.instruments)..where((t) => t.symbol.equals(symbol)))
          .write(InstrumentsCompanion(alias: Value(alias)));

  Future<void> setInWidget(String symbol, bool value) =>
      (_db.update(_db.instruments)..where((t) => t.symbol.equals(symbol)))
          .write(InstrumentsCompanion(inWidget: Value(value)));

  Future<void> remove(String symbol) =>
      (_db.delete(_db.instruments)..where((t) => t.symbol.equals(symbol))).go();

  static const _nextSortOrder = 1000; // 新加入的排最後；以後要拖曳排序再改成小數/重排

  static List<OrderingTerm Function(Instruments)> get _ordering =>
      [(t) => OrderingTerm.asc(t.sortOrder)];
}
