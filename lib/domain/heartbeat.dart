import '../core/alerts.dart';
import '../core/clock.dart';
import '../core/models.dart';
import '../core/money.dart';
import '../core/trading_calendar.dart';
import '../core/widget_data.dart';
import '../data/db/database.dart';
import '../data/repositories/alert_repository.dart';
import '../data/repositories/instrument_repository.dart';
import '../data/repositories/quote_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../platform/platform.dart';
import 'digest_text.dart';
import 'fx_service.dart';
import 'portfolio_service.dart';

class HeartbeatResult {
  const HeartbeatResult({
    required this.at,
    required this.fetched,
    required this.fired,
    required this.cleared,
    required this.digestsSent,
    required this.skippedFetch,
    required this.errors,
  });

  final DateTime at;
  final int fetched, fired, cleared, digestsSent;
  final bool skippedFetch;
  final List<String> errors;

  @override
  String toString() =>
      'Heartbeat @$at fetched=$fetched fired=$fired cleared=$cleared digests=$digestsSent'
      '${skippedFetch ? ' (未抓報價)' : ''}${errors.isEmpty ? '' : ' errors=$errors'}';
}

/// **全專案唯一的排程邏輯**。15 分鐘一次心跳，每 tick 依序做：
/// 抓該抓的報價 → 評估提醒（re-arm 去重）→ 該發的收盤日報 → 刷新桌面小工具。
///
/// 刻意「不用 alarm、不用 foreground service、不用精確排程權限」：
/// 使用者接受的準確度是 15 分鐘等級，那麼輪詢 + 冪等 key 是最省的做法，而且被 Doze
/// 延後之後下一次 tick 會自動補上（發過沒有重發，因為 key 記在 Settings）。
class Heartbeat {
  Heartbeat({
    required this.clock,
    required this.calendar,
    required this.portfolio,
    required this.quotes,
    required this.alerts,
    required this.instruments,
    required this.settings,
    required this.fx,
    required this.notification,
    required this.widget,
    this.engine = const AlertEngine(),
    this.baseCcy = 'TWD',
  });

  final Clock clock;
  final TradingCalendar calendar;
  final PortfolioService portfolio;
  final QuoteRepository quotes;
  final AlertRepository alerts;
  final InstrumentRepository instruments;
  final SettingsRepository settings;
  final FxService fx;
  final NotificationGateway notification;
  final WidgetBridge widget;
  final AlertEngine engine;
  final String baseCcy;

