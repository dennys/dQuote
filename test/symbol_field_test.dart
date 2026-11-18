import 'package:dquote/data/db/database.dart';
import 'package:dquote/generated/l10n/app_localizations.dart';
import 'package:dquote/pages/symbol_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 「代號可以用選的」這顆欄位。頁面那端的接線（自選股 → options）由 `app_smoke_test.dart`
/// 從新增持股的入口走一次；這裡只驗欄位本身的兩條判斷：清單選完會填回欄位、沒清單時不給按鈕。
Widget wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  group('symbolOptionsOf', () {
    test('使用者自己取的別名優先，沒別名才用來源名稱', () {
      final opts = symbolOptionsOf([
        const Instrument(
            symbol: '2330.TW',
            name: 'Taiwan Semiconductor Manufacturing Company',
            alias: '台積電',
            currency: 'TWD',
            market: 'taiwan',
            sortOrder: 1,
            inWidget: false),
        const Instrument(symbol: 'TSM', name: 'TSMC ADR', currency: 'USD', market: 'america', sortOrder: 2, inWidget: false),
      ]);
      expect(opts['2330.TW'], '台積電');
      expect(opts['TSM'], 'TSMC ADR');
    });
  });

  group('SymbolField', () {
    testWidgets('按按鈕開清單 → 選一個就把代號填進欄位（名稱排前面）', (tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(wrap(SymbolField(
        controller: ctrl,
        labelText: 'Symbol',
        options: const {'2330.TW': '台積電', 'TSM': ''},
      )));

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();
      expect(find.text('台積電'), findsOneWidget, reason: '清單要用名稱當主標題');
      // 沒有名稱的項目：主標題與副標都退回代號（所以是兩處，不是錯事）。
      expect(find.text('TSM'), findsWidgets);

      await tester.tap(find.text('台積電'));
      await tester.pumpAndSettle();
      expect(ctrl.text, '2330.TW', reason: '按下去要填的是代號，不是名稱');
    });

    testWidgets('清單是空的 → 不給按鈕（退回純手打，別給使用者開空白清單）', (tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(wrap(SymbolField(controller: ctrl, options: const {})));
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });
  });
}
