/// 損益計算 —— 整個 app 的價值核心，也是唯一「算錯就會誤導決策」的地方，
/// 所以做成**純 Dart**（不碰資料庫、不碰網路、不碰 Flutter），在 test/pnl_test.dart 裡
/// 用「手算對得起來」的數字驗。
///
/// ## 匯兌損益怎麼拆
/// 以基礎貨幣（TWD）計價時，一檔持股的損益可以**精確**拆成兩塊：
///
/// ```
/// 損益(基礎幣) = (現價 − 成本) × 股數 × 現匯率   ← 證券損益（股價貢獻，以現匯率折台）
///              + 成本 × 股數 × (現匯率 − 買進匯率) ← 匯兌損益（匯率貢獻）
/// ```
/// 兩式相加恰好等於 `市值(基礎幣) − 成本(基礎幣)`，所以「合計」不會對不起來。
/// 台幣持股匯率恆為 1 → 匯兌損益自然為 0。
///
/// ## 現金怎麼算進合計
/// 只有**會產生損益的部位**進入損益與成本：持股與外幣現金。台幣現金是支付工具
/// （`costRate` null → 匯兌恆為 0），所以它的成本與損益都不計 —— 否則一大筆閒置台幣
/// 現金會把「報酬率」稀釋掉，停損提醒就永遠不會觸發。契約：
/// `securitiesPnlBase + fxPnlBase == pnlBase`，`pnlPct == pnlBase / costBase`。
library;

/// 持股輸入（由資料庫 row + 即時報價湊出來，這裡只吃純資料）。
class PositionInput {
  const PositionInput({
    this.id,
    required this.symbol,
    required this.name,
    required this.ccy,
    required this.shares,
    required this.costPrice,
    required this.costRate,
    required this.lastPrice,
  });

  /// Holdings 表的列 id。同一檔可以買兩次（兩筆列），**編輯／刪除一定要靠它**，
  /// 用 symbol 反查會改到另一筆。由呼叫端（PortfolioService）填。
  final int? id;
  final String symbol;
  final String name;
  final String ccy;
  final double shares;
  final double costPrice;

  /// 買進時「1 ccy = ? 基礎貨幣」；null → 沒有資料，退回用現匯率（此時匯兌損益為 0）。
  final double? costRate;
  final double? lastPrice; // null → 無報價
}

class CashInput {
  const CashInput({
    this.id,
    required this.ccy,
    required this.label,
    required this.kind,
    required this.amount,
    required this.costRate,
  });

  /// CashPositions 表的列 id（同上：識別靠它，不靠 ccy+label）。
  final int? id;
  final String ccy;
  final String label;
  final String kind; // broker | bank | wallet
  final double amount;

  /// 取得時「1 ccy = ? 基礎貨幣」；null → 退回現匯率（本幣現金恒為 0 損益）。
  final double? costRate;
}

class PositionPnl {
  const PositionPnl({
    this.id,
    required this.symbol,
    required this.name,
    required this.ccy,
    required this.shares,
    required this.costPrice,
    required this.lastPrice,
    required this.marketValueBase,
    required this.costBase,
    required this.pnlBase,
    required this.securitiesPnlBase,
    required this.fxPnlBase,
    required this.pnlPct,
    required this.hasQuote,
    required this.hasRate,
  });

  final int? id;
  final String symbol, name, ccy;
  final double shares, costPrice;
  final double? lastPrice;
  final double marketValueBase, costBase, pnlBase, securitiesPnlBase, fxPnlBase;
  final double? pnlPct;
  final bool hasQuote, hasRate;

  /// 沒有報價也沒有匯率時，這筆不能計入總資產（會低估，UI 要標示）。
  bool get included => hasQuote && hasRate;
}

class CashPnl {
  const CashPnl({
    this.id,
    required this.ccy,
    required this.label,
    required this.kind,
    required this.amount,
    required this.valueBase,
    required this.costBase,
    required this.fxPnlBase,
    required this.hasRate,
    required this.isForeign,
  });

  final int? id;
  final String ccy, label, kind;
  final double amount, valueBase, costBase, fxPnlBase;
  final bool hasRate;

  /// 是否為外幣（基礎貨幣以外）→ UI 決定要不要顯示匯兌損益。
  final bool isForeign;

  bool get included => hasRate;
}

class PortfolioSummary {
  const PortfolioSummary({
    required this.positionsValueBase,
    required this.foreignCashValueBase,
    required this.baseCashValueBase,
    required this.totalAssetsBase,
    required this.costBase,
    required this.pnlBase,
    required this.securitiesPnlBase,
    required this.fxPnlBase,
    required this.pnlPct,
    required this.buyingPowerBase,
    required this.excludedSymbols,
    required this.positions,
    required this.cashes,
  });

  final double positionsValueBase;
  final double foreignCashValueBase;
  final double baseCashValueBase;
  final double totalAssetsBase;
  /// 會產生損益的部位之成本（持股 + 外幣現金；台幣現金不算）
  final double costBase;
  final double pnlBase;

  /// 損益拆解：`securitiesPnlBase + fxPnlBase == pnlBase`
  final double securitiesPnlBase, fxPnlBase;

  /// `pnlBase / costBase * 100`；沒有可計算成本的部位 → null
  final double? pnlPct;

  /// 券商帳戶的可用資金（`kind == 'broker'` 的現金合計，基礎幣）
  final double buyingPowerBase;

  /// 因為沒報價／沒匯率而被排除出總資產的代號（UI 必須標示，不能靜態低估資產）
  final List<String> excludedSymbols;
  final List<PositionPnl> positions;
  final List<CashPnl> cashes;