  Future<HeartbeatResult> tick({bool force = false, DigestStrings strings = const DigestStrings.zh()}) async {
    final now = clock();
    final errors = <String>[];

    final ruleRows = await alerts.alerts();
    final rules = [for (final r in ruleRows) _toRule(r)];
    final instrumentsAll = await instruments.all();

    // 收盤日報的開關就是提醒頁那條 `closingDigest` 規則（沒建這條 = 預設開）。
    // 以前它是個完全沒人讀的 kind：設了不會觸發、不想收也沒有地方關。
    final digestRules = rules.where((r) => r.kind == AlertKind.closingDigest).toList();
    final digestOn = digestRules.isEmpty || digestRules.any((r) => r.enabled);

    final twKey = digestOn ? calendar.twDigestKey(now) : null;
    final usKey = digestOn ? calendar.usDigestKey(now) : null;
    final digestPending = (twKey != null && !await settings.isSent(twKey)) ||
        (usKey != null && !await settings.isSent(usKey));

    // 收盤日報需要的報價是「現在」的，所以有日報要發時一定抓；盤中才抓，盤外省電。
    final shouldFetch = force || digestPending || calendar.anyMarketOpenAt(now);

    final bundle = await portfolio.load(refresh: shouldFetch);

    // 提醒可能盯著不在自選股裡的代號（例如只設了 USD/TWD 的匯率提醒）→ 補抓那些
    var quoteMap = Map<String, Quote>.of(bundle.quotes);
    if (shouldFetch) {
      final extra = {for (final r in rules) if (r.symbol != null) r.symbol!}
          .difference(quoteMap.keys.toSet());
      if (extra.isNotEmpty) {
        try {
          final batch = await quotes.refresh(extra);
          fx.absorb(batch.quotes);
          quoteMap.addAll(batch.quotes);
        } on Object catch (e) {
          errors.add('提醒報價: $e');
        }
      }
    }

    var fired = 0, cleared = 0;
    if (rules.isNotEmpty) {
      final armed = await alerts.armedMap();
      final decisions = engine.evaluate(
        rules: rules,
        inputs: AlertInputs(
          quotes: quoteMap,
          positionPnlPct: bundle.positionPnlPct,
          portfolioPnlPct: bundle.summary.pnlPct,
        ),
        armedOf: (id) => armed[id] ?? true,
      );
      for (final d in decisions) {
        try {
          if (d.isClear) {
            await alerts.recordClear(d.rule.id, d.value);
            cleared++;
          } else {
            await alerts.recordFire(d.rule.id, d.value);
            await notification.showAlert(
              rule: d.rule,
              quote: d.rule.symbol == null ? null : quoteMap[d.rule.symbol],
              value: d.value,
              body: _alertBody(d, quoteMap, strings),
            );
            fired++;
          }
        } on Object catch (e) {
          errors.add('通知#${d.rule.id}: $e');
        }
      }
    }

    var digests = 0;
    for (final (key, market) in [(twKey, 'TW'), (usKey, 'US')]) {
      if (key == null || await settings.isSent(key)) continue;
      try {
        final digest = await _buildDigest(market, key, bundle, quoteMap, instrumentsAll);
        final text = buildDigestText(digest, strings, _formatter(bundle), bundle.updatedAt);
        await notification.showDigest(key: key, title: text.title, body: text.body);
        await settings.markSent(key); // 發成功才標記 → 失敗下次 tick 會重試
        digests++;
      } on Object catch (e) {
        errors.add('日報 $key: $e');
      }
    }

    try {
      await _publishWidget(quoteMap);
    } on Object catch (e) {
      errors.add('小工具: $e');
    }

    await settings.markHeartbeat(now);
    return HeartbeatResult(
      at: now,
      fetched: shouldFetch ? quoteMap.length : 0,
      fired: fired,
      cleared: cleared,
      digestsSent: digests,
      skippedFetch: !shouldFetch,
      errors: errors,
    );
  }

  AlertRule _toRule(Alert r) => AlertRule(
        id: r.id,
        kind: AlertKind.values.firstWhere((e) => e.name == r.kind, orElse: () => AlertKind.above),
        scope: r.scope == AlertScope.portfolio.name ? AlertScope.portfolio : AlertScope.single,
        symbol: r.symbol,
        threshold: r.threshold,
        enabled: r.enabled,
        note: r.note,
      );

  String _alertBody(AlertDecision d, Map<String, Quote> quotes, DigestStrings s) {
    final q = d.rule.symbol == null ? null : quotes[d.rule.symbol];
    final name = (q?.name == null || q!.name.isEmpty) ? (d.rule.symbol ?? '') : q.name;
    final price = q == null ? '' : '${q.price}';
    final pct = q?.changePct == null ? '' : '${q!.changePct!.toStringAsFixed(2)}%';
    final threshold = d.rule.threshold == null ? '' : '${d.rule.threshold}';
    return '$name $price（$pct）— ${s.alertTitle} ${d.rule.kind.name} $threshold';
  }

