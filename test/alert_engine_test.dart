import 'package:dquote/core/alerts.dart';
import 'package:dquote/core/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// re-arm 去重是提醒系統的好壞分水嶺：價格在門檻上下跳動時，
/// 「每 15 分鐘轟一次」和「只在突破時轟一次」是兩種完全不同的產品。
/// 狀態機的外部記憶：alertId → 是否武裝。測試自己管這個狀態，
/// 等於把 AlertRepository 的角色在測試裡重演一遍（真實實作讀 AlertLogs）。
class Armed {
  final map = <int, bool>{};
  bool of(int id) => map[id] ?? true;
  void apply(List<AlertDecision> decisions) {
    for (final d in decisions) {
      map[d.rule.id] = d.isClear; // fire → 解除武裝；clear → 重新武裝
    }
  }
}

void main() {
  const engine = AlertEngine();

  List<AlertDecision> run(List<AlertRule> rules, AlertInputs inputs, Armed armed) {
    final d = engine.evaluate(rules: rules, inputs: inputs, armedOf: armed.of);
    armed.apply(d);
    return d;
  }

  group('價格上穿', () {
    final rules = [rule(AlertKind.above, symbol: '2330.TW', threshold: 2400)];

    test('突破門檻 → 觸發一次', () {
      final armed = Armed();
      final d = run(rules, AlertInputs(quotes: {'2330.TW': quoteOf('2330.TW', 2415, prev: 2400)}), armed);
      expect(d.where((e) => e.isClear == false).length, 1);
      expect(armed.of(1), isFalse, reason: '觸發後必須解除武裝');
    });

    test('條件仍成立時**不重複發**（這是最重要的一條）', () {
      final armed = Armed();
      final q = {'2330.TW': quoteOf('2330.TW', 2415, prev: 2400)};
      run(rules, AlertInputs(quotes: q), armed);
      final again = run(rules, AlertInputs(quotes: q), armed);
      expect(again, isEmpty, reason: '還在門檻上就不該再打擾使用者');
    });

    test('跌回門檻下 → 發出 clear（重新武裝），再突破才會又發', () {
      final armed = Armed();
      run(rules, AlertInputs(quotes: {'2330.TW': quoteOf('2330.TW', 2415, prev: 2400)}), armed);
      final cleared = run(rules, AlertInputs(quotes: {'2330.TW': quoteOf('2330.TW', 2380, prev: 2400)}), armed);
      expect(cleared.where((e) => e.isClear).length, 1);
      expect(armed.of(1), isTrue);
      final refire = run(rules, AlertInputs(quotes: {'2330.TW': quoteOf('2330.TW', 2402, prev: 2400)}), armed);
      expect(refire.where((e) => !e.isClear).length, 1);
    });

    test('剛好等於門檻也算觸發（>= 不是 >）', () {
      final armed = Armed();
      final d = run(rules, AlertInputs(quotes: {'2330.TW': quoteOf('2330.TW', 2400, prev: 2400)}), armed);
      expect(d.where((e) => !e.isClear).length, 1);
    });
  });

  group('資料不足時不判斷、也不清除狀態', () {
    test('查不到報價 → 完全沒有決定（不會誤判成「已回到門檻下」而重新武裝）', () {
      final armed = Armed()..map[1] = false;
      final d = engine.evaluate(
          rules: [rule(AlertKind.above, symbol: 'XYZ', threshold: 1)],
          inputs: const AlertInputs(quotes: {}),
          armedOf: armed.of);
      expect(d, isEmpty);
      expect(armed.of(1), isFalse, reason: '狀態必須維持，不能因為拿不到資料就重置');
    });
  });

  group('單日漲跌幅', () {
    final rules = [rule(AlertKind.dayChange, symbol: '2330.TW', threshold: 5)];
    test('漲超过 5% 觸發', () {
      final armed = Armed();
      final d = run(rules, AlertInputs(quotes: {'2330.TW': quoteOf('2330.TW', 1050, prev: 1000)}), armed);
      expect(d.where((e) => !e.isClear).length, 1);
    });
    test('跌超过 5% 也算（取絕對值）', () {
      final armed = Armed();
      final d = run(rules, AlertInputs(quotes: {'2330.TW': quoteOf('2330.TW', 940, prev: 1000)}), armed);
      expect(d.where((e) => !e.isClear).length, 1);
    });
    test('4.9% 不觸發', () {
      final armed = Armed();
      final d = run(rules, AlertInputs(quotes: {'2330.TW': quoteOf('2330.TW', 1049, prev: 1000)}), armed);
      expect(d.where((e) => !e.isClear), isEmpty);
    });
  });

  group('持股損益提醒', () {
    test('門檻為正 → 獲利達標才發', () {
      final armed = Armed();
      final r = [rule(AlertKind.pnl, symbol: '2330.TW', threshold: 20)];
      expect(run(r, const AlertInputs(positionPnlPct: {'2330.TW': 19}), armed), isEmpty);
      final d = run(r, const AlertInputs(positionPnlPct: {'2330.TW': 21}), armed);
      expect(d.where((e) => !e.isClear).length, 1);
    });

    test('門檻為負 → 是「跌破」而不是「漲破」（停損不能反算）', () {
      final armed = Armed();
      final r = [rule(AlertKind.pnl, symbol: '2330.TW', threshold: -15)];
      expect(run(r, const AlertInputs(positionPnlPct: {'2330.TW': 50}), armed), isEmpty);
      final d = run(r, const AlertInputs(positionPnlPct: {'2330.TW': -16}), armed);
      expect(d.where((e) => !e.isClear).length, 1);
    });

    test('scope = portfolio 用整體損益', () {
      final armed = Armed();
      final r = [rule(AlertKind.pnl, threshold: 10, scope: AlertScope.portfolio)];
      expect(run(r, const AlertInputs(quotes: {}, portfolioPnlPct: 9), armed), isEmpty);
      expect(run(r, const AlertInputs(quotes: {}, portfolioPnlPct: 11), armed).where((e) => !e.isClear).length, 1);
    });
  });

  group('匯率突破', () {
    test('門檻為正 → 突破上緣', () {
      final armed = Armed();
      final r = [rule(AlertKind.fx, symbol: 'USDTWD=X', threshold: 33)];
      expect(run(r, AlertInputs(quotes: {'USDTWD=X': quoteOf('USDTWD=X', 32.9, ccy: 'TWD', market: Market.fx)}), armed),
          isEmpty);
      expect(
          run(r, AlertInputs(quotes: {'USDTWD=X': quoteOf('USDTWD=X', 33.1, ccy: 'TWD', market: Market.fx)}), armed)
              .where((e) => !e.isClear)
              .length,
          1);
    });
  });

  group('開關與種類', () {
    test('enabled = false 的規則完全不理', () {
      const engine = AlertEngine();
      final d = engine.evaluate(
        rules: [rule(AlertKind.above, symbol: '2330.TW', threshold: 1, enabled: false)],
        inputs: AlertInputs(quotes: {'2330.TW': quoteOf('2330.TW', 9999)}),
        armedOf: (_) => true,
      );
      expect(d, isEmpty);
    });

    test('closingDigest 不由引擎評估（由心跳按日報時窗處理）', () {
      const engine = AlertEngine();
      final d = engine.evaluate(
        rules: [rule(AlertKind.closingDigest)],
        inputs: AlertInputs(quotes: {'2330.TW': quoteOf('2330.TW', 9999)}),
        armedOf: (_) => true,
      );
      expect(d, isEmpty);
    });
  });
}
