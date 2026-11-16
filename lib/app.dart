import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/models.dart';
import 'di.dart';
import 'generated/l10n/app_localizations.dart';
import 'pages/alerts_page.dart';
import 'pages/portfolio_page.dart';
import 'pages/quote_detail_page.dart';
import 'pages/watchlist_page.dart';
import 'theme.dart';

/// 設定狀態（主題、紅漲綠跌、基礎幣）。啟動時讀一次，之後從設定頁改。
class SettingsController extends ChangeNotifier {
  SettingsController(this._container) {
    _load();
  }

  final AppContainer _container;
  ThemeMode _themeMode = ThemeMode.system;
  bool _redIsUp = true;
  String _baseCcy = 'TWD';
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get redIsUp => _redIsUp;
  String get baseCcy => _baseCcy;
  bool get loaded => _loaded;

  Future<void> _load() async {
    final s = _container.settings;
    final mode = await s.themeMode();
    _redIsUp = await s.redIsUp();
    _baseCcy = await s.baseCcy();
    _themeMode = switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    _themeMode = m;
    await _container.settings.setThemeMode(m.name);
    notifyListeners();
  }

  Future<void> setRedIsUp(bool v) async {
    _redIsUp = v;
    await _container.settings.setRedIsUp(v);
    notifyListeners();
  }
}

/// 把 `dquote://quote/2330.TW` 這類 deep link 換成 MaterialApp 的路徑。
///
/// 不拉 go_router：目前只有兩個入口（某档走勢頁、持股頁），用 routeName 就夠；
/// 以後頁面超過十個再換套件。Android 端的 intent-filter 在 AndroidManifest.xml，
/// iOS 以後只要 Info.plist 加 CFBundleURLTypes，**Dart 這侧不用改**。
String initialRouteOf(String routeName) {
  final uri = Uri.tryParse(routeName);
  if (uri == null) return '/';
  if (uri.scheme == 'dquote') {
    switch (uri.host) {
      case 'quote':
        final symbol = Uri.decodeComponent(uri.pathSegments.join('/'));
        return symbol.isEmpty ? '/' : '/quote?symbol=$symbol';
      case 'portfolio':
        return '/portfolio';
      case 'alerts':
        return '/alerts';
    }
  }
  return '/';
}

/// 給背景 resume 用的跳頁入口（`MaterialApp.navigatorKey`）：那個時機點沒有 BuildContext。
final appNavigatorKey = GlobalKey<NavigatorState>();

class DQuoteApp extends StatelessWidget {
  const DQuoteApp({super.key, this.initialRoute = '/'});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsController(getIt<AppContainer>()),
      child: Consumer<SettingsController>(
        builder: (context, settings, _) => MaterialApp(
          navigatorKey: appNavigatorKey,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(brightness: Brightness.light, redIsUp: settings.redIsUp),
          darkTheme: buildTheme(brightness: Brightness.dark, redIsUp: settings.redIsUp),
          themeMode: settings.themeMode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: initialRoute,
          routes: {
            '/': (_) => const HomeShell(),
            '/portfolio': (_) => const HomeShell(initialTab: 3),
            '/alerts': (_) => const HomeShell(initialTab: 4),
          },
          onGenerateRoute: (routeSettings) {
            final name = routeSettings.name ?? '/';
            final uri = Uri.parse(name);
            if (uri.path == '/quote') {
              return MaterialPageRoute(
                builder: (_) => QuoteDetailPage(symbol: uri.queryParameters['symbol'] ?? ''),
              );
            }
            return MaterialPageRoute(builder: (_) => const HomeShell());
          },
          builder: (context, child) => _DeepLinkOnResume(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}

/// 點通知時 app 可能只是在背景被叫醒 —— **不會重跑 `main()`**，所以 `initialRoute` 這條路
/// 走不到。這裡在 resume 時補問一次通知帶的 deep link（`takePendingDeepLink` 取過就清，
/// 所以不會重複跳）。沒帶東西時整個 widget 就是透明的 child。
class _DeepLinkOnResume extends StatefulWidget {
  const _DeepLinkOnResume({required this.child});
  final Widget child;

  @override
  State<_DeepLinkOnResume> createState() => _DeepLinkOnResumeState();
}

class _DeepLinkOnResumeState extends State<_DeepLinkOnResume> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _route();
  }

  Future<void> _route() async {
    final deep = await getIt<AppContainer>().notification.takePendingDeepLink();
    if (deep == null || !mounted) return;
    appNavigatorKey.currentState?.pushNamed(initialRouteOf(deep));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// 底部導覽。三個市場分頁在 WatchlistPage 內部用 TabBar，所以「市場」與「功能」
/// 不會擠在同一層。
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          WatchlistPage(markets: taiwanTabMarkets),
          WatchlistPage(markets: americaTabMarkets),
          WatchlistPage(markets: fxTabMarkets),
          PortfolioPage(),
          AlertsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.show_chart), label: l.tabTaiwan),
          NavigationDestination(icon: const Icon(Icons.public), label: l.tabAmerica),
          NavigationDestination(icon: const Icon(Icons.swap_horiz), label: l.tabFx),
          NavigationDestination(icon: const Icon(Icons.account_balance_wallet), label: l.tabPortfolio),
          NavigationDestination(icon: const Icon(Icons.notifications), label: l.tabAlerts),
        ],
      ),
    );
  }
}
