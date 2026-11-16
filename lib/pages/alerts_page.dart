import 'package:flutter/material.dart';

import '../core/alerts.dart';
import '../core/money.dart';
import '../core/symbol.dart';
import '../data/db/database.dart';
import '../di.dart';
import '../generated/l10n/app_localizations.dart';

/// 提醒頁：規則清單 + 通知歷史 + 「上次檢查」診斷列。
///
/// 「上次檢查 HH:mm」不是裝飾 —— 通知沒來時，使用者自己就能分辨是「被省電策略殺了」
/// 還是「條件根本沒觸發」，省掉大量疑難雜症的时间。
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  /// 見 `watchlist_page.dart` 的說明：stream 在 build 外建立，否則無限重建。
  late final Stream<List<Alert>> _alerts = getIt<AppContainer>().alerts.watchAlerts();
  List<AlertLog> _history = const [];
  DateTime? _lastCheck;
  bool _notifGranted = true;

  @override
  void initState() {
    super.initState();
    _loadExtras();
    _askPermission();
  }

  /// 提醒送不送得出去，取決於 POST_NOTIFICATIONS。**進這頁就問一次**：
  /// 太早問（啟動時）會被拒得莫名其妙，太晚問（等使用者設好提醒）的話他根本不知道
  /// 自己一條都不會收到。被拒時頁面留一條提示，點「重試」可以再問。
  Future<void> _askPermission() async {
    final granted = await getIt<AppContainer>().notification.ensurePermission();
    if (!mounted) return;
    setState(() => _notifGranted = granted);
  }

  Future<void> _loadExtras() async {
    final c = getIt<AppContainer>();
    final history = await c.alerts.history();
    final last = await c.settings.lastHeartbeat();
    if (!mounted) return;
    setState(() {
      _history = history;
      _lastCheck = last;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.tabAlerts),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _add(context)),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadExtras),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (!_notifGranted)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(Icons.notifications_off_outlined,
                    color: Theme.of(context).colorScheme.onErrorContainer),
                title: Text(l.notifPermissionMissing,
                    style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                trailing: TextButton(onPressed: _askPermission, child: Text(l.actionRetry)),
                onTap: _askPermission,
              ),
            ),
          StreamBuilder<List<Alert>>(
            stream: _alerts,
            builder: (context, snap) {
              final rows = snap.data ?? const <Alert>[];
              if (rows.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text(l.emptyAlerts)),
                );
              }
              return Column(
                children: [for (final a in rows) _AlertTile(alert: a, onChanged: _loadExtras)],
              );
            },
          ),
          const SizedBox(height: 16),
          if (_lastCheck != null)
            Text('${l.labelLastCheck}: ${MoneyFormatter.clock(_lastCheck)}',
                style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Text(l.alertHistory, style: Theme.of(context).textTheme.titleMedium),
          if (_history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l.alertHistoryEmpty, style: Theme.of(context).textTheme.bodySmall),
            )
          else
            for (final log in _history)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${log.triggered ? '●' : '○'} ${log.alertId} #${log.id}',
                    style: Theme.of(context).textTheme.bodyMedium),
                subtitle: Text(log.value == null
                    ? MoneyFormatter.clock(log.firedAt)
                    : '${MoneyFormatter.clock(log.firedAt)} · ${log.value}'),
              ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final c = getIt<AppContainer>();
    var kind = AlertKind.above;
    var scope = AlertScope.single;
    final symbolCtrl = TextEditingController();
    final thresholdCtrl = TextEditingController();
    String? error;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final needsSymbol = kind != AlertKind.pnl || scope == AlertScope.single;
          return AlertDialog(
            title: Text(l.addAlertTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<AlertKind>(
                    initialValue: kind,
                    items: [
                      DropdownMenuItem(value: AlertKind.above, child: Text(l.alertKindAbove)),
                      DropdownMenuItem(value: AlertKind.below, child: Text(l.alertKindBelow)),
                      DropdownMenuItem(value: AlertKind.dayChange, child: Text(l.alertKindDayChange)),
                      DropdownMenuItem(value: AlertKind.pnl, child: Text(l.alertKindPnl)),
                      DropdownMenuItem(value: AlertKind.fx, child: Text(l.alertKindFx)),
                      DropdownMenuItem(value: AlertKind.closingDigest, child: Text(l.alertKindClosingDigest)),
                    ],
                    onChanged: (v) => setState(() => kind = v ?? kind),
                  ),
                  if (kind == AlertKind.pnl)
                    DropdownButtonFormField<AlertScope>(
                      initialValue: scope,
                      items: [
                        DropdownMenuItem(value: AlertScope.single, child: Text(l.alertScopeSingle)),
                        DropdownMenuItem(value: AlertScope.portfolio, child: Text(l.alertScopePortfolio)),
                      ],
                      onChanged: (v) => setState(() => scope = v ?? scope),
                    ),
                  if (needsSymbol && kind != AlertKind.closingDigest)
                    TextField(
                        controller: symbolCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(labelText: l.fieldSymbol, errorText: error)),
                  if (kind != AlertKind.closingDigest)
                    TextField(
                        controller: thresholdCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: InputDecoration(labelText: l.fieldThreshold)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l.actionCancel)),
              FilledButton(
                onPressed: () async {
                  final symbolText = symbolCtrl.text.trim();
                  String? symbol;
                  if (needsSymbol && kind != AlertKind.closingDigest && symbolText.isNotEmpty) {
                    // 只支援代號輸入（**不做中文搜尋**：實測 Yahoo 對「台積電」回 0 筆）
                    final parsed = parseSymbol(symbolText);
                    if (parsed == null) {
                      setState(() => error = l.symbolUnrecognized);
                      return;
                    }
                    symbol = parsed.yahooSymbol;
                  }
                  final threshold = double.tryParse(thresholdCtrl.text.trim());
                  await c.alerts.addAlert(
                    kind: kind,
                    scope: scope,
                    symbol: symbol,
                    threshold: threshold,
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  await _loadExtras();
                },
                child: Text(l.actionSave),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onChanged});
  final Alert alert;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final kind = AlertKind.values.firstWhere((e) => e.name == alert.kind, orElse: () => AlertKind.above);
    final label = switch (kind) {
      AlertKind.closingDigest => l.alertKindClosingDigest,
      AlertKind.above => l.alertKindAbove,
      AlertKind.below => l.alertKindBelow,
      AlertKind.dayChange => l.alertKindDayChange,
      AlertKind.pnl => l.alertKindPnl,
      AlertKind.fx => l.alertKindFx,
    };
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: alert.enabled,
      onChanged: (v) async {
        await getIt<AppContainer>().alerts.setEnabled(alert.id, v);
        onChanged();
      },
      title: Text(label),
      subtitle: Text([
        if (alert.symbol != null) alert.symbol!,
        if (alert.threshold != null) '${alert.threshold}',
        if (alert.scope == 'portfolio') l.alertScopePortfolio,
      ].join(' · ')),
      secondary: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          await getIt<AppContainer>().alerts.removeAlert(alert.id);
          onChanged();
        },
      ),
    );
  }
}
