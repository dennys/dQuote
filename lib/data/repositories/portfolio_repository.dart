import 'package:drift/drift.dart';

import '../db/database.dart';

/// 持股與現金／外幣。兩張表同一個 repo，因為在 UI 上它們就是同一頁的兩個區塊，
/// 而「外幣 = 會隨匯率變值的現金」這層關係不該被 repo 邊界切開。
class PortfolioRepository {
  PortfolioRepository(this._db);
  final AppDatabase _db;

  // ---------------------------------------------------------------- 持股

  Future<List<Holding>> holdings() => (_db.select(_db.holdings)
        ..orderBy([(t) => OrderingTerm.asc(t.symbol)]))
      .get();

  Future<int> addHolding({
    required String symbol,
    required String market,
    required String ccy,
    required double shares,
    required double costPrice,
    double? costRate,
    DateTime? buyDate,
    String? broker,
    String? note,
  }) =>
      _db.into(_db.holdings).insert(HoldingsCompanion.insert(
            symbol: symbol,
            market: Value(market),
            ccy: Value(ccy),
            shares: shares,
            costPrice: costPrice,
            costRate: Value(costRate),
            buyDate: Value(buyDate),
            broker: Value(broker),
            note: Value(note),
            updatedAt: DateTime.now(),
          ));

  Future<void> updateHolding(int id, {double? shares, double? costPrice, double? costRate, String? note}) =>
      (_db.update(_db.holdings)..where((t) => t.id.equals(id))).write(HoldingsCompanion(
        shares: shares == null ? const Value.absent() : Value(shares),
        costPrice: costPrice == null ? const Value.absent() : Value(costPrice),
        costRate: costRate == null ? const Value.absent() : Value(costRate),
        note: note == null ? const Value.absent() : Value(note),
        updatedAt: Value(DateTime.now()),
      ));

  Future<int> removeHolding(int id) =>
      (_db.delete(_db.holdings)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------- 現金／外幣

  Future<List<CashPosition>> cash() => (_db.select(_db.cashPositions)
        ..orderBy([(t) => OrderingTerm.asc(t.ccy)]))
      .get();

  Future<int> addCash({
    required String ccy,
    required double amount,
    double? costRate,
    required String kind,
    String label = '',
    String? note,
  }) =>
      _db.into(_db.cashPositions).insert(CashPositionsCompanion.insert(
            ccy: ccy,
            amount: amount,
            costRate: Value(costRate),
            kind: Value(kind),
            label: Value(label),
            note: Value(note),
            updatedAt: DateTime.now(),
          ));

  Future<void> updateCash(int id, {double? amount, double? costRate, String? label, String? note}) =>
      (_db.update(_db.cashPositions)..where((t) => t.id.equals(id))).write(CashPositionsCompanion(
        amount: amount == null ? const Value.absent() : Value(amount),
        costRate: costRate == null ? const Value.absent() : Value(costRate),
        label: label == null ? const Value.absent() : Value(label),
        note: note == null ? const Value.absent() : Value(note),
        updatedAt: Value(DateTime.now()),
      ));

  Future<int> removeCash(int id) =>
      (_db.delete(_db.cashPositions)..where((t) => t.id.equals(id))).go();
}
