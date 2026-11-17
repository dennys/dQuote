import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_format.dart';
import '../core/models.dart';
import '../core/money.dart';
import '../core/symbol.dart';
import '../data/db/database.dart';
import '../di.dart';
import '../generated/l10n/app_localizations.dart';
import '../theme.dart';
import 'quote_detail_page.dart';
import 'settings_page.dart';

/// 自選清單：台股、美股、匯率混排在同一頁，順序由使用者拖曳決定。
class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> with WidgetsBindingObserver {
  Timer? _timer;

  /// Stream／Future **必須在 build 之外建立**。在 build 裡呼叫 `watchAll()` 會每次產生新的
  /// stream → StreamBuilder 重新訂閱 → drift 推一次初值 → setState → 無限重建迴圈
  /// （CPU 燒滿、電吃掉一半；`test/app_smoke_test.dart` 就是用来擋這個）。
  late final Stream<List<Instrument>> _instruments = getIt<AppContainer>().instruments.watchAll();
  late final Stream<Map<String, Quote>> _quotes = getIt<AppContainer>().quotes.watchCached();

  Future<DateTime?>? _updatedAt;

  /// 前景自動刷新間隔。背景交給 15 分鐘心跳（見 PLAN：使用者接受的準確度是 15 分鐘等級，
  /// 前景 30 秒已經夠「看起來是活的」，再短只是多打 request）。
  static const _foregroundInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    _updatedAt = getIt<AppContainer>().quotes.lastUpdated();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh(silent: true));
  }

  @override
  void dispose() {
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// app 進背景後 Dart 的 timer **還是會跑**（Android 不會凍結 isolate），三個分頁一起就是
  /// 每 30 秒把整份自選股打一遍 —— 整套「15 分鐘心跳省電」的設計會被它抵銷。
  /// 所以前景輪詢只用在前景；背景交給心跳。
  void _startTimer() =>
      _timer ??= Timer.periodic(_foregroundInterval, (_) => _refresh(silent: true));
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
      _refresh(silent: true);
    } else {
      _stopTimer();
    }
  }

  Future<List<String>> _symbols() async {
    final c = getIt<AppContainer>();
    final rows = await c.instruments.all();
    return rows.map((e) => e.symbol).toList();
  }

  Future<void> _refresh({bool silent = false}) async {
    final symbols = await _symbols();
    if (symbols.isEmpty) return;
    final c = getIt<AppContainer>();
    try {
      await c.quotes.refresh(symbols);
      // 匯率有 TTL 快取，未過期時 ensureRates 不會打網路，所以不必依分頁判斷
      await c.fx.ensureRates(knownFxBases);
      if (mounted) setState(() => _updatedAt = getIt<AppContainer>().quotes.lastUpdated());
    } on Object {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.loadFailedHint)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tabWatchlist),
        actions: [
          IconButton(
            tooltip: l.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SettingsPage(onRunTick: () => getIt<AppContainer>().heartbeat.tick(force: true)))),
          ),
          IconButton(
            tooltip: l.actionAdd,
            icon: const Icon(Icons.add),
            onPressed: () => _addItem(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: StreamBuilder<List<Instrument>>(
          stream: _instruments,
          builder: (context, snap) {
            final rows = snap.data ?? const <Instrument>[];
            if (rows.isEmpty) return _empty(context, l);
            return StreamBuilder<Map<String, Quote>>(
              stream: _quotes,
              builder: (context, qsnap) => ReorderableListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: rows.length + 1, // 最後一是「更新於 …」的 footer
                buildDefaultDragHandles: false, // 只用長按拖曳，否則會吃掉點選
                onReorderItem: (oldIndex, newIndex) => _reorder(rows, oldIndex, newIndex),
                itemBuilder: (context, i) {
                  if (i == rows.length) {
                    return KeyedSubtree(key: const ValueKey('footer'), child: _footer(context));
                  }
                  final ins = rows[i];
                  return ReorderableDelayedDragStartListener(
                    // 長按才開始拖（點擊仍交給 ListTile 開走勢頁）
                    key: ValueKey('drag-${ins.symbol}'),
                    index: i,
                    child: _QuoteTile(instrument: ins, quote: qsnap.data?[ins.symbol]),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  /// 拖曳排序後寫回 sortOrder。
  Future<void> _reorder(List<Instrument> rows, int oldIndex, int newIndex) async {
    if (oldIndex >= rows.length) return;
    // onReorderItem（新版 API）給的 newIndex 已經扣掉被移走的那一格，不用再自己減
    final to = newIndex.clamp(0, rows.length - 1); // 最後一是 footer，不能排到它後面
    if (to == oldIndex) return;
    final symbols = rows.map((e) => e.symbol).toList();
    symbols.insert(to, symbols.removeAt(oldIndex));
    await getIt<AppContainer>().instruments.reorder(symbols);
  }

  Widget _empty(BuildContext context, AppLocalizations l) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(child: Text(l.emptyWatchlist, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      );

  Widget _footer(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return FutureBuilder<DateTime?>(
      future: _updatedAt,
      builder: (context, snap) {
        if (snap.data == null) return const SizedBox(height: 24);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              '${l.updatedOn(MoneyFormatter.clock(snap.data))} · ${l.labelDelayedQuote}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }

  Future<void> _addItem(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final c = getIt<AppContainer>();
    final controller = TextEditingController();
    var parsed = parseSymbol('');
    var checked = false;
    String? error;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(l.addInstrumentTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l.fieldSymbol,
                  hintText: l.addInstrumentHint,
                  errorText: error,
                ),
                onChanged: (v) {
                  parsed = parseSymbol(v);
                  error = v.trim().isEmpty ? null : (parsed == null ? l.symbolUnrecognized : null);
                  checked = false;
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              if (checked && parsed != null)
                Text('${parsed!.yahooSymbol} → ${parsed!.market.name}',
                    style: Theme.of(dialogContext).textTheme.bodySmall),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l.actionCancel)),
            FilledButton(
              onPressed: parsed == null
                  ? null
                  : () async {
                      final p = parsed!;
                      // 先抓 messenger：await 之後再用 context 會踩 use_build_context_synchronously
                      final messenger = ScaffoldMessenger.of(context);
                      final exists = await c.instruments.find(p.yahooSymbol);
                      if (exists != null) {
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        messenger.showSnackBar(SnackBar(content: Text(l.alreadyAdded)));
                        return;
                      }
                      try {
                        final batch = await c.quotes.refresh([p.yahooSymbol]);
                        final q = batch.quotes[p.yahooSymbol];
                        if (q == null) {
                          setState(() => error = l.symbolNotFound);
                          return;
                        }
                        await c.instruments.add(
                          symbol: q.symbol,
                          name: q.name,
                          currency: q.currency,
                          market: p.market,
                          inWidget: true,
                        );
                        await c.heartbeat.refreshWidget();
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } on Object {
                        setState(() => error = l.symbolNotFound);
                      }
                    },
              child: Text(l.actionAdd),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteTile extends StatelessWidget {
  const _QuoteTile({required this.instrument, required this.quote});

  final Instrument instrument;
  final Quote? quote;

  @override
  Widget build(BuildContext context) {
    final colors = context.priceColors;
    final fmt = moneyFormatter(context);
    final name = (instrument.alias?.isNotEmpty ?? false)
        ? instrument.alias!
        : (instrument.name.isNotEmpty ? instrument.name : instrument.symbol);
    final decimals = quote?.market == Market.fx ? 3 : null;

    return Dismissible(
      key: ValueKey(instrument.symbol),
      direction: DismissDirection.endToStart,
      background: Container(
        color: colors.down,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => getIt<AppContainer>().instruments.remove(instrument.symbol),
      child: ListTile(
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(instrument.symbol, style: Theme.of(context).textTheme.bodySmall),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              quote == null ? '—' : fmt.amount(quote!.price, quote!.currency, decimals: decimals),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.forChange(quote?.change), fontWeight: FontWeight.w600),
            ),
            Text(
              quote == null ? '' : quoteChangeText(fmt, quote!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.forChange(quote?.change)),
            ),
          ],
        ),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => QuoteDetailPage(symbol: instrument.symbol))),
        onLongPress: () => _toggleWidget(context),
      ),
    );
  }

  Future<void> _toggleWidget(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final c = getIt<AppContainer>();
    final next = !instrument.inWidget;
    final shown = await c.heartbeat.setInWidget(instrument.symbol, next);
    messenger.showSnackBar(SnackBar(
        content: Text(!next ? l.removedFromWidget : shown ? l.addedToWidget : l.widgetRowLimit)));
  }
}
