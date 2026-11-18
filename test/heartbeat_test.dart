import 'package:dquote/core/alerts.dart';
import 'package:dquote/core/clock.dart';
import 'package:dquote/core/models.dart';
import 'package:dquote/core/trading_calendar.dart';
import 'package:dquote/data/db/database.dart';
import 'package:dquote/data/repositories/alert_repository.dart';
import 'package:dquote/data/repositories/instrument_repository.dart';
import 'package:dquote/data/repositories/portfolio_repository.dart';
import 'package:dquote/data/repositories/quote_repository.dart';
import 'package:dquote/data/repositories/settings_repository.dart';
import 'package:dquote/domain/fx_service.dart';
import 'package:dquote/domain/heartbeat.dart';
import 'package:dquote/domain/portfolio_service.dart';
import 'package:dquote/platform/platform.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// 心跳的整合測試：把「時段判斷 + 抓價 + re-arm 去重 + 日報冪等 + 小工具發布」
/// 串在一起跑，用**固定時間**與記憶體資料庫，不需要裝置、不需要網路。
///
/// 這支測試是整個提醒功能的保險絲 —— 這些邏輯在真機上要等 15 分鐘才看得出一次結果，
/// 沒有它就只能靠人工乾等（也最容易悄悄壞掉）。
void main() {
  late AppDatabase db;
  late FakeQuoteSource source;
  late FakeNotificationGateway notif;
  late FakeWidgetBridge widgetBridge;
  late QuoteRepository quotes;
  late AlertRepository alerts;
  late SettingsRepository settings;
  late InstrumentRepository instruments;

  setUp(() async {
    db = AppDatabase.memory();
    source = FakeQuoteSource({
      '2330.TW': quoteOf('2330.TW', 2415, prev: 2400),
      '0050.TW': quoteOf('0050.TW', 105, prev: 100),
      'TSM': quoteOf('TSM', 400, prev: 390, ccy: 'USD', market: Market.america),
      'USDTWD=X': quoteOf('USDTWD=X', 32.9, ccy: 'TWD', market: Market.fx),
    });
    notif = FakeNotificationGateway();
    widgetBridge = FakeWidgetBridge();
    quotes = QuoteRepository(db, source);
    alerts = AlertRepository(db);
    settings = SettingsRepository(db);
    instruments = InstrumentRepository(db);
  });

  tearDown(() async => db.close());

  Future<Heartbeat> hb(DateTime at) async {
    final fx = FxService(quotes);
    final portfolio = PortfolioService(db: db, portfolio: PortfolioRepository(db), quotes: quotes, fx: fx);
    return Heartbeat(
      clock: fixedClock(at),
      calendar: const TradingCalendar(),
      portfolio: portfolio,
      quotes: quotes,
      alerts: alerts,
      instruments: instruments,
      settings: settings,
      fx: fx,
      notification: notif,
      widget: widgetBridge,
    );
  }

  // 2026-11-20 是星期五。台北 11:00 = 03:00Z（盤中）；台北 13:40 = 05:40Z（已收盤）
  final inTradSession = DateTime.utc(2026, 11, 20, 3, 0);
  final afterClose = DateTime.utc(2026, 11, 20, 5, 40);
  final weekendNight = DateTime.utc(2026, 11, 21, 16, 0); // 週六台北 00:00

  Future<void> seedWatchlist() async {
    await instruments.add(symbol: '2330.TW', name: '台積電', currency: 'TWD', market: Market.taiwan, inWidget: true);
    await instruments.add(symbol: '0050.TW', name: '元大台灣50', currency: 'TWD', market: Market.taiwan, inWidget: true);
    await instruments.add(symbol: 'TSM', name: 'TSMC ADR', currency: 'USD', market: Market.america);
  }

  group('報價抓取', () {
    test('盤中 tick 會抓自選股並發布給桌面小工具', () async {
      await seedWatchlist();
      final result = await (await hb(inTradSession)).tick();

      expect(result.skippedFetch, isFalse);
      expect(source.requested, containsAll(<String>['2330.TW', '0050.TW', 'TSM']));
      expect(widgetBridge.lastPayload?.rows.length, 2, reason: '只有勾選 in_widget 的兩档進小工具');
      expect(result.errors, isEmpty);
    });

    test('非盤中且沒有日報要發 → 不去抓報價（省電、省 request）', () async {
      await seedWatchlist();
      final result = await (await hb(weekendNight)).tick();
      expect(result.skippedFetch, isTrue);
      expect(source.requested, isEmpty);
    });

    test('單檔失敗不會讓整批失敗（其他档照樣更新）', () async {
      await seedWatchlist();
      source.failing.add('0050.TW');
      final result = await (await hb(inTradSession)).tick();
      final cached = await quotes.cached();
      expect(cached.keys, containsAll(<String>['2330.TW', 'TSM']));
      expect(result.errors, isEmpty, reason: '單檔查無不是心跳的錯誤');
    });
  });

  group('提醒：re-arm 只在心跳這一端也成立', () {
    Future<void> addAboveAlert() async {
      await instruments.add(symbol: '2330.TW', name: '台積電', currency: 'TWD', market: Market.taiwan);
      await alerts.addAlert(kind: AlertKind.above, scope: AlertScope.single, symbol: '2330.TW', threshold: 2400);
    }

    test('第一次觸發、第二次不重複發；跌回去後再突破會再發', () async {
      await addAboveAlert();
      // 2415 > 2400
      var r = await (await hb(inTradSession)).tick();
      expect(r.fired, 1);
      expect(notif.alerts.length, 1);

      r = await (await hb(inTradSession)).tick();
      expect(r.fired, 0, reason: '還在門檻上 → 不重複轟使用者');
      expect(notif.alerts.length, 1);

      // 跌回 2380 → clear（重新武裝）
      source.quotes['2330.TW'] = quoteOf('2330.TW', 2380, prev: 2400);
      r = await (await hb(inTradSession)).tick();
      expect(r.cleared, 1);

      // 再突破 → 又發
      source.quotes['2330.TW'] = quoteOf('2330.TW', 2450, prev: 2400);
      r = await (await hb(inTradSession)).tick();
      expect(r.fired, 1);
      expect(notif.alerts.length, 2);
    });

    test('通知內文一節一行（不擠成一行）', () async {
      await addAboveAlert();
      await (await hb(inTradSession)).tick();
      final body = notif.alertBodies.single;
      expect(body.split('\n').first, allOf(contains('台積電'), contains('2415')));
      expect(body.split('\n').last, contains('dQuote 提醒'), reason: '觸發條件另起一行');
      expect(body, isNot(contains('—')), reason: '不要用破折號把各節串成一行');
    });

    test('通知的標題與內文都用使用者取的別名（長名字那几档靠這個）', () async {
      await instruments.add(
          symbol: '2330.TW', name: 'Taiwan Semiconductor Manufacturing Company', currency: 'TWD', market: Market.taiwan);
      await instruments.setAlias('2330.TW', '台積電');
      await alerts.addAlert(kind: AlertKind.above, scope: AlertScope.single, symbol: '2330.TW', threshold: 2400);
      await (await hb(inTradSession)).tick();
      expect(notif.alertQuoteNames.single, '台積電', reason: '標題用別名，不是來源的長名稱');
      expect(notif.alertBodies.single, contains('台積電 2415'));
    });

    test('觸發紀錄會進通知歷史（同一張表两用）', () async {
      await addAboveAlert();
      await (await hb(inTradSession)).tick();
      final history = await alerts.history();
      expect(history, hasLength(1));
      expect(history.first.triggered, isTrue);
      expect(history.first.value, 2415);
    });

    test('停用中的規則不會發', () async {
      await addAboveAlert();
      final rows = await alerts.alerts();
      await alerts.setEnabled(rows.first.id, false);
      final r = await (await hb(inTradSession)).tick();
      expect(r.fired, 0);
      expect(notif.alerts, isEmpty);
    });
  });

  group('收盤日報', () {
    test('收盤後發一次；同一天重複 tick 不會重發（冪等 key）', () async {
      await seedWatchlist();
      var r = await (await hb(afterClose)).tick();
      expect(r.digestsSent, 1);
      expect(notif.digests.single.key, 'TW-2026-11-20');
      expect(notif.digests.single.body, contains('台積電'), reason: '日報內容要有漲跌排行');

      r = await (await hb(afterClose)).tick();
      expect(r.digestsSent, 0);
      expect(notif.digests.length, 1);
    });

    test('被 Doze 延後到晚上仍能補發（用時窗而不是時間點）', () async {
      await seedWatchlist();
      final lateNight = DateTime.utc(2026, 11, 20, 12, 0); // 台北 20:00
      final r = await (await hb(lateNight)).tick();
      expect(r.digestsSent, 1);
    });

    test('美股日報落在台北凌晨時不發（05:00 以後才發）', () async {
      await seedWatchlist();
      // 夏令收盤 20:00Z → 台北 04:00，不該吵人
      final tooEarly = DateTime.utc(2026, 8, 5, 20, 30);
      final r = await (await hb(tooEarly)).tick();
      expect(notif.digests.where((d) => d.key.startsWith('US')), isEmpty);
      expect(r.digestsSent, 0);
    });

    test('通知發送失敗時不標記已發 → 下次 tick 會重試（不會靜態吞掉日報）', () async {
      await seedWatchlist();
      final failing = _FailingGateway();
      final fx = FxService(quotes);
      final heartbeat = Heartbeat(
        clock: fixedClock(afterClose),
        calendar: const TradingCalendar(),
        portfolio: PortfolioService(db: db, portfolio: PortfolioRepository(db), quotes: quotes, fx: fx),
        quotes: quotes,
        alerts: alerts,
        instruments: instruments,
        settings: settings,
        fx: fx,
        notification: failing,
        widget: widgetBridge,
      );
      final r = await heartbeat.tick();
      expect(r.digestsSent, 0);
      expect(r.errors.any((e) => e.contains('日報')), isTrue);
      expect(await settings.isSent('TW-2026-11-20'), isFalse);
    });
  });

  test('心跳會記錄「上次檢查」時間（設定頁的診斷列）', () async {
    await seedWatchlist();
    await (await hb(inTradSession)).tick();
    expect(await settings.lastHeartbeat(), inTradSession);
  });

  test('小工具只發到設定的列數（設定頁的滑桿不是裝飾）', () async {
    await seedWatchlist();
    await settings.setWidgetRows(1);
    await (await hb(inTradSession)).tick();
    expect(widgetBridge.lastPayload?.rows.length, 1,
        reason: '以前把 in_widget 的全部發出去，滑桿形同虛設');
    expect(widgetBridge.lastPayload?.redIsUp, isTrue);
  });

  test('收盤日報可以用提醒頁那條 closingDigest 規則關掉（沒建 = 預設開）', () async {
    await seedWatchlist();
    await alerts.addAlert(kind: AlertKind.closingDigest, scope: AlertScope.single, enabled: false);
    final r = await (await hb(afterClose)).tick();
    expect(r.digestsSent, 0, reason: '規則停用 = 使用者不要日報');
    expect(await settings.isSent('TW-2026-11-20'), isFalse);
  });
}

class _FailingGateway implements NotificationGateway {
  @override
  Future<void> initialize({
    required String digestName,
    required String digestDesc,
    required String priceName,
    required String priceDesc,
    required String pnlName,
    required String pnlDesc,
  }) async {}

  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<String?> takePendingDeepLink() async => null;

  @override
  Future<void> showAlert({
    required AlertRule rule,
    required Quote? quote,
    required double? value,
    required String body,
  }) async =>
      throw StateError('boom');

  @override
  Future<void> showDigest({required String key, required String title, required String body}) async =>
      throw StateError('boom');
}
