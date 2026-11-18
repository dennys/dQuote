import 'dart:ui' show Locale;

import 'package:dquote/core/alerts.dart';
import 'package:dquote/core/models.dart';
import 'package:dquote/core/widget_data.dart';
import 'package:dquote/data/datasources/yahoo_datasource.dart';
import 'package:dquote/platform/platform.dart';

import 'package:dquote/di.dart' show digestStringsOf;
import 'package:dquote/generated/l10n/app_localizations.dart';

/// 測試用的假實作。
///
/// 刻意**不用 mockito**：這裡的介面都很小，手寫 fake 幾十行就夠，還不用被
/// `build_runner` / `test` 的版本互相鎖死（同 family 專案踩過的版本地獄）。

class FakeQuoteSource implements QuoteDataSource {
  FakeQuoteSource([Map<String, Quote>? quotes]) : quotes = Map.of(quotes ?? {});

  final Map<String, Quote> quotes;

  /// 測試可設定哪些代號要失敗（模擬「資料源壞了 / 查無代號」）
  final Set<String> failing = {};

  /// 記錄每次被要求抓的代號，用來驗證「只抓需要的、沒抓時段外的」
  final List<String> requested = [];

  @override
  Future<Quote> quote(String symbol) async {
    requested.add(symbol);
    final q = quotes[symbol];
    if (q == null || failing.contains(symbol)) {
      throw QuoteException('fake: 查無代號', symbol: symbol);
    }
    return q;
  }

  @override
  Future<CandleSeries> candles(String symbol, QuoteRange range) async {
    requested.add(symbol);
    final q = quotes[symbol];
    if (q == null || failing.contains(symbol)) {
      throw QuoteException('fake: 查無代號', symbol: symbol);
    }
    return CandleSeries(symbol: symbol, range: range, candles: _fakeCandles(range), quote: q);
  }

  static List<Candle> _fakeCandles(QuoteRange range) {
    // 20 根，收盤線性上升；時間戳用固定基準，避免測試依賴現在時間
    final step = switch (range) {
      QuoteRange.d1 => 300,
      QuoteRange.d5 => 1800,
      _ => 86400,
    };
    return [
      for (var i = 0; i < 20; i++)
        Candle(
            time: 1700000000 + i * step,
            open: 100.0 + i,
            high: 101.0 + i,
            low: 99.0 + i,
            close: 100.5 + i,
            volume: 1000.0 + i)
    ];
  }
}

Quote quoteOf(String symbol, double price, {double? prev, String ccy = 'TWD', Market market = Market.taiwan, String? name}) =>
    Quote(
      symbol: symbol,
      name: name ?? symbol,
      currency: ccy,
      market: market,
      price: price,
      previousClose: prev,
      marketTime: 1700000000,
      volume: 1000,
    );

class FakeNotificationGateway implements NotificationGateway {
  final List<String> alerts = [];
  final List<({String key, String title, String body})> digests = [];

  /// 通知內文（斷行行為靠這個驗，`alerts` 那個字串是給觸發順序用的）。
  final List<String> alertBodies = [];

  /// 通知標題的來源（gateway 用 quote.name 當標題）—— 驗別名有沒有上到通知。
  final List<String?> alertQuoteNames = [];
  bool granted = true;

  /// `ensurePermission()` 被叫過幾次 —— 驗「啟動時不問、進提醒頁才問」。
  int asked = 0;

  /// 測試可塞一條「使用者是點通知進來的」；取過就清（跟真實作一樣）。
  String? pendingDeepLink;

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
  Future<bool> ensurePermission() async {
    asked++;
    return granted;
  }

  @override
  Future<String?> takePendingDeepLink() async {
    final deep = pendingDeepLink;
    pendingDeepLink = null;
    return deep;
  }

  @override
  Future<void> showAlert({
    required AlertRule rule,
    required Quote? quote,
    required double? value,
    required String body,
  }) async {
    alerts.add('${rule.kind.name}:${rule.symbol}:$value');
    alertBodies.add(body);
    alertQuoteNames.add(quote?.name);
  }

  @override
  Future<void> showDigest({required String key, required String title, required String body}) async {
    digests.add((key: key, title: title, body: body));
  }
}

class FakeWidgetBridge implements WidgetBridge {
  WidgetPayload? lastPayload;

  @override
  Future<void> publish(WidgetPayload payload) async => lastPayload = payload;
}

/// 提醒規則的快捷建立
AlertRule rule(AlertKind kind, {int id = 1, String? symbol, double? threshold, AlertScope scope = AlertScope.single, bool enabled = true}) =>
    AlertRule(id: id, kind: kind, scope: scope, symbol: symbol, threshold: threshold, enabled: enabled);

/// 通知文案由呼叫端傳進來（前景 l10n、背景用裝置語系查表）。測試固定用中文版，
/// 內文斷言才不會跟著測試跑在什麼語系而飄。
final zhStrings = digestStringsOf(lookupAppLocalizations(const Locale('zh')));
