import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../app.dart' show SettingsController;
import '../domain/fx_service.dart';
import 'models.dart';
import 'money.dart';

/// 取得目前設定的金額格式化器。**頁面一律用這支**，不要自己 new MoneyFormatter，
/// 否則「切換基礎貨幣」這種需求來了就會到处漏。
MoneyFormatter moneyFormatter(BuildContext context) {
  final base = context.select<SettingsController, String>((s) => s.baseCcy);
  // 用 select 而不是 `getIt<...>().fx.rates`：匯率晚到時這一頁要自己重畫。
  final rates = context.select<FxService, Map<String, double>>((f) => f.snapshot);
  return MoneyFormatter(baseCcy: base, rateOf: (c) => rates[c] ?? (c == base ? 1 : null));
}

/// 漲跌文字：`+15.00 (+0.63%)`。絕對值用報價幣別的小數位（匯率 4 位，其餘 2 位）。
/// 沒有前收盤價時回空字串。
String quoteChangeText(MoneyFormatter fmt, Quote q) {
  final change = q.change;
  final pct = q.changePct;
  if (change == null || pct == null) return '';
  final decimals = q.market == Market.fx ? 4 : 2;
  return '${fmt.signed(change, q.currency, decimals: decimals, withSymbol: false)} (${fmt.pct(pct)})';
}
