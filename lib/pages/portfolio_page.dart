import 'package:flutter/material.dart';

import '../core/app_format.dart';
import '../core/models.dart';
import '../core/pnl.dart';
import '../core/symbol.dart';
import '../domain/portfolio_service.dart';
import '../di.dart';
import '../generated/l10n/app_localizations.dart';
import 'symbol_field.dart';
import '../theme.dart';

/// 持股總覽：總資產 + 損益拆解（證券 / 匯兌 / 合計）+ 資產配置 + 持股 + 現金外幣。
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  PortfolioBundle? _bundle;
  bool _loading = true;
  bool _showAll = false; // 持倉很多時預設只看前 8 大，避免一屏塞爆

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = true}) async {
    setState(() => _loading = true);
    try {
      final b = await getIt<AppContainer>().portfolioService.load(refresh: refresh);
      if (mounted) setState(() => _bundle = b);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.tabPortfolio),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _load()),
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddSheet(context)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(),
        child: _loading && _bundle == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                children: [
                  _SummaryCard(bundle: _bundle),
                  const SizedBox(height: 12),
                  _AllocationCard(bundle: _bundle),
                  const SizedBox(height: 16),
                  Text(l.labelHoldings, style: Theme.of(context).textTheme.titleMedium),
                  ..._holdingRows(),
                  TextButton(
                    onPressed: _holdingCount() > 8 ? () => setState(() => _showAll = !_showAll) : null,
                    child: Text(_showAll ? '⌃' : '⌄'),
                  ),
                  const SizedBox(height: 12),
                  Text('${l.labelCash} / ${l.labelForeignCash}', style: Theme.of(context).textTheme.titleMedium),
                  ..._cashRows(),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  int _holdingCount() => _bundle?.summary.positions.length ?? 0;

  List<Widget> _holdingRows() {
    final s = _bundle?.summary;
    if (s == null || s.positions.isEmpty) return [const _HintLine()];
    final list = s.positions.toList()
      ..sort((a, b) => b.marketValueBase.compareTo(a.marketValueBase));
    final visible = _showAll ? list : list.take(8).toList();
    return [for (final p in visible) _PositionTile(p: p, onMenu: () => _positionMenu(p))];
  }

  List<Widget> _cashRows() {
    final cs = _bundle?.summary.cashes;
    if (cs == null || cs.isEmpty) return [const _HintLine()];
    return [for (final c in cs) _CashTile(c: c, onMenu: () => _cashMenu(c))];
  }

  /// 長按一列 → 編輯或刪除。**編輯一定要能進**，否則加倉得先刪掉重填，
  /// 而重填時成本價很容易填成「今天的價格」，損益就整筆錯掉（而且使用者不會發覺）。
  Future<void> _positionMenu(PositionPnl p) => _rowMenu(p.symbol, [
        (Icons.edit_outlined, AppLocalizations.of(context)!.actionEdit, () async {
          await _holdingDialog(context, existing: p);
          await _load(refresh: false);
        }),
        (Icons.delete_outline, AppLocalizations.of(context)!.actionDelete, () => _removePosition(p)),
      ]);

  Future<void> _cashMenu(CashPnl c) => _rowMenu('${c.label} (${c.ccy})', [
        (Icons.edit_outlined, AppLocalizations.of(context)!.actionEdit, () async {
          await _cashDialog(context, existing: c);
          await _load(refresh: false);
        }),
        (Icons.delete_outline, AppLocalizations.of(context)!.actionDelete, () => _removeCash(c)),
      ]);

  /// 共用的長按選單（兩個地方只差項目），另開一個函式是為了別在 widget 裡寫 callback  spaghetti。
  Future<void> _rowMenu(String title, List<(IconData, String, Future<void> Function())> items) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(title, style: Theme.of(context).textTheme.labelLarge)),
            for (final (icon, label, _) in items)
              ListTile(leading: Icon(icon), title: Text(label), onTap: () => Navigator.pop(sheetContext, label)),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    final hit = items.where((e) => e.$2 == choice).firstOrNull;
    if (hit != null) await hit.$3();
  }

  Future<void> _removePosition(PositionPnl p) async {
    if (p.id == null) return;
    await getIt<AppContainer>().portfolio.removeHolding(p.id!);
    await _load(refresh: false);
  }

  Future<void> _removeCash(CashPnl c) async {
    if (c.id == null) return;
    await getIt<AppContainer>().portfolio.removeCash(c.id!);
    await _load(refresh: false);
  }

  Future<void> _showAddSheet(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: Text(l.addHoldingTitle),
              onTap: () => Navigator.pop(sheetContext, 'holding'),
            ),
            ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: Text(l.addCashTitle),
              onTap: () => Navigator.pop(sheetContext, 'cash'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || choice == null) return;
    if (choice == 'holding') {
      await _holdingDialog(context);
    } else {
      await _cashDialog(context);
    }
    if (context.mounted) await _load(refresh: false);
  }

  /// 新增／編輯持股（同一支 dialog，`existing` 非空就是編輯）。
  /// 代號鎖定：改代號等於換一档，應該是刪一筆加一筆，不是把這筆的成本搬過去。
  Future<void> _holdingDialog(BuildContext context, {PositionPnl? existing}) async {
    final l = AppLocalizations.of(context)!;
    final c = getIt<AppContainer>();
    final symbolCtrl = TextEditingController(text: existing?.symbol ?? '');
    final sharesCtrl = TextEditingController(text: existing == null ? '' : _num(existing.shares));
    final costCtrl = TextEditingController(text: existing == null ? '' : _num(existing.costPrice));
    String? error;
    // 持股常常就是自選股裡那一档 → 給清單選；還是可以打（沒加自選的那档）。
    final options = symbolOptionsOf(await c.instruments.all());
    if (!context.mounted) return; // await 之後才用 context 開 dialog

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(existing == null ? l.addHoldingTitle : l.actionEdit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SymbolField(
                  controller: symbolCtrl,
                  enabled: existing == null,
                  options: options,
                  labelText: l.fieldSymbol,
                  errorText: error,
                  hintText: '2330 · TSM'),
              TextField(
                  controller: sharesCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l.fieldShares)),
              TextField(
                  controller: costCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l.fieldCostPrice)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l.actionCancel)),
            FilledButton(
              onPressed: () async {
                final parsed = parseSymbol(symbolCtrl.text);
                final shares = double.tryParse(sharesCtrl.text);
                final cost = double.tryParse(costCtrl.text);
                if (parsed == null) {
                  setState(() => error = l.symbolUnrecognized);
                  return;
                }
                if (shares == null || cost == null || shares <= 0 || cost <= 0) return;

                // 建持股時就鎖定「買進時的匯率」，之後才能拆出匯兌損益（沒有匯率的本幣 → null）
                double? costRate;
                if (parsed.market != Market.taiwan) {
                  await c.fx.ensureRates([_ccyOf(parsed)]);
                  costRate = c.fx.rateOf(_ccyOf(parsed));
                }
                if (existing == null) {
                  await c.portfolio.addHolding(
                    symbol: parsed.yahooSymbol,
                    market: parsed.market.name,
                    ccy: _ccyOf(parsed),
                    shares: shares,
                    costPrice: cost,
                    costRate: costRate,
                  );
                } else if (existing.id != null) {
                  // 用列 id 而不是拿 symbol 反查：同一檔買兩次（兩筆列）是常態，
                  // 用 symbol 會永遠改到第一筆 —— 另一筆的成本悄悄被踩掉。
                  await c.portfolio.updateHolding(existing.id!, shares: shares, costPrice: cost);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(l.actionSave),
            ),
          ],
        ),
      ),
    );
  }

  static Future<double?> _liveRate(AppContainer c, String ccy) async {
    await c.fx.ensureRates([ccy]);
    return c.fx.rateOf(ccy);
  }

  /// 編輯時預填的數字：整數不要變成「1000.0」這種難看的樣子。
  static String _num(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  static String _ccyOf(ParsedSymbol p) =>
      p.market == Market.taiwan || p.yahooSymbol.endsWith('TWD=X') ? 'TWD' : 'USD';

  /// 新增／編輯現金・外幣部位。幣別與種類鎖定（它們是這筆的識別條件），
  /// 可改的是金額與「取得時的匯率」（留空＝不改；新增時自動抓當日的）。
  Future<void> _cashDialog(BuildContext context, {CashPnl? existing}) async {
    final l = AppLocalizations.of(context)!;
    final c = getIt<AppContainer>();
    final amountCtrl = TextEditingController(text: existing == null ? '' : _num(existing.amount));
    final rateCtrl = TextEditingController();
    var ccy = existing?.ccy ?? 'USD';
    var kind = existing?.kind ?? 'bank';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(existing == null ? l.addCashTitle : l.actionEdit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: ccy,
                items: [for (final b in ['TWD', ...knownFxBases]) DropdownMenuItem(value: b, child: Text(b))],
                // 幣別是這筆的識別條件，編輯時鎖死（onChanged: null 就是 disable）
                onChanged: existing == null ? (v) => setState(() => ccy = v ?? ccy) : null,
              ),
              TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l.fieldAmount)),
              if (ccy != 'TWD')
                TextField(
                    controller: rateCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: l.fieldCostRate, hintText: existing == null ? '' : l.actionUnchanged)),
              DropdownButtonFormField<String>(
                initialValue: kind,
                items: [
                  DropdownMenuItem(value: 'broker', child: Text(l.cashKindBroker)),
                  DropdownMenuItem(value: 'bank', child: Text(l.cashKindBank)),
                  DropdownMenuItem(value: 'wallet', child: Text(l.cashKindWallet)),
                ],
                onChanged: (v) => setState(() => kind = v ?? kind),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l.actionCancel)),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text);
                if (amount == null || amount <= 0) return;
                if (existing == null) {
                  double? costRate;
                  if (ccy != 'TWD') {
                    costRate = double.tryParse(rateCtrl.text) ?? await _liveRate(c, ccy);
                  }
                  await c.portfolio.addCash(ccy: ccy, amount: amount, costRate: costRate, kind: kind);
                } else if (existing.id != null) {
                  // 同上：用列 id，不用 ccy+kind+label 反查
                  await c.portfolio.updateCash(existing.id!,
                      amount: amount, costRate: double.tryParse(rateCtrl.text));
                }
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.bundle});
  final PortfolioBundle? bundle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fmt = moneyFormatter(context);
    final colors = context.priceColors;
    final s = bundle?.summary;

    Widget row(String label, String value, [Color? color]) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.labelTotalAssets, style: Theme.of(context).textTheme.bodySmall),
            Text(
              s == null ? '—' : fmt.base(s.totalAssetsBase),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Divider(height: 20),
            row(l.labelSecuritiesPnl, s == null ? '—' : fmt.signedBase(s.securitiesPnlBase),
                s == null ? null : colors.forChange(s.securitiesPnlBase)),
            row(l.labelFxPnl, s == null ? '—' : fmt.signedBase(s.fxPnlBase),
                s == null ? null : colors.forChange(s.fxPnlBase)),
            row(l.labelCombinedPnl,
                s == null ? '—' : '${fmt.signedBase(s.pnlBase)} ${s.pnlPct == null ? '' : fmt.pct(s.pnlPct!)}',
                s == null ? null : colors.forChange(s.pnlBase)),
            if (s != null && s.buyingPowerBase > 0) row(l.labelBuyingPower, fmt.base(s.buyingPowerBase)),
            if (s != null && s.excludedSymbols.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('⚠ ${s.excludedSymbols.join(', ')} ${l.noData}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange)),
              ),
          ],
        ),
      ),
    );
  }
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard({required this.bundle});
  final PortfolioBundle? bundle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = bundle?.summary;
    if (s == null || s.totalAssetsBase == 0) return const SizedBox.shrink();

    final parts = <(String, double, Color)>[
      (l.labelHoldings, s.holdingsWeight, Theme.of(context).colorScheme.primary),
      (l.labelForeignCash, s.foreignCashWeight, Theme.of(context).colorScheme.tertiary),
      (l.labelCash, s.cashWeight, Theme.of(context).colorScheme.secondary),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.labelAllocation, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    for (final p in parts)
                      if (p.$2 > 0)
                        Expanded(flex: (p.$2 * 1000).round(), child: ColoredBox(color: p.$3)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                for (final (label, weight, color) in parts)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 10, height: 10, color: color),
                      const SizedBox(width: 4),
                      Text('$label ${(weight * 100).toStringAsFixed(0)}%'),
                    ],
                  ),
              ],
            ),
            if (s.concentratedSymbols().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠ ${l.labelHoldings} ${s.concentratedSymbols().join(', ')} > '
                  '${(PortfolioSummary.concentrationWarn * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PositionTile extends StatelessWidget {
  const _PositionTile({required this.p, required this.onMenu});
  final PositionPnl p;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fmt = moneyFormatter(context);
    final colors = context.priceColors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(p.name.isEmpty ? p.symbol : p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${p.symbol} · ${p.shares.toStringAsFixed(0)} ${l.fieldShares} · ${l.fieldCostPrice} ${fmt.amount(p.costPrice, p.ccy)}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(p.included ? fmt.base(p.marketValueBase) : '—',
              style: Theme.of(context).textTheme.titleSmall),
          Text(
            p.included
                ? '${fmt.signedBase(p.pnlBase)} ${p.pnlPct == null ? '' : fmt.pct(p.pnlPct!)}'
                : l.noData,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.forChange(p.pnlBase)),
          ),
        ],
      ),
      onLongPress: onMenu, // 長按 = 編輯／刪除
    );
  }
}

class _CashTile extends StatelessWidget {
  const _CashTile({required this.c, required this.onMenu});
  final CashPnl c;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final fmt = moneyFormatter(context);
    final colors = context.priceColors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${c.label} (${c.ccy})'),
      subtitle: Text(fmt.amount(c.amount, c.ccy)),
      trailing: c.isForeign
          ? Text(fmt.signedBase(c.fxPnlBase),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.forChange(c.fxPnlBase)))
          : Text(fmt.base(c.valueBase), style: Theme.of(context).textTheme.titleSmall),
      onLongPress: onMenu, // 長按 = 編輯／刪除
    );
  }
}

class _HintLine extends StatelessWidget {
  const _HintLine();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(AppLocalizations.of(context)!.emptyPortfolio,
            style: Theme.of(context).textTheme.bodySmall),
      );
}
