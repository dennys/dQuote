import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart' show SettingsController;
import '../core/money.dart';
import '../di.dart';
import '../domain/heartbeat.dart';
import '../generated/l10n/app_localizations.dart';

/// 設定頁。開發者區那顆「立即執行一次檢查」是**驗收用的**：
/// WorkManager 的 15 分鐘對開發太慢，按它等於手動跑一次心跳（同一條程式路徑，
/// 不是另寫一條「測試用」邏輯，所以測過的東西就是實際上線會跑的東西）。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.onRunTick});

  /// 由上層注入（測試可換成假的）；預設直接跑 container 的心跳。
  final Future<HeartbeatResult> Function()? onRunTick;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _busy = false;
  int _widgetRows = 4;
  DateTime? _lastCheck;

  /// 見 `watchlist_page.dart`：Future 也要在 build 外建立，否則無限重建。
  final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = getIt<AppContainer>();
    final rows = await c.settings.widgetRows();
    final last = await c.settings.lastHeartbeat();
    if (!mounted) return;
    setState(() {
      _widgetRows = rows;
      _lastCheck = last;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sectionTitle(context, l.settingsTheme),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'system', label: Text(l.settingsThemeSystem)),
              ButtonSegment(value: 'light', label: Text(l.settingsThemeLight)),
              ButtonSegment(value: 'dark', label: Text(l.settingsThemeDark)),
            ],
            selected: {settings.themeMode.name},
            onSelectionChanged: (s) => settings.setThemeMode(
                s.first == 'light' ? ThemeMode.light : s.first == 'dark' ? ThemeMode.dark : ThemeMode.system),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: settings.redIsUp,
            onChanged: settings.setRedIsUp,
            title: Text(l.settingsRedIsUp),
          ),
          const Divider(),
          _sectionTitle(context, l.settingsWidgetRows),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _widgetRows.toDouble(),
                  min: 2,
                  max: 8,
                  divisions: 6,
                  label: '$_widgetRows',
                  onChanged: (v) => setState(() => _widgetRows = v.round()),
                  onChangeEnd: (v) async {
                    // 只存設定就好：下次心跳發布小工具時會照這個列數截斷
                    // （`Heartbeat._publishWidget` → `InstrumentRepository.forWidget(limit:)`）。
                    await getIt<AppContainer>().settings.setWidgetRows(v.round());
                  },
                ),
              ),
              Text('$_widgetRows'),
            ],
          ),
          const Divider(),
          _sectionTitle(context, l.settingsNotifications),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.notifPermRationale),
            trailing: TextButton(
              onPressed: () async {
                final granted = await getIt<AppContainer>().notification.ensurePermission();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(granted ? '✓' : l.loadFailedHint)));
                }
              },
              child: Text(l.actionSave),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('⚙ 電池最佳化設定'),
            subtitle: const Text('Pixel 內建省電即可；被限制時請設「無限制」',
                style: TextStyle(fontSize: 12)),
            trailing: TextButton(
              onPressed: () async {
                // shortcut: url_launcher 開不進「電池最佳化」這個頁面（Android 沒公開 scheme），
                // 只能開 App 資訊頁。開失敗時退回顯示手動路徑。
                final ok = await launchUrl(Uri.parse('package:com.dennys.dquote'));
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('設定 → 應用程式 → dQuote → 電池 → 無限制')));
                }
              },
              child: const Icon(Icons.open_in_new, size: 18),
            ),
          ),
          const Divider(),
          _sectionTitle(context, l.settingsDeveloper),
          if (_lastCheck != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${l.labelLastCheck}: ${MoneyFormatter.clock(_lastCheck)}'),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.settingsRunTickNow),
            trailing: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow),
            onTap: _busy ? null : _runTick,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.settingsRunTickViaScheduler),
            // 真正上線跑的是這條路（WorkManager → heartbeatDispatcher → 另一個 isolate，
            // 還會自己 initialize 通知 channel）；上面那顆在 UI isolate 裡跑，驗不到那些。
            subtitle: Text(l.settingsTickScheduled, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.play_arrow),
            onTap: () async {
              await getIt<AppContainer>().scheduler.runNow();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.settingsTickScheduled)));
              }
            },
          ),
          const Divider(),
          _sectionTitle(context, l.settingsAbout),
          FutureBuilder<PackageInfo>(
            future: _packageInfo, // 同頁共用一個 Future，不要在 build 裡 new（會無限重建）
            builder: (context, snap) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.settingsVersion),
              trailing: Text('${snap.data?.version ?? '—'}+${snap.data?.buildNumber ?? ''}'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );

  Future<void> _runTick() async {
    setState(() => _busy = true);
    try {
      final result = await (widget.onRunTick ??
          () => getIt<AppContainer>().heartbeat.tick(force: true))();
      await _load();
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.settingsRunTickNow),
            content: SingleChildScrollView(child: SelectableText(result.toString())),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext),
                  child: Text(AppLocalizations.of(context)!.actionClose)),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
