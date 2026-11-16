/// 提醒規則的判定 —— **純 Dart**，re-arm 去重的狀態由呼叫端（AlertRepository）供給，
/// 所以整個狀態機可以在 test/alert_engine_test.dart 裡跑完，不需要通知外掛。
library;

import 'models.dart';

enum AlertKind { closingDigest, above, below, dayChange, pnl, fx }

enum AlertScope { single, portfolio }

/// 一條提醒規則（資料庫 row 的純資料視圖）。
class AlertRule {
  const AlertRule({
    required this.id,
    required this.kind,
    required this.scope,
    this.symbol,
    this.threshold,
    this.enabled = true,
    this.note,
  });

  final int id;
  final AlertKind kind;
  final AlertScope scope;
  final String? symbol;
  final double? threshold;
  final bool enabled;
  final String? note;
}

class AlertDecision {
  const AlertDecision.fire(this.rule, this.value) : isClear = false;
  const AlertDecision.clear(this.rule, this.value) : isClear = true;

  final AlertRule rule;

  /// 觸發當下用的數值（寫進 AlertLog，給「通知歷史」顯示）
  final double? value;
  final bool isClear;
}

class AlertInputs {
  const AlertInputs({
    this.quotes = const {},
    this.positionPnlPct = const {},
    this.portfolioPnlPct,
  });

  /// symbol → 最新報價
  final Map<String, Quote> quotes;

  /// symbol → 該筆持股的損益百分比（由 PnlCalculator 算好送進來；引擎自己不算損益）
  final Map<String, double> positionPnlPct;

  /// 整個投資組合的損益百分比（scope = portfolio 用）
  final double? portfolioPnlPct;
}

class AlertEngine {
  const AlertEngine();

  /// [armedOf] 回傳「這條規則現在能不能發」——re-arm 語意：
  /// 條件成立期間**不重複發**，必須先回到未成立（發出 clear）才會重新武裝。
  /// 這跟券商 App 的慣例一致，否則價格在門檻上下跳動時會每 15 分鐘轟一次。
  List<AlertDecision> evaluate({
    required List<AlertRule> rules,
    required AlertInputs inputs,
    required bool Function(int alertId) armedOf,
  }) {
    final out = <AlertDecision>[];
    for (final r in rules) {
      if (!r.enabled || r.kind == AlertKind.closingDigest) continue;
      final hit = _valueAndHit(r, inputs);
      if (hit == null) continue; // 資料不足（無報價）→ 不判斷，也不清除狀態
      final (value, satisfied) = hit;
      if (satisfied) {
        if (armedOf(r.id)) out.add(AlertDecision.fire(r, value));
      } else if (!armedOf(r.id)) {
        out.add(AlertDecision.clear(r, value));
      }
    }
    return out;
  }

  /// (當下數值, 是否成立)。回 null = 資料不足，跳過這條。
  (double, bool)? _valueAndHit(AlertRule r, AlertInputs inputs) {
    final t = r.threshold;
    switch (r.kind) {
      case AlertKind.above:
      case AlertKind.below:
      case AlertKind.fx:
        final q = r.symbol == null ? null : inputs.quotes[r.symbol];
        if (q == null || t == null) return null;
        // fx 只是 UI 上的預設（對象是匯率這檔「商品」），判定跟 above/below 相同：
        // 門檻為正 → 突破上緣；為負 → 跌破下緣（取絕對值比）。
        if (r.kind == AlertKind.fx) {
          return (q.price, t >= 0 ? q.price >= t : q.price <= t.abs());
        }
        return (q.price, r.kind == AlertKind.above ? q.price >= t : q.price <= t);

      case AlertKind.dayChange:
        final pct = r.symbol == null ? null : inputs.quotes[r.symbol]?.changePct;
        if (pct == null || t == null) return null;
        return (pct, pct.abs() >= t.abs());

      case AlertKind.pnl:
        if (t == null) return null;
        final pct = r.scope == AlertScope.portfolio
            ? inputs.portfolioPnlPct
            : (r.symbol == null ? null : inputs.positionPnlPct[r.symbol]);
        if (pct == null) return null;
        // 門檻正數 → 獲利警示（≥）；負數 → 虧損/停損警示（≤）
        return (pct, t >= 0 ? pct >= t : pct <= t);

      case AlertKind.closingDigest:
        return null;
    }
  }
}