  Future<ClosingDigest> _buildDigest(
    String market,
    String key,
    PortfolioBundle bundle,
    Map<String, Quote> quoteMap,
    List<Instrument> all,
  ) async {
    final rows = [
      for (final i in all)
        if (_digestMarketOf(i.market) == market && quoteMap[i.symbol] != null)
          _row(quoteMap[i.symbol]!, displayName: _displayName(i, quoteMap[i.symbol]!)),
    ];
    return ClosingDigest(
      market: market,
      tradingDate: key.split('-').skip(1).join('-'),
      summary: bundle.summary,
      gainers: ClosingDigest.rank(rows, up: true),
      losers: ClosingDigest.rank(rows, up: false),
      indexQuote: market == 'TW' ? quoteMap['^TWII'] : null,
    );
  }

  /// Instruments 存的是 `taiwan`/`america`，日報用的是 `TW`/`US`。
  static String _digestMarketOf(String stored) => switch (stored) {
        'taiwan' => 'TW',
        'america' => 'US',
        _ => stored,
      };

  /// 顯示名的優先序：**使用者自己取的 > 自選股存的 > 來源給的**。
  /// Yahoo 對部分台股根本沒給名稱（只給 longName 或乾脆沒有），所以不能只用來源的名字。
  static String _displayName(Instrument i, Quote q) {
    final alias = i.alias;
    if (alias != null && alias.isNotEmpty) return alias;
    if (i.name.isNotEmpty) return i.name;
    return q.name.isNotEmpty ? q.name : q.symbol;
  }

  WidgetRow _row(Quote q, {String? displayName}) => WidgetRow(
        symbol: q.symbol,
        name: displayName ?? (q.name.isNotEmpty ? q.name : q.symbol),
        price: q.price,
        change: q.change,
        changePct: q.changePct,
        currency: q.currency,
        market: q.market,
      );

  MoneyFormatter _formatter(PortfolioBundle b) =>
      MoneyFormatter(baseCcy: baseCcy, rateOf: (c) => b.rates[c]);

  /// 開關某档要不要進小工具，並立刻重發。回傳「開啟時它有沒有真的出現在小工具上」——
  /// 超過設定頁那個列數上限時 `forWidget` 會截掉，呼叫端要換文案，別讓使用者以為按了沒效果。
  Future<bool> setInWidget(String symbol, bool value) async {
    await instruments.setInWidget(symbol, value);
    await refreshWidget();
    if (!value) return false;
    final rows = await instruments.forWidget(limit: await settings.widgetRows());
    return rows.any((i) => i.symbol == symbol);
  }

  /// 不打網路，只用快取的報價重發小工具：自選股增刪、改小工具開關後馬上反映，不用等下次心跳。
  Future<void> refreshWidget() async {
    try {
      final symbols = [for (final i in await instruments.all()) i.symbol];
      await _publishWidget(await quotes.cached(symbols));
    } on Object {
      // 小工具發布失敗不影響使用者操作，下次心跳會再發一次。
    }
  }

  /// 桌面小工具。列數上限就是設定頁那個滑桿（以前把 in_widget 的全部發出去，滑桿形同虛設）。
  Future<void> _publishWidget(Map<String, Quote> quoteMap) async {
    final inWidget = await instruments.forWidget(limit: await settings.widgetRows());
    if (inWidget.isEmpty) return; // 沒勾選就不打擾（也不要寫空 payload 蓋掉上次內容）
    final rows = [
      for (final i in inWidget)
        if (quoteMap[i.symbol] != null) _row(quoteMap[i.symbol]!, displayName: _displayName(i, quoteMap[i.symbol]!)),
    ];
    if (rows.isEmpty) return;
    // 「更新於」用快取批次的時間，不是現在：這一條路（refreshWidget、盤中跳過抓價的 tick）
    // 拿的是幾十分鐘前的報價，打 clock() 會讓小工具報一個比 app 還新的時間。
    final updatedAt = await quotes.lastUpdated() ?? clock();
    await widget.publish(WidgetPayload(
      updatedAt: updatedAt.millisecondsSinceEpoch ~/ 1000,
      baseCcy: 'TWD',
      redIsUp: await settings.redIsUp(),
      rows: rows,
    ));
  }
}
