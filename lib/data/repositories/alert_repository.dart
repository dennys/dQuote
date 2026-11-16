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

  /// 一次讀出全部 alert 的武裝狀態（心跳每 15 分鐘呼叫一次，所以要用一次查詢而不是 N 次）。
  Future<Map<int, bool>> armedMap() async {
    final rows = await (_db.select(_db.alertLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .get();
    final result = <int, bool>{};
    for (final r in rows) {
      result.putIfAbsent(r.alertId, () => !r.triggered); // 最後一筆未觸發 → 武裝中
    }
    return result;
  }

  Future<void> recordFire(int alertId, double? value) => _log(alertId, value, true);
  Future<void> recordClear(int alertId, double? value) => _log(alertId, value, false);

  Future<void> _log(int alertId, double? value, bool triggered) =>
      _db.into(_db.alertLogs).insert(AlertLogsCompanion.insert(
            alertId: alertId,
            firedAt: DateTime.now(),
            value: Value(value),
            triggered: Value(triggered),
          ));

  /// 「通知歷史」頁用
  Future<List<AlertLog>> history({int limit = 100}) => (_db.select(_db.alertLogs)
        ..orderBy([(t) => OrderingTerm.desc(t.id)])
        ..limit(limit))
      .get();
}
