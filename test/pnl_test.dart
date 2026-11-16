import 'package:dquote/core/pnl.dart';
import 'package:flutter_test/flutter_test.dart';

/// 損益是整個 app 最容易「算錯但看不出錯」的地方，所以每個數字都要對得起手算。
void main() {
  // 匯率表：1 USD = 32 TWD、1 JPY = 0.2 TWD、TWD = 1
  double? rate(String ccy) => switch (ccy) {
        'TWD' => 1,
        'USD' => 32,
        'JPY' => 0.2,
        _ => null,
      };
  final calc = PnlCalculator(baseCcy: 'TWD', rateOf: rate);

  PositionInput holding({
    String symbol = '2330.TW',
    String ccy = 'TWD',
    double shares = 1000,
    double cost = 500,
    double? last = 550,
    double? costRate,
  }) =>
      PositionInput(
        symbol: symbol,
        name: symbol,
        ccy: ccy,
        shares: shares,
        costPrice: cost,
        costRate: costRate,
        lastPrice: last,
      );

  group('台幣持股', () {
    test('基本損益：(550-500)×1000 = +50,000，匯兌 = 0', () {
      final p = calc.position(holding());
      expect(p.marketValueBase, 550000);
      expect(p.costBase, 500000);
      expect(p.pnlBase, closeTo(50000, 1e-9));
      expect(p.securitiesPnlBase, closeTo(50000, 1e-9));
      expect(p.fxPnlBase, 0);
      expect(p.pnlPct, closeTo(10, 1e-9));
      expect(p.included, isTrue);
    });

    test('虧損是負的，百分比以成本為基數', () {
      final p = calc.position(holding(last: 450));
      expect(p.pnlBase, closeTo(-50000, 1e-9));
      expect(p.pnlPct, closeTo(-10, 1e-9));
    });

    test('沒有報價 → 不計入總資產（要讓 UI 標示，不能靜態低估）', () {
      final p = calc.position(holding(last: null));
      expect(p.included, isFalse);
      expect(p.hasQuote, isFalse);
      expect(p.marketValueBase, 0);
    });

    test('股數 0 → 不炸、損益 0、百分比 null', () {
      final p = calc.position(holding(shares: 0));
      expect(p.pnlBase, 0);
      expect(p.pnlPct, isNull, reason: '成本 0 不能拿去當除數');
    });
  });

  group('美股持股的匯兌損益拆解', () {
    // 買進：10 股 @ 120 USD、當時 1 USD = 30 TWD → 成本 36,000 TWD
    // 現在：150.50 USD、1 USD = 32 TWD → 市值 48,160 TWD
    // 證券損益 = (150.5-120)×10×32 = 9,760
    // 匯兌損益 = 120×10×(32-30) = 2,400
    // 合計 = 12,160 = 48,160 - 36,000 ✓
    final input = const PositionInput(
      symbol: 'NVDA',
      name: 'NVIDIA',
      ccy: 'USD',
      shares: 10,
      costPrice: 120,
      costRate: 30,
      lastPrice: 150.5,
    );

    test('拆解後兩式相加必須恰好等於總損益', () {
      final p = calc.position(input);
      expect(p.costBase, closeTo(36000, 1e-6));
      expect(p.marketValueBase, closeTo(48160, 1e-6));
      expect(p.securitiesPnlBase, closeTo(9760, 1e-6));
      expect(p.fxPnlBase, closeTo(2400, 1e-6));
      expect(p.pnlBase, closeTo(p.securitiesPnlBase + p.fxPnlBase, 1e-6));
      expect(p.pnlBase, closeTo(12160, 1e-6));
    });

    test('匯率不變時匯兌損益為 0（不會憑空生出匯差）', () {
      final p = calc.position(const PositionInput(
          symbol: 'NVDA', name: 'n', ccy: 'USD', shares: 10, costPrice: 120, costRate: 32, lastPrice: 150.5));
      expect(p.fxPnlBase, closeTo(0, 1e-9));
      expect(p.pnlBase, closeTo(9760, 1e-6));
    });

    test('股價不動但美元變值錢 → 全部損益都來自匯兌', () {
      final p = calc.position(const PositionInput(
          symbol: 'NVDA', name: 'n', ccy: 'USD', shares: 10, costPrice: 120, costRate: 30, lastPrice: 120));
      expect(p.securitiesPnlBase, closeTo(0, 1e-9));
      expect(p.fxPnlBase, closeTo(2400, 1e-6));
      expect(p.pnlBase, closeTo(2400, 1e-6));
    });

    test('沒有買進匯率 → 退回現匯率，匯兌記 0（不硬猜）', () {
      final p = calc.position(const PositionInput(
          symbol: 'NVDA', name: 'n', ccy: 'USD', shares: 10, costPrice: 120, costRate: null, lastPrice: 150.5));
      expect(p.fxPnlBase, closeTo(0, 1e-9));
      expect(p.costBase, closeTo(38400, 1e-6));
    });

    test('沒有該幣別匯率 → 整筆排除，並記錄在 excludedSymbols', () {
      final s = calc.summarize([
        const PositionInput(symbol: 'XYZ', name: 'x', ccy: 'EUR', shares: 1, costPrice: 1, costRate: 1, lastPrice: 2),
      ], const []);
      expect(s.totalAssetsBase, 0);
      expect(s.excludedSymbols, contains('XYZ'));
    });
  });

  group('現金與外幣', () {
    test('台幣現金沒有匯兌損益', () {
      final c = calc.cash(const CashInput(ccy: 'TWD', label: '台銀', kind: 'bank', amount: 100000, costRate: null));
      expect(c.valueBase, 100000);
      expect(c.fxPnlBase, 0);
      expect(c.isForeign, isFalse);
    });

    test('外幣的損益全部來自匯差：3000 USD 從 31.2 → 32 → +2,400', () {
      final c = calc.cash(const CashInput(ccy: 'USD', label: '定存', kind: 'bank', amount: 3000, costRate: 31.2));
      expect(c.valueBase, closeTo(96000, 1e-6));
      expect(c.fxPnlBase, closeTo(2400, 1e-6));
      expect(c.isForeign, isTrue);
    });
  });

  group('總資產與配置', () {
    test('持股 + 外幣 + 現金 三塊相加，並各自算出權重', () {
      final s = calc.summarize([
        holding(), // 550,000
      ], [
        const CashInput(ccy: 'USD', label: '外幣', kind: 'bank', amount: 1000, costRate: 30), // 32,000
        const CashInput(ccy: 'TWD', label: '現金', kind: 'wallet', amount: 18000, costRate: null),
      ]);
      expect(s.positionsValueBase, closeTo(550000, 1e-6));
      expect(s.foreignCashValueBase, closeTo(32000, 1e-6));
      expect(s.baseCashValueBase, 18000);
      expect(s.totalAssetsBase, closeTo(600000, 1e-6));
      expect(s.holdingsWeight, closeTo(550000 / 600000, 1e-9));
      expect(s.cashWeight, closeTo(18000 / 600000, 1e-9));
    });

    test('券商現金才算可買力，銀行/手頭現金不算', () {
      final s = calc.summarize([], [
        const CashInput(ccy: 'TWD', label: '券商', kind: 'broker', amount: 45900, costRate: null),
        const CashInput(ccy: 'TWD', label: '錢包', kind: 'wallet', amount: 1000, costRate: null),
      ]);
      expect(s.buyingPowerBase, 45900);
    });

    test('單一持股超過 30% → 集中度警示抓得到', () {
      final s = calc.summarize([
        holding(symbol: '2330.TW'), // 550,000
        holding(symbol: '2317.TW', cost: 50, last: 55), // 55,000
      ], [
        const CashInput(ccy: 'TWD', label: '現金', kind: 'wallet', amount: 100000, costRate: null),
      ]);
      expect(s.concentratedSymbols(), contains('2330.TW'));
      expect(s.concentratedSymbols(), isNot(contains('2317.TW')));
    });

    test('空投資組合不炸（總資產 0、權重 0）', () {
      final s = calc.summarize([], []);
      expect(s.totalAssetsBase, 0);
      expect(s.holdingsWeight, 0);
      expect(s.pnlPct, isNull);
    });
  });

  group('可買力', () {
    final calc2 = PnlCalculator(baseCcy: 'TWD', rateOf: rate);
    test('台幣計價：45,900 買 2,295 的一張 → 20 股', () {
      expect(calc2.sharesAffordable(buyingPowerBase: 45900, price: 2295, ccy: 'TWD'), 20);
    });
    test('美元計價要先換算：32,000 TWD 買 50 USD（=1600 TWD）→ 20 股', () {
      expect(calc2.sharesAffordable(buyingPowerBase: 32000, price: 50, ccy: 'USD'), 20);
    });
    test('沒有報價或沒有匯率 → null，不假裝是 0', () {
      expect(calc2.sharesAffordable(buyingPowerBase: 32000, price: null, ccy: 'USD'), isNull);
      expect(calc2.sharesAffordable(buyingPowerBase: 32000, price: 50, ccy: 'EUR'), isNull);
    });
  });
  group('合計拆解（含外幣現金）', () {
    // 卡面上「證券 + 匯兌 = 合計」三個數字要對得起來。
    // 外幣現金的匯差以前只進匯兌、不進合計，會變成「+50,000 / +6,000 / +50,000」。
    test('證券 + 匯兌 == 合計，外幣現金的匯差也要算進去', () {
      final s = calc.summarize([
        holding(), // TWD 持股 +50,000
      ], [
        const CashInput(ccy: 'USD', label: '外幣', kind: 'bank', amount: 3000, costRate: 30), // 30 → 32
        const CashInput(ccy: 'TWD', label: '現金', kind: 'wallet', amount: 50000, costRate: null),
      ]);
      expect(s.securitiesPnlBase, closeTo(50000, 1e-6));
      expect(s.fxPnlBase, closeTo(6000, 1e-6));
      expect(s.securitiesPnlBase + s.fxPnlBase, closeTo(s.pnlBase, 1e-6),
          reason: '三個數字加不起來就是合計沒把現金匯差算進去');
      expect(s.pnlBase, closeTo(56000, 1e-6));
      // 分母只算會產生損益的部位：持股 + 外幣現金；台幣現金是支付工具
      expect(s.costBase, closeTo(500000 + 3000 * 30, 1e-6));
      expect(s.pnlPct, closeTo(56000 / 590000 * 100, 1e-9));
    });
  });

}
