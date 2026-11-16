import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/app_format.dart';
import '../core/models.dart';
import '../core/alerts.dart';
import '../data/db/database.dart' show Holding;
import '../di.dart';
import '../generated/l10n/app_localizations.dart';
import '../theme.dart';

/// 個股詳情：走勢圖 + 區間切換 + 成本線。
///
/// 成本線是「三個字的程式量、很大的視覺價值」那一類功能：圖上畫一條虛線在你的成本，
/// 一眼就看得出現價離成本多遠。
class QuoteDetailPage extends StatefulWidget {
  const QuoteDetailPage({super.key, required this.symbol});
  final String symbol;

  @override
  State<QuoteDetailPage> createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends State<QuoteDetailPage> {
  QuoteRange _range = QuoteRange.d1;
  List<Candle> _candles = const [];
  Quote? _quote;
  String? _error;
  bool _loading = true;
  double? _costPrice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final c = getIt<AppContainer>();
    try {
      final candles = await c.quotes.history(widget.symbol, _range, force: force);
      final cached = await c.quotes.cached([widget.symbol]);
      final holdings = (await c.portfolio.holdings()).where((h) => h.symbol == widget.symbol).toList();
      if (!mounted) return;
      setState(() {
        _candles = candles;
        _quote = cached[widget.symbol];
        _costPrice = holdings.isEmpty ? null : _averageCost(holdings);
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  /// 同檔多筆買進 → 顯示加權平均成本（不是第一筆，那會誤導）。
  static double? _averageCost(List<Holding> holdings) {
    final shares = holdings.fold<double>(0, (a, h) => a + h.shares);
    if (shares == 0) return null;
    final cost = holdings.fold<double>(0, (a, h) => a + h.shares * h.costPrice);
    return cost / shares;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fmt = moneyFormatter(context);
    final colors = context.priceColors;
    final q = _quote;

    return Scaffold(
      appBar: AppBar(
        title: Text(q?.name.isNotEmpty == true ? q!.name : widget.symbol),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _load(force: true)),
          IconButton(
            icon: const Icon(Icons.add_alert_outlined),
            tooltip: l.addAlertTitle,
            onPressed: () => _addAlert(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(force: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    q == null ? '—' : fmt.amount(q.price, q.currency, decimals: q.market == Market.fx ? 3 : null),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colors.forChange(q?.change), fontWeight: FontWeight.w700),
                  ),
                ),
                if (q != null && q.changePct != null)
                  Text(fmt.pct(q.changePct!),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.forChange(q.change))),
              ],
            ),
            Text(widget.symbol, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            _RangeSelector(selected: _range, onChanged: (r) {
              setState(() => _range = r);
              _load();
            }),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('${l.loadFailed}\n$_error', textAlign: TextAlign.center))
                      : _candles.isEmpty
                          ? Center(child: Text(l.noData))
                          : _chart(context),
            ),
            const SizedBox(height: 8),
            if (_costPrice != null)
              Text('${l.labelCostLine} ${fmt.amount(_costPrice!, q?.currency ?? 'TWD')}',
                  style: Theme.of(context).textTheme.bodySmall),
            if (_candles.isNotEmpty)
              Text('${l.labelVolume}: ${_lastVolume()}', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  String _lastVolume() {
    final v = _candles.last.volume;
    if (v == null) return '—';
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(2)}B';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  Widget _chart(BuildContext context) {
    final colors = context.priceColors;
    final spots = [
      for (var i = 0; i < _candles.length; i++) FlSpot(i.toDouble(), _candles[i].close),
    ];
    final first = _candles.first.close;
    final last = _candles.last.close;
    final tint = last >= first ? colors.up : colors.down;

    return LineChart(
      LineChartData(
        minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.998,
        maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.002,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (_costPrice != null)
              HorizontalLine(
                y: _costPrice!,
                color: Colors.grey.shade600,
                strokeWidth: 1,
                dashArray: [6, 4],
              ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            barWidth: 2,
            color: tint,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: tint.withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }

  Future<void> _addAlert(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final c = getIt<AppContainer>();
    var kind = AlertKindPreset.above;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(l.addAlertTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<AlertKindPreset>(
                initialValue: kind,
                items: [
                  DropdownMenuItem(value: AlertKindPreset.above, child: Text(l.alertKindAbove)),
                  DropdownMenuItem(value: AlertKindPreset.below, child: Text(l.alertKindBelow)),
                  DropdownMenuItem(value: AlertKindPreset.dayChange, child: Text(l.alertKindDayChange)),
                ],
                onChanged: (v) => setState(() => kind = v ?? kind),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(labelText: l.fieldThreshold),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l.actionCancel)),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(controller.text.trim());
                if (value == null) return;
                await c.alerts.addAlert(
                  kind: switch (kind) {
                    AlertKindPreset.above => AlertKind.above,
                    AlertKindPreset.below => AlertKind.below,
                    AlertKindPreset.dayChange => AlertKind.dayChange,
                  },
                  scope: AlertScope.single,
                  symbol: widget.symbol,
                  threshold: value,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(l.actionSave),
            ),
          ],
        ),
      ),
    );
  }
}

/// UI 上只給三個預設（引擎支援 6 種，但從詳情頁加的就這三個最常用；
/// 其餘在提醒頁新增）。
enum AlertKindPreset { above, below, dayChange }

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onChanged});

  final QuoteRange selected;
  final ValueChanged<QuoteRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final labels = {
      QuoteRange.d1: l.range1d,
      QuoteRange.d5: l.range5d,
      QuoteRange.m1: l.range1m,
      QuoteRange.m3: l.range3m,
      QuoteRange.y1: l.range1y,
      QuoteRange.y5: l.range5y,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final r in QuoteRange.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(labels[r]!),
                selected: r == selected,
                onSelected: (_) => onChanged(r),
              ),
            ),
        ],
      ),
    );
  }
}
