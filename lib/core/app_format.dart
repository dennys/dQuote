import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../app.dart' show SettingsController;
import '../di.dart';
import 'money.dart';

/// 取得目前設定的金額格式化器。**頁面一律用這支**，不要自己 new MoneyFormatter，
/// 否則「切換基礎貨幣」這種需求來了就會到处漏。
MoneyFormatter moneyFormatter(BuildContext context) {
  final base = context.select<SettingsController, String>((s) => s.baseCcy);
  final rates = getIt<AppContainer>().fx.rates;
  return MoneyFormatter(baseCcy: base, rateOf: (c) => rates[c] ?? (c == base ? 1 : null));
}
