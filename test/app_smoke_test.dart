import 'package:dquote/app.dart';
import 'package:dquote/core/models.dart';
import 'package:dquote/data/db/database.dart';
import 'package:dquote/data/repositories/portfolio_repository.dart';
import 'package:dquote/di.dart';
import 'package:dquote/pages/alerts_page.dart';
import 'package:dquote/pages/portfolio_page.dart';
import 'package:dquote/pages/quote_detail_page.dart';
import 'package:dquote/pages/settings_page.dart';
import 'package:dquote/pages/watchlist_page.dart';
import 'package:dquote/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// UI 冒煙測試：**不是**驗收畫面好不好看，而是「這五個分頁在真機上會不會一開就紅」。
///
/// 目前還沒上過真機，而 build 方法裡的空殼（例如 `!`、`late`、l10n 少鍵、drift 流還沒回來時
/// 存取 null）在 `flutter analyze` 是查不出來的 —— 只有在真的 pump 過一次才會炸。
/// 所以這裡把五個分頁、個股頁、設定頁都走一遍，並檢查 `takeException()`。
void main() {
  late AppDatabase db;
  late FakeQuoteSource source;
  late FakeNotificationGateway notif;
  late FakeWidgetBridge widgetBridge;

  setUp(() async {
    getIt.reset();
    db = AppDatabase.memory();
    notif = FakeNotificationGateway();
    widgetBridge = FakeWidgetBridge();
    source = FakeQuoteSource({
      '2330.TW': quoteOf('2330.TW', 2415, prev: 2400, name: '台積電'),
      '0050.TW': quoteOf('0050.TW', 105, prev: 100, name: '元大台灣50'),
      'TSM': quoteOf('TSM', 400, prev: 390, ccy: 'USD', market: Market.america, name: 'TSMC ADR'),
      'NVDA': quoteOf('NVDA', 180, prev: 175, ccy: 'USD', market: Market.america, name: 'NVIDIA'),
      'USDTWD=X': quoteOf('USDTWD=X', 32.9, prev: 32.8, market: Market.fx, name: 'USD/TWD'),
      '^TWII': quoteOf('^TWII', 22800, prev: 22700, market: Market.stockIndex, name: '加權指數'),
    });
    // 部位與現金：讓持股頁真的有數字可算（空白頁測不到 MoneyFormatter 那條路）。
    // **同一個 db instance 傳給 container**——記憶體庫每次 new 都是新的一間。
    final portfolio = PortfolioRepository(db);
    await portfolio.addHolding(symbol: '2330.TW', market: 'taiwan', ccy: 'TWD', shares: 1000, costPrice: 500, costRate: 1);
    await portfolio.addCash(ccy: 'USD', amount: 3000, costRate: 30.5, kind: 'cash');
  });

  /// loader 會轉，`pumpAndSettle` 會等到 timeout；改用固定幾拍的推進。
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  /// 收工。**先把 tree 卸掉再結束**：drift 的 StreamQueryStore 在 StreamBuilder dispose 時會
  /// 排一個 0ms 的延遲關閉 timer，留著它 widget test 會報「Pending timers」而紅。
  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> pumpApp(WidgetTester tester, {String initialRoute = '/'}) async {
    final container = await AppContainer.create(
      db: db,
      quoteSource: source,
      notification: notif,
      widget: widgetBridge,
    );
    getIt.registerSingleton<AppContainer>(container);
    await tester.pumpWidget(DQuoteApp(initialRoute: initialRoute));
    await settle(tester);
  }

  tearDown(() async {
    getIt.reset();
    await db.close();
  });

  testWidgets('啟動：三個分頁都渲染得出來，且沒有未捕獲例外', (tester) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);

    // IndexedStack 不會把沒選到的分頁留在樹裡，所以**選到哪個就驗哪個**。
    final expected = <Type>[WatchlistPage, PortfolioPage, AlertsPage];
    for (var i = 0; i < expected.length; i++) {
      await tester.tap(find.byType(NavigationDestination).at(i));
      await settle(tester);
      expect(find.byType(expected[i]), findsWidgets, reason: '切到第 $i 個分頁後頁面沒出現');
      expect(tester.takeException(), isNull, reason: '切到第 $i 個分頁時炸了');
    }
    await finish(tester);
  });

  testWidgets('自選頁混排顯示台股／美股／匯率，漲跌同時有絕對值與百分比', (tester) async {
    await pumpApp(tester);
    expect(find.byKey(const ValueKey('2330.TW')), findsOneWidget);
    expect(find.byKey(const ValueKey('TSM')), findsOneWidget);
    expect(find.byKey(const ValueKey('USDTWD=X')), findsOneWidget);
    // 名稱走「自選股存的 name」（seedIfEmpty 給的是 TSMC），價格/漲跌幅走 MoneyFormatter ——
    // 這三樣一起出現才證明「報價有進到清單」，而不只是清單渲染出來。
    expect(find.textContaining('TSMC'), findsWidgets);
    expect(find.textContaining('2,415'), findsWidgets);
    expect(find.text('+15.00 (+0.63%)'), findsOneWidget);
    expect(find.text('+10.00 (+2.56%)'), findsOneWidget);
    // 匯率那列才是 `quoteChangeText` 多帶一個 decimals 參數的唯一理由（絕對值 4 位）。
    expect(find.text('+0.1000 (+0.30%)'), findsOneWidget, reason: '匯率絕對漲跌要用 4 位小數');
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('點自選股 → 個股走勢頁（含圖表）會渲染，返回也正常', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('2330.TW')));
    await settle(tester);
    expect(find.byType(QuoteDetailPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 換區間（1d → 1Y）：圖表資料來源是快取/假來源，不能卡住或炸
    final oneYear = find.textContaining('1Y');
    if (oneYear.evaluate().isNotEmpty) {
      await tester.tap(oneYear.first);
      await settle(tester);
      expect(tester.takeException(), isNull);
    }

    final back = find.byTooltip('Back') ;
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back.first);
      await settle(tester);
    }
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('長按自選股 → 進出桌面小工具；列數滿了要明說，不能假裝已加入', (tester) async {
    await pumpApp(tester);
    // seed 的前 4 档在小工具裡，滑桿預設 4 列 → 已經滿了。
    await tester.longPress(find.byKey(const ValueKey('NVDA')));
    await settle(tester);
    await tester.tap(find.descendant(
        of: find.byType(BottomSheet), matching: find.text('Add to home widget')));
    await settle(tester);
    expect(widgetBridge.lastPayload?.rows.map((r) => r.symbol), isNot(contains('NVDA')),
        reason: 'forWidget 照 sortOrder 截前 4 列，NVDA 排最後 → 不會出現在小工具');
    expect(find.textContaining('Home widget is full'), findsOneWidget,
        reason: '不能只給「已加入」，那會讓使用者以為按了沒效果');

    // 關掉一列 → 剛才被截掉的 NVDA 自動補上來（證明重發真的走到 WidgetBridge）。
    await tester.longPress(find.byKey(const ValueKey('2330.TW')));
    await settle(tester);
    await tester.tap(find.descendant(
        of: find.byType(BottomSheet), matching: find.text('Remove from home widget')));
    await settle(tester);
    expect(widgetBridge.lastPayload?.rows.map((r) => r.symbol), contains('NVDA'));
    // snackbar 是排隊的（上一條還在上面時新的不會插隊），所以得先讓它過場。
    await tester.pump(const Duration(seconds: 5));
    await settle(tester);
    expect(find.textContaining('Removed from home widget'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('長按自選股 → 改別名 → 各處改用別名顯示（代號不變）', (tester) async {
    await pumpApp(tester);
    await tester.longPress(find.byKey(const ValueKey('2330.TW')));
    await settle(tester);
    await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('Set alias')));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, '台積電');
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(find.text('台積電'), findsWidgets, reason: '標題换成使用者取的別名');
    expect(find.text('2330.TW'), findsWidgets, reason: '副標仍是代號 —— 別名只改顯示，不取代代號');
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('新增持股：代號可以從自選股選（不用手打 2330.TW 這種後綴）', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await settle(tester);
    await tester.tap(find.descendant(of: find.byType(PortfolioPage), matching: find.byIcon(Icons.add)));
    await settle(tester);
    await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('Add holding')));
    await settle(tester);
    await tester.tap(find.byIcon(Icons.expand_more));
    await settle(tester);
    await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('元大台灣50')));
    await settle(tester);
    final field = tester.widget<TextField>(
        find.ancestor(of: find.byIcon(Icons.expand_more), matching: find.byType(TextField)));
    expect(field.controller?.text, '0050.TW', reason: '清單按下去要填的是代號');
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('啟動時不問通知權限；進過提醒分頁才問（README 承諾的行為）', (tester) async {
    await pumpApp(tester);
    expect(notif.asked, 0,
        reason: '三個分頁一起建的話，AlertsPage.initState 會在使用者還站在自選頁時就把權限問掉；'
                '太早問會被拒得莫名其妙，而整個提醒功能全靠這個權限');

    await tester.tap(find.byType(NavigationDestination).at(2));
    await settle(tester);
    expect(notif.asked, greaterThan(0), reason: '真的進那頁才問');
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('左滑刪除自選股要立刻重發桌面小工具（不然那档會留在桌面上到下次心跳）', (tester) async {
    await pumpApp(tester);
    await tester.drag(find.byKey(const ValueKey('2330.TW')), const Offset(-600, 0));
    await settle(tester);
    expect(widgetBridge.lastPayload, isNotNull, reason: '刪除後要立刻發布一次，不是等 15 分鐘');
    expect(widgetBridge.lastPayload!.rows.map((r) => r.symbol), isNot(contains('2330.TW')));
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('持股頁真的有金額與損益數字（不是空白，也不是 NaN）', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await settle(tester);

    final text = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? '').join(' ');
    expect(text, contains('NT\$'), reason: '基礎幣金額要出現');
    expect(text, isNot(contains('NaN')));
    expect(text, isNot(contains('Infinity')));
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('deep link /portfolio 會直接落在持股分頁', (tester) async {
    await pumpApp(tester, initialRoute: '/portfolio');
    expect(find.byType(PortfolioPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('指數（加權指數）出現在台股分頁 —— 之前是哪個分頁都不顯示', (tester) async {
    await pumpApp(tester);
    // seed 進庫的 ^TWII 屬於 Market.stockIndex：沒有分頁歸屬規則時它「加了但看不到」
    expect(find.textContaining('加權指數'), findsWidgets);
    expect(find.byKey(const ValueKey('drag-^TWII')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('通知權限被拒時，提醒頁要明說「不會送達」並給重試（不要讓使用者自己猜）', (tester) async {
    notif.granted = false;
    await pumpApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(2));
    await settle(tester);
    expect(find.textContaining('Notifications are blocked'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('持股長按 → 編輯 → 改股數會寫回（加倉不必刪掉重填）', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await settle(tester);

    expect(find.textContaining('1000 Shares'), findsWidgets, reason: '進編輯前的股數');

    await tester.longPress(find.textContaining('TSMC').first);
    await settle(tester);
    await tester.tap(find.text('Edit'));
    await settle(tester);

    final sharesField = find.byType(TextField).at(1); // 代號 / 股數 / 成本
    expect(tester.widget<TextField>(sharesField).controller!.text, '1000',
        reason: '編輯一定要預填舊值，否則一按保存就變成空值/錯值');
    await tester.enterText(sharesField, '2000');
    await tester.tap(find.text('Save'));
    await settle(tester);

    expect(find.textContaining('2000 Shares'), findsWidgets);
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('設定頁可開啟並顯示診斷列（含「立即執行一次檢查」）', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined).first);
    await settle(tester);
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  // 同一檔買兩次（兩筆 Holdings）是一般券商常態；這兩支守的是「改到錯的那筆」。
  testWidgets('同檔買兩次：長按編輯第二筆，不能改到第一筆', (tester) async {
    await PortfolioRepository(db).addHolding(
        symbol: '2330.TW', market: 'taiwan', ccy: 'TWD', shares: 2000, costPrice: 1500, costRate: 1);
    await pumpApp(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await settle(tester);

    // 第二筆故意較大 → 排在第一列，確定在可點擊區（太低會被底部導覽欄擋住）
    await tester.longPress(find.textContaining('2000 Shares'));
    await settle(tester);
    await tester.tap(find.text('Edit'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(1), '700');
    await tester.tap(find.text('Save'));
    await settle(tester);

    final rows = await PortfolioRepository(db).holdings();
    expect(rows.singleWhere((h) => h.costPrice == 1500).shares, 700,
        reason: ' 編輯要改到剛長按的那筆，不是同代號的第一筆');
    expect(rows.singleWhere((h) => h.costPrice == 500).shares, 1000,
        reason: '另一筆的成本不能被子單改到');
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('紅漲綠跌開關真的會換色（不是只有存進設定）', (tester) async {
    await pumpApp(tester);
    Color upColor() => Theme.of(tester.element(find.byType(Scaffold).first)).extension<PriceColors>()!.up;
    expect(upColor(), PriceColors.twConvention.up);

    await tester.tap(find.byIcon(Icons.settings_outlined).first);
    await settle(tester);
    await tester.tap(find.byType(Switch));
    await settle(tester);

    expect(upColor(), PriceColors.usConvention.up,
        reason: 'buildTheme 没讀 redIsUp 的話，這行會紅（那個開關就只是裝飾）');
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  test('通知帶的 deep link 要解成可用的 route', () {
    expect(initialRouteOf('dquote://quote/2330.TW'), '/quote?symbol=2330.TW');
    expect(initialRouteOf('dquote://portfolio'), '/portfolio');
    expect(initialRouteOf('dquote://alerts'), '/alerts');
    expect(initialRouteOf('dquote://quote/'), '/');
    expect(initialRouteOf(''), '/');
  });

  testWidgets('app 已在背景時點通知 → resume 要跳到那條通知指的頁', (tester) async {
    notif.pendingDeepLink = 'dquote://quote/TSM';
    await pumpApp(tester);
    expect(find.byType(QuoteDetailPage), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await settle(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);

    expect(find.byType(QuoteDetailPage), findsOneWidget,
        reason: '熱啟動不會重跑 main()，所以 initialRoute 這條路走不到');
    expect(tester.takeException(), isNull);
    await finish(tester);
  });
}
