import '../db/database.dart';

/// scalar 設定 + **冪等 key**。
///
/// 有 drift 了就不引入 shared_preferences：少一個依賴、少一個 aarch64 釘版。
/// 收盤日報的「今天已發」就是放在這裡（`markSent('TW-2026-11-20')`），
/// 所以就算 WorkManager 被 Doze 延後、或 app 重啟，也不會重發。
class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  static const keyBaseCurrency = 'base_ccy';
  static const keyRedIsUp = 'red_is_up';
  static const keyTheme = 'theme'; // system|light|dark
  static const keyWidgetRows = 'widget_rows';
  static const keyDigestPrefix = 'digest'; // digest/<key> = '1'

  Future<String> _get(String key, String fallback) async {
    final row = await (_db.select(_db.settings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value ?? fallback;
  }

  Future<void> _set(String key, String value) => _db.into(_db.settings).insertOnConflictUpdate(
        SettingsCompanion.insert(key: key, value: value),
      );

  /// 基礎貨幣。现阶段固定 TWD；留 getter 是因為 UI／formatter 只從這裡取，
  /// 以後要做「切換基礎幣」只改選單，不用動顯示邏輯。
  Future<String> baseCcy() => _get(keyBaseCurrency, 'TWD');

  /// 紅漲綠跌（台灣慣例）。預設 true。
  Future<bool> redIsUp() async => (await _get(keyRedIsUp, '1')) == '1';
  Future<void> setRedIsUp(bool v) => _set(keyRedIsUp, v ? '1' : '0');

  /// system | light | dark
  Future<String> themeMode() => _get(keyTheme, 'system');
  Future<void> setThemeMode(String v) => _set(keyTheme, v);

  Future<int> widgetRows() async => int.tryParse(await _get(keyWidgetRows, '4')) ?? 4;
  Future<void> setWidgetRows(int v) => _set(keyWidgetRows, '$v');

  // ------------------------------------------------------------ 冪等 key

  Future<bool> isSent(String key) async =>
      await (_db.select(_db.settings)..where((t) => t.key.equals('$keyDigestPrefix/$key')))
          .getSingleOrNull() !=
      null;

  Future<void> markSent(String key) => _set('$keyDigestPrefix/$key', '1');

  /// 心跳最後執行的時刻，給設定頁的「上次檢查」顯示。
  /// 不是裝飾：通知沒來時，使用者自己就能看出是被省電策略殺了還是規則沒觸發。
  Future<DateTime?> lastHeartbeat() async {
    final v = (await _get('last_heartbeat', ''));
    return v.isEmpty ? null : DateTime.tryParse(v);
  }

  Future<void> markHeartbeat(DateTime t) => _set('last_heartbeat', t.toIso8601String());
}
