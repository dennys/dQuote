import 'package:dquote/core/models.dart';
import 'package:dquote/core/money.dart';
import 'package:dquote/core/pnl.dart';
import 'package:dquote/core/widget_data.dart';
import 'package:dquote/domain/digest_text.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Flutter ↔ 原生桌面小工具的契約。這一組測試的價值不在「測到 bug」，
/// 而是**強迫任何對欄位的修改都要經過測試**，避免哪天改壞了 Kotlin 端才發現。
void main() {
  group('payload 契約', () {
    final payload = const WidgetPayload(updatedAt: 1700000000, baseCcy: 'TWD', redIsUp: true, rows: [
      WidgetRow(symbol: '2330.TW', name: '台積電', price: 2415, change: 15, changePct: 0.62, currency: 'TWD', market: Market.taiwan),
      WidgetRow(symbol: 'TSM', name: 'TSMC', price: 400, change: -2, changePct: -0.5, currency: 'USD', market: Market.america),
    ]);

    test('encode → decode 不失真（Kotlin 讀的就是這份 JSON）', () {
      final json = payload.encode();
      final back = WidgetPayload.decode(json);
      expect(back.updatedAt, 1700000000);
      expect(back.baseCcy, 'TWD');
      expect(back.rows.map((r) => r.symbol), ['2330.TW', 'TSM']);
      expect(back.rows.first.price, 2415);
      expect(back.rows.last.changePct, -0.5);
      expect(back.redIsUp, isTrue);
    });

    test('red_is_up 會帶過去（小工具跟 app 不同色就是這裡斷了）', () {
      const green = WidgetPayload(
          updatedAt: 1,
          baseCcy: 'TWD',
          redIsUp: false,
          rows: [WidgetRow(symbol: 'A', name: 'A', price: 1, change: 1, changePct: 1, currency: 'TWD', market: Market.taiwan)]);
      expect(green.encode(), contains('"red_is_up":false'));
      expect(WidgetPayload.decode(green.encode()).redIsUp, isFalse);
      // 舊 payload（沒這個欄位）→ 預設紅漲，不能變成緑漲
      expect(WidgetPayload.decode('{"rows":[]}').redIsUp, isTrue);
    });

    test('欄位名稱是固定的那几个（改名字會壞了原生端，要有測試擋住）', () {
      expect(payload.encode(), contains('"updated_at"'));
      expect(payload.encode(), contains('"base_ccy"'));
      expect(payload.encode(), contains('"chg_pct"'));
      expect(payload.encode(), contains('"market"'));
    });

    test('缺欄位時 decode 不會炸（舊版小工具讀新版 / 新版讀舊檔）', () {
      final back = WidgetPayload.decode('{"rows":[{"symbol":"2330.TW","price":1}]}');
      expect(back.updatedAt, 0);
      expect(back.baseCcy, 'TWD');
      expect(back.rows.single.name, '');
      expect(back.rows.single.changePct, isNull);
    });

    test('key 名稱固定', () {
      expect(WidgetContract.quotesKey, 'quotes');
    });
  });

  group('日報排行', () {
    final rows = [
      const WidgetRow(symbol: 'A', name: 'A', price: 1, change: 5, changePct: 5, currency: 'TWD', market: Market.taiwan),
      const WidgetRow(symbol: 'B', name: 'B', price: 1, change: -3, changePct: -3, currency: 'TWD', market: Market.taiwan),
      const WidgetRow(symbol: 'C', name: 'C', price: 1, change: 9, changePct: 9, currency: 'TWD', market: Market.taiwan),
      const WidgetRow(symbol: 'D', name: 'D', price: 1, change: null, changePct: null, currency: 'TWD', market: Market.taiwan),
    ];

    test('漲價前由大到小、最多 3 筆，沒有漲跌幅的排除', () {
      expect(ClosingDigest.rank(rows, up: true).map((r) => r.symbol), ['C', 'A', 'B']);
    });

    test('跌價前由小到大', () {
      expect(ClosingDigest.rank(rows, up: false).map((r) => r.symbol), ['B', 'A', 'C']);
    });

    test('全部沒有漲跌幅 → 空清單（日報不會出現一排「null%」）', () {
      expect(ClosingDigest.rank([rows.last], up: true), isEmpty);
    });
  });

  group('日報文案', () {
    test('包含總資產、損益、排行與更新時間（背景通知沒有 l10n，靠這份組裝）', () {
      const calc = PnlCalculator(baseCcy: 'TWD', rateOf: _rate);
      final summary = calc.summarize([
        const PositionInput(symbol: '2330.TW', name: '台積電', ccy: 'TWD', shares: 1000, costPrice: 500, costRate: 1, lastPrice: 550),
      ], []);
      final digest = ClosingDigest(
        market: 'TW',
        tradingDate: '2026-11-20',
        summary: summary,
        gainers: [
          const WidgetRow(symbol: '2330.TW', name: '台積電', price: 550, change: 50, changePct: 10, currency: 'TWD', market: Market.taiwan),
        ],
        losers: const [],
        indexQuote: quoteOf('^TWII', 41779, prev: 41000),
      );
      final text = buildDigestText(
          digest, zhStrings, const MoneyFormatter(baseCcy: 'TWD', rateOf: _rate), DateTime(2026, 11, 20, 13, 40));

      expect(text.title, '台股收盤');
      expect(text.body, contains('總資產'));
      expect(text.body, contains('NT\$550,000'));
      expect(text.body, contains('台積電'));
      expect(text.body, contains('+10.00%'));
      expect(text.body, contains('更新於 13:40'));
    });

    test('排行榜一檔一行（通知裡三檔擠一行會分不出邊界）', () {
      const calc = PnlCalculator(baseCcy: 'TWD', rateOf: _rate);
      final digest = ClosingDigest(
        market: 'TW',
        tradingDate: '2026-11-20',
        summary: calc.summarize([], []),
        gainers: const [
          WidgetRow(symbol: '2330.TW', name: '台積電', price: 550, change: 50, changePct: 10, currency: 'TWD', market: Market.taiwan),
          WidgetRow(symbol: '2317.TW', name: '鴻海', price: 100, change: 2, changePct: 2.04, currency: 'TWD', market: Market.taiwan),
        ],
        losers: const [],
        indexQuote: null,
      );
      final lines = buildDigestText(digest, zhStrings, const MoneyFormatter(baseCcy: 'TWD', rateOf: _rate), null)
          .body
          .split('\n');
      expect(lines, containsAllInOrder(['漲幅前 3', '台積電 +10.00%', '鴻海 +2.04%']));
    });
  });

  group('小工具格式契约', () {
    test('價格小數位與 app 同一條規則（DquoteWidget.kt 的 price() 照這張表實作）', () {
      const fmt = MoneyFormatter(baseCcy: 'TWD', rateOf: _rate);
      String price(double v, String ccy, Market m) =>
          fmt.amount(v, ccy, decimals: m == Market.fx ? 3 : null, withSymbol: false);

      expect(price(215, 'TWD', Market.taiwan), '215.00');
      expect(price(215.5, 'TWD', Market.taiwan), '215.50');
      expect(price(23456, 'TWD', Market.taiwan), '23,456', reason: '≥1000 的整數不補 .00');
      expect(price(400, 'USD', Market.america), '400.00');
      expect(price(32.9, 'TWD', Market.fx), '32.900', reason: '匯率固定 3 位');
      expect(price(0.2043, 'TWD', Market.fx), '0.2043', reason: '小於 1 給 4 位');
      expect(price(0.2043, 'JPY', Market.america), '0.2043', reason: '小於 1 的判斷要在零小幣別之前');
      expect(price(1200, 'JPY', Market.america), '1,200', reason: '零小幣別一律 0 位');
    });
  });
}

double? _rate(String ccy) => ccy == 'TWD' ? 1 : null;