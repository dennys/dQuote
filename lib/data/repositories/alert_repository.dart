import 'package:drift/drift.dart';

import '../../core/alerts.dart';
import '../db/database.dart';

/// 提醒規則與觸發歷史。
///
/// **re-arm 狀態機的唯一來源是 [AlertLogs]**：同一條 alert 的最後一筆若是
/// `triggered == false`（代表條件已回到未成立），才算「武裝中」、才准再發。
/// 把狀態放在既有的一張表裡，而不是另外開一個 `armed` 欄位，好處是「通知歷史」頁
/// 跟狀態機永遠不會不一致（同一份資料两用）。
class AlertRepository {
  AlertRepository(this._db);
  final AppDatabase _db;

  Stream<List<Alert>> watchAlerts() => (_db.select(_db.alerts)
        ..orderBy([(t) => OrderingTerm.asc(t.id)]))
      .watch();

  Future<List<Alert>> alerts() => (_db.select(_db.alerts)
        ..orderBy([(t) => OrderingTerm.asc(t.id)]))
      .get();

  Future<int> addAlert({
    required AlertKind kind,
    required AlertScope scope,
    String? symbol,
    double? threshold,
    bool enabled = true,
    String? note,
  }) =>
      _db.into(_db.alerts).insert(AlertsCompanion.insert(
            kind: kind.name,
            scope: Value(scope.name),
            symbol: Value(symbol),
            threshold: Value(threshold),
            enabled: Value(enabled),
            note: Value(note),
            createdAt: DateTime.now(),
          ));

  Future<void> setEnabled(int id, bool enabled) =>
      (_db.update(_db.alerts)..where((t) => t.id.equals(id)))
          .write(AlertsCompanion(enabled: Value(enabled)));

  Future<int> removeAlert(int id) =>
      (_db.delete(_db.alerts)..where((t) => t.id.equals(id))).go();

  /// 一次讀出全部 alert 的武裝狀態（心跳每 15 分鐘叫一次，所以要一次查完而不是 N 次）。
  ///
  /// 每條 alert 只聽**最後一筆**（MAX(id)），所以先 group-by 取那些 id、再照 id 取回內容：
  /// 兩個小查詢。以前是把整張 `AlertLogs` 讀進 Dart 再 `putIfAbsent` —— 價格在門檻上進出的
  /// 規則每 tick 就寫 fire/clear 兩筆，放一年就會每 15 分鐘掃一次幾萬筆。
  Future<Map<int, bool>> armedMap() async {
    final maxId = _db.alertLogs.id.max();
    final grouped = _db.selectOnly(_db.alertLogs)
      ..addColumns([maxId])
      ..groupBy([_db.alertLogs.alertId]);
    final ids = (await grouped.get()).map((r) => r.read(maxId)!).toList();
    if (ids.isEmpty) return const {};
    final rows = await (_db.select(_db.alertLogs)..where((t) => t.id.isIn(ids))).get();
    return {for (final r in rows) r.alertId: !r.triggered}; // 最後一筆未觸發 → 武裝中
  }

  Future<void> recordFire(int alertId, double? value) => _log(alertId, value, true);
  Future<void> recordClear(int alertId, double? value) => _log(alertId, value, false);

  /// 觸發紀錄保留上限。狀態機只要每條的最後一筆、「通知歷史」頁也只顯示前 100 筆，
  /// 多留的沒人看，只會讓每次心跳多掃資料、資料庫一直長。
  static const historyLimit = 500;

  Future<void> _log(int alertId, double? value, bool triggered) async {
    await _db.into(_db.alertLogs).insert(AlertLogsCompanion.insert(
          alertId: alertId,
          firedAt: DateTime.now(),
          value: Value(value),
          triggered: Value(triggered),
        ));
    await _prune();
  }

  /// 只留最近 [historyLimit] 筆。id 是單調遞增的，所以「最舊的 N 筆」= id 最小的 N 筆，
  /// 一次範圍刪除；這個量不需要索引。
  Future<void> _prune() async {
    final total = _db.alertLogs.id.count();
    final row = await (_db.selectOnly(_db.alertLogs)..addColumns([total])).getSingle();
    final excess = (row.read(total) ?? 0) - historyLimit;
    if (excess <= 0) return;
    final stale = await (_db.select(_db.alertLogs)
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(excess))
        .get();
    await (_db.delete(_db.alertLogs)..where((t) => t.id.isIn({for (final r in stale) r.id}))).go();
  }

  /// 「通知歷史」頁用
  Future<List<AlertLog>> history({int limit = 100}) => (_db.select(_db.alertLogs)
        ..orderBy([(t) => OrderingTerm.desc(t.id)])
        ..limit(limit))
      .get();
}
