// 參數用不帶底線的名字（API 讀起來乾淨），欄位用底線 → 這個 lint 在我們的寫法下無解
// ignore_for_file: prefer_initializing_formals

import '../core/models.dart';
import '../core/pnl.dart';
import '../data/db/database.dart';
import '../data/repositories/portfolio_repository.dart';
import '../data/repositories/quote_repository.dart';
import 'fx_service.dart';

/// 一次載入的結果：摘要 + 用的到的報價/匯率 + 失敗清單。
class PortfolioBundle {
  const PortfolioBundle({
    required this.summary,
    required this.quotes,
    required this.rates,
    required this.updatedAt,
    required this.failedSymbols,
  });

  final PortfolioSummary summary;
  final Map<String, Quote> quotes;
  final Map<String, double> rates;
  final DateTime? updatedAt;
  final List<String> failedSymbols;

  /// 給提醒引擎用的單檔損益%（引擎自己不算損益，避免兩套算法）
  Map<String, double> get positionPnlPct => {
        for (final p in summary.positions)
          if (p.pnlPct != null) p.symbol: p.pnlPct!,
      };
}

/// 把「持股 + 現金 + 報價 + 匯率」湊成 [PortfolioSummary] 的唯一地方。
/// UI 與心跳都走這裡，這樣「畫面上看到的損益」與「通知發出去的損益」不可能算法不同。
class PortfolioService {
  PortfolioService({
    required AppDatabase db,
    required PortfolioRepository portfolio,
    required QuoteRepository quotes,
    required FxService fx,
    this.baseCcy = 'TWD',
  })  : _db = db,
        _portfolio = portfolio,
        _quotes = quotes,
        _fx = fx;

  final AppDatabase _db;
  final PortfolioRepository _portfolio;
  final QuoteRepository _quotes;
  final FxService _fx;
  final String baseCcy;

  /// [refresh] = true 時先打網路再算；false 只用快取（開機、背景心跳自己抓完之後呼叫）。
  Future<PortfolioBundle> load({bool refresh = false}) async {
    final holdings = await _portfolio.holdings();
    final cash = await _portfolio.cash();
    final instruments = await (_db.select(_db.instruments).get());

    final symbols = <String>{
      for (final h in holdings) h.symbol,
      for (final i in instruments) i.symbol,
    };
    final ccys = <String>{
      for (final h in holdings) h.ccy,
      for (final c in cash) c.ccy,
    };

    var failed = <String>[];
    if (refresh && symbols.isNotEmpty) {
      final batch = await _quotes.refresh(symbols);
      _fx.absorb(batch.quotes);
      failed = batch.failed.keys.toList();
    }
    await _fx.ensureRates(ccys, force: refresh);

    final quotes = await _quotes.cached(symbols);
    final bySymbol = {for (final i in instruments) i.symbol: i};

    final inputs = [
      for (final h in holdings)
        PositionInput(
          id: h.id,
          symbol: h.symbol,
          name: bySymbol[h.symbol]?.alias ?? (bySymbol[h.symbol]?.name.isNotEmpty == true ? bySymbol[h.symbol]!.name : h.symbol),
          ccy: h.ccy,
          shares: h.shares,
          costPrice: h.costPrice,
          costRate: h.costRate,
          lastPrice: quotes[h.symbol]?.price,
        ),
    ];
    final cashInputs = [
      for (final c in cash)
        CashInput(
          id: c.id,
          ccy: c.ccy,
          label: c.label.isEmpty ? c.ccy : c.label,
          kind: c.kind,
          amount: c.amount,
          costRate: c.costRate,
        ),
    ];

    final calc = PnlCalculator(baseCcy: baseCcy, rateOf: _fx.rateOf);
    final summary = calc.summarize(inputs, cashInputs);

    return PortfolioBundle(
      summary: summary,
      quotes: quotes,
      rates: _fx.rates,
      updatedAt: await _quotes.lastUpdated(),
      failedSymbols: failed,
    );
  }
}