  double get holdingsWeight => totalAssetsBase == 0 ? 0 : positionsValueBase / totalAssetsBase;
  double get foreignCashWeight =>
      totalAssetsBase == 0 ? 0 : foreignCashValueBase / totalAssetsBase;
  double get cashWeight => totalAssetsBase == 0 ? 0 : baseCashValueBase / totalAssetsBase;

  /// 單一持股佔總資產超過這個比例就該警示（集中度）。
  static const concentrationWarn = 0.30;

  List<String> concentratedSymbols() => [
        for (final p in positions)
          if (included(p) && totalAssetsBase > 0 &&
              p.marketValueBase / totalAssetsBase > concentrationWarn)
            p.symbol,
      ];

  static bool included(PositionPnl p) => p.included;
}

class PnlCalculator {
  const PnlCalculator({required this.baseCcy, required this.rateOf});

  final String baseCcy;

  /// 每 1 個 ccy = ? 基礎貨幣。基礎貨幣本身恒為 1。
  final double? Function(String ccy) rateOf;

  bool _isBase(String ccy) => ccy.toUpperCase() == baseCcy.toUpperCase();

  double? _rate(String ccy) => _isBase(ccy) ? 1 : rateOf(ccy);

  PositionPnl position(PositionInput i) {
    final rateNow = _rate(i.ccy);
    final hasRate = rateNow != null;
    final hasQuote = i.lastPrice != null;
    final rb = i.costRate ?? rateNow; // 沒有買進匯率 → 退回現匯率（匯兌損益 0）

    double costBase = 0, mvBase = 0, sec = 0, fx = 0, pnl = 0;
    double? pct;
    if (hasRate && hasQuote) {
      final rn = rateNow, l = i.lastPrice!;
      costBase = i.shares * i.costPrice * rb!;
      mvBase = i.shares * l * rn;
      sec = (l - i.costPrice) * i.shares * rn;
      fx = i.costPrice * i.shares * (rn - rb);
      pnl = mvBase - costBase; // == sec + fx
      if (costBase != 0) pct = pnl / costBase * 100;
    }

    return PositionPnl(
      id: i.id,
      symbol: i.symbol,
      name: i.name,
      ccy: i.ccy,
      shares: i.shares,
      costPrice: i.costPrice,
      lastPrice: i.lastPrice,
      marketValueBase: mvBase,
      costBase: costBase,
      pnlBase: pnl,
      securitiesPnlBase: sec,
      fxPnlBase: fx,
      pnlPct: pct,
      hasQuote: hasQuote,
      hasRate: hasRate,
    );
  }

  CashPnl cash(CashInput i) {
    final rateNow = _rate(i.ccy);
    final hasRate = rateNow != null;
    double valueBase = 0, costBase = 0, fx = 0;
    if (hasRate) {
      final rn = rateNow;
      final rb = i.costRate ?? rn;
      valueBase = i.amount * rn;
      costBase = i.amount * rb;
      fx = valueBase - costBase;
    }
    return CashPnl(
      id: i.id,
      ccy: i.ccy,
      label: i.label,
      kind: i.kind,
      amount: i.amount,
      valueBase: valueBase,
      costBase: costBase,
      fxPnlBase: fx,
      hasRate: hasRate,
      isForeign: !_isBase(i.ccy),
    );
  }

  PortfolioSummary summarize(List<PositionInput> positions, List<CashInput> cashes) {
    final ps = [for (final p in positions) position(p)];
    final cs = [for (final c in cashes) cash(c)];

    double mv = 0, cost = 0, pnl = 0, sec = 0, fx = 0, fxCash = 0, baseCash = 0, buying = 0;
    final excluded = <String>[];

    for (final p in ps) {
      if (!p.included) {
        excluded.add(p.symbol);
        continue;
      }
      mv += p.marketValueBase;
      cost += p.costBase;
      pnl += p.pnlBase;
      sec += p.securitiesPnlBase;
      fx += p.fxPnlBase;
    }
    for (final c in cs) {
      if (!c.included) {
        excluded.add('${c.ccy}:${c.label}');
        continue;
      }
      if (_isBase(c.ccy)) {
        baseCash += c.valueBase;
      } else {
        fxCash += c.valueBase;
        // 外幣現金的匯差也是損益，而且**要一起進合計**，否則卡面上「證券 + 匯兌 ≠ 合計」
        // （它的成本同時進分母，合計% 才是這塊部位的真實報酬率）。
        fx += c.fxPnlBase;
        pnl += c.fxPnlBase;
        cost += c.costBase;
      }
      if (c.kind == 'broker') buying += c.valueBase;
    }

    final total = mv + fxCash + baseCash;
    return PortfolioSummary(
      positionsValueBase: mv,
      foreignCashValueBase: fxCash,
      baseCashValueBase: baseCash,
      totalAssetsBase: total,
      costBase: cost,
      pnlBase: pnl,
      securitiesPnlBase: sec,
      fxPnlBase: fx,
      pnlPct: cost == 0 ? null : pnl / cost * 100,
      buyingPowerBase: buying,
      excludedSymbols: excluded,
      positions: ps,
      cashes: cs,
    );
  }

  /// 可買力：以基礎貨幣表示「現在還買得起幾股」。
  /// 沒有報價或沒有匯率時回 null（不假設成 0，讓 UI 顯示 `—`）。
  int? sharesAffordable({required double buyingPowerBase, required double? price, required String ccy}) {
    if (price == null || price <= 0) return null;
    final fx = _isBase(ccy) ? 1.0 : rateOf(ccy);
    final inBase = fx == null ? null : price * fx;
    if (inBase == null || inBase <= 0) return null;
    return (buyingPowerBase / inBase).floor();
  }
}
