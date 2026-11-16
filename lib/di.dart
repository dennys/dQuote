import 'dart:ui';

import 'package:get_it/get_it.dart';
import 'package:workmanager/workmanager.dart';

import 'core/clock.dart';
import 'core/trading_calendar.dart';
import 'data/db/database.dart';
import 'data/datasources/yahoo_datasource.dart';
import 'data/repositories/alert_repository.dart';
import 'data/repositories/instrument_repository.dart';
import 'data/repositories/portfolio_repository.dart';
import 'data/repositories/quote_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'domain/fx_service.dart';
import 'domain/heartbeat.dart';
import 'domain/portfolio_service.dart';
import 'generated/l10n/app_localizations.dart';
import 'platform/awesome_gateway.dart';
import 'platform/home_widget_bridge.dart';
import 'platform/platform.dart';
import 'platform/workmanager_scheduler.dart';

final getIt = GetIt.instance;

/// 依賴容器。**只有一處 new 得出來東西**，所以背景 isolate 也能用同一套（不需要
/// BuildContext、不需要 l10n 的 widget tree）。
class AppContainer {
  AppContainer({
    required this.db,
    required this.instruments,
    required this.portfolio,
    required this.quotes,
    required this.alerts,
    required this.settings,
    required this.fx,
    required this.portfolioService,
    required this.notification,
    required this.widget,
    required this.scheduler,
    required this.heartbeat,
  });

  final AppDatabase db;
  final InstrumentRepository instruments;
  final PortfolioRepository portfolio;
  final QuoteRepository quotes;
  final AlertRepository alerts;
  final SettingsRepository settings;
  final FxService fx;
  final PortfolioService portfolioService;
  // 介面而不是實作類別：測試才塞得進假的（真機上沒人碰得到這三個類別的差異）。
  final NotificationGateway notification;
  final WidgetBridge widget;
  final RefreshScheduler scheduler;
  final Heartbeat heartbeat;

  /// [db] 可注入記憶體資料庫給測試用。
  static Future<AppContainer> create({
    AppDatabase? db,
    Clock? clock,
    QuoteDataSource? quoteSource,
    NotificationGateway? notification,
    WidgetBridge? widget,
    RefreshScheduler? scheduler,
  }) async {
    final database = db ?? AppDatabase.open();
    await database.seedIfEmpty();

    final instruments = InstrumentRepository(database);
    final portfolio = PortfolioRepository(database);
    final settings = SettingsRepository(database);
    final alerts = AlertRepository(database);
    final quotes = QuoteRepository(database, quoteSource ?? YahooDataSource());
    final baseCcy = await settings.baseCcy();
    final fx = FxService(quotes, baseCcy: baseCcy);
    final portfolioService = PortfolioService(
      db: database,
      portfolio: portfolio,
      quotes: quotes,
      fx: fx,
      baseCcy: baseCcy,
    );
    final gateway = notification ?? AwesomeNotificationGateway();
    final widgetBridge = widget ?? HomeWidgetBridge();
    final refreshScheduler = scheduler ?? WorkmanagerScheduler();

    final heartbeat = Heartbeat(
      clock: clock ?? nowUtc,
      calendar: const TradingCalendar(),
      portfolio: portfolioService,
      quotes: quotes,
      alerts: alerts,
      instruments: instruments,
      settings: settings,
      fx: fx,
      notification: gateway,
      widget: widgetBridge,
      baseCcy: baseCcy,
    );

    return AppContainer(
      db: database,
      instruments: instruments,
      portfolio: portfolio,
      quotes: quotes,
      alerts: alerts,
      settings: settings,
      fx: fx,
      portfolioService: portfolioService,
      notification: gateway,
      widget: widgetBridge,
      scheduler: refreshScheduler,
      heartbeat: heartbeat,
    );
  }

  /// 註冊到 GetIt，UI 用 `getIt<AppContainer>()` 拿。
  static Future<AppContainer> bootstrap() async {
    if (getIt.isRegistered<AppContainer>()) return getIt<AppContainer>();
    final c = await create();
    getIt.registerSingleton<AppContainer>(c);
    return c;
  }
}

/// 背景通知要的字串（沒有 BuildContext，用裝置語系查表 —— 比照同 family 專案的做法）。
({String digestName, String digestDesc, String priceName, String priceDesc, String pnlName, String pnlDesc})
    backgroundChannelTexts() {
  final l = lookupAppLocalizations(PlatformDispatcher.instance.locale);
  return (
    digestName: l.channelDigestDesc,
    digestDesc: l.channelDigestDesc,
    priceName: l.channelPriceDesc,
    priceDesc: l.channelPriceDesc,
    pnlName: l.channelPnlDesc,
    pnlDesc: l.channelPnlDesc,
  );
}

/// WorkManager 的背景進入點。必须是 **top-level function** + `vm:entry-point`，
/// 否則 release 會被 tree-shake 掉、背景永遠不跑（debug 發現不了，是最難查的一类 bug）。
@pragma('vm:entry-point')
void heartbeatDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    return _runBackgroundTick(force: false); // 回 false 讓 WorkManager 依退避政策重試
  });
}

/// 桌面小工具「↻」按鈕的進入點（home_widget 在背景 headless engine 呼叫）。
/// 只有一個動作，所以只認 `dquote://refresh`；其他 URI 直接忽略。
@pragma('vm:entry-point')
Future<void> widgetInteractivityDispatcher(Uri? uri) async {
  if (uri?.host != 'refresh') return;
  await _runBackgroundTick(force: true);
}

Future<bool> _runBackgroundTick({required bool force}) async {
  try {
    final container = await AppContainer.create();
    final t = backgroundChannelTexts();
    await container.notification.initialize(
      digestName: t.digestName,
      digestDesc: t.digestDesc,
      priceName: t.priceName,
      priceDesc: t.priceDesc,
      pnlName: t.pnlName,
      pnlDesc: t.pnlDesc,
    );
    await container.heartbeat.tick(force: force);
    return true;
  } on Object {
    return false;
  }
}
