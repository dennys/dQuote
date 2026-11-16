import 'dart:async';

import 'package:dio/dio.dart';

import '../../core/models.dart';
import '../../core/symbol.dart';

/// 報價來源壞掉時丟出的錯誤。UI 一定要能區分「沒網路」與「資料源改格式了」——
/// 後者要顯示最後快取的數字加時間戳，而不是白畫面。
class QuoteException implements Exception {
  QuoteException(this.message, {this.symbol, this.isNetwork = false, this.statusCode});

  final String message;
  final String? symbol;
  final bool isNetwork;
  final int? statusCode;

  @override
  String toString() =>
      'QuoteException($symbol): $message${statusCode == null ? '' : ' (HTTP $statusCode)'}';
}

/// 抓到的走勢（含 meta，讓 UI 不用為名稱/幣別再打一次）。
class CandleSeries {
  const CandleSeries({
    required this.symbol,
    required this.range,
    required this.candles,
    required this.quote,
  });

  final String symbol;
  final QuoteRange range;
  final List<Candle> candles;
  final Quote quote;
}

/// Yahoo Finance chart 端點。
///
/// 2026-11 實測（寫程式前測的，別當成永遠成立）：
/// * `v8/finance/chart/{sym}?range=&interval=` **免 auth 可用**；台/美/匯/指数都蓋到。
/// * `v7/finance/quote`（批量）**被擋**（`Unauthorized`）→ 所以 N 档 = N 個 request，
///   必須自己限制併發，否則自選股一多就會被Rate limit。
/// * 沒有 `regularMarketChange` 欄位 → 漲跌一律自己用 `previousClose` 算（見 [Quote]）。
/// * 沒有中文名稱；部分台股连 `shortName` 都不給（只給 `longName`），所以名稱要 fallback。
abstract class QuoteDataSource {
  Future<Quote> quote(String symbol);
  Future<CandleSeries> candles(String symbol, QuoteRange range);
}

class YahooDataSource implements QuoteDataSource {
  YahooDataSource({Dio? dio, String? baseUrl, int maxConcurrent = 5, Duration? timeout})
      : _baseUrl = baseUrl ?? 'https://query1.finance.yahoo.com',
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: timeout ?? const Duration(seconds: 10),
              receiveTimeout: timeout ?? const Duration(seconds: 10),
              headers: const {'User-Agent': _ua},
            )),
        _permit = _Permit(maxConcurrent);

  static const _ua =
      'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Mobile Safari/537.36';

  final String _baseUrl;
  final Dio _dio;
  final _Permit _permit;

  @override
  Future<Quote> quote(String symbol) async {
    final series = await _fetch(symbol, QuoteRange.d1);
    return series.quote;
  }

  @override
  Future<CandleSeries> candles(String symbol, QuoteRange range) => _fetch(symbol, range);

  Future<CandleSeries> _fetch(String symbol, QuoteRange range) => _permit.run(() async {
        late final Response<Map<String, dynamic>> res;
        try {
          res = await _dio.get<Map<String, dynamic>>(
            '$_baseUrl/v8/finance/chart/${Uri.encodeComponent(symbol)}',
            queryParameters: {'range': range.range, 'interval': range.interval},
          );
        } on DioException catch (e) {
          throw QuoteException(_describe(e),
              symbol: symbol,
              isNetwork: e.type == DioExceptionType.connectionError ||
                  e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout,
              statusCode: e.response?.statusCode);
        }

        final chart = res.data?['chart'];
        final result = chart is Map ? chart['result'] : null;
        final error = chart is Map ? chart['error'] : null;
        if (error != null) {
          throw QuoteException('來源回報：${(error as Map)['code'] ?? error}',
              symbol: symbol, statusCode: res.statusCode);
        }
        if (result is! List || result.isEmpty) {
          throw QuoteException('查無此代號', symbol: symbol, statusCode: res.statusCode);
        }
        final r = (result.first as Map).cast<String, dynamic>();
        return _parse(symbol, range, r);
      });

  static String _describe(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.connectionError =>
          '網路不通',
        DioExceptionType.badResponse => 'HTTP ${e.response?.statusCode}',
        _ => '抓取失敗',
      };

  /// Yahoo 的 chart JSON 巢狀很深且欄位會缺，這裡一次收斂成我們的模型；
  /// 欄位對不上時丟 [QuoteException]（讓上層顯示快取），不要回一堆 null 讓 UI 猜。
  static CandleSeries _parse(String symbol, QuoteRange range, Map<String, dynamic> r) {
    final meta = ((r['meta'] as Map?) ?? const {}).cast<String, dynamic>();
    final price = (meta['regularMarketPrice'] as num?)?.toDouble();
    if (price == null) {
      throw QuoteException('無最新價', symbol: symbol);
    }
    final previous = (meta['previousClose'] as num?)?.toDouble() ??
        (meta['chartPreviousClose'] as num?)?.toDouble();

    final quote = Quote(
      symbol: symbol,
      name: ((meta['shortName'] ?? meta['longName']) as String?)?.trim() ?? '',
      currency: (meta['currency'] as String?) ?? _guessCcy(symbol),
      market: _marketOf(meta, symbol),
      price: price,
      previousClose: previous,
      marketTime: (meta['regularMarketTime'] as num?)?.toInt(),
      volume: (meta['regularMarketVolume'] as num?)?.toDouble(),
    );

    final indicators = ((r['indicators'] as Map?)?['quote'] as List?) ?? const [];
    final bars = indicators.isEmpty
        ? const <String, dynamic>{}
        : (indicators.first as Map).cast<String, dynamic>();
    final stamps = (r['timestamp'] as List?) ?? const [];

    final candles = <Candle>[];
    for (var i = 0; i < stamps.length; i++) {
      final t = (stamps[i] as num?)?.toInt();
      final close = _at(bars['close'], i);
      if (t == null || close == null) continue; // 停牌/資料洞 → 丟掉這根，不畫假點
      candles.add(Candle(
        time: t,
        open: _at(bars['open'], i) ?? close,
        high: _at(bars['high'], i) ?? close,
        low: _at(bars['low'], i) ?? close,
        close: close,
        volume: _at(bars['volume'], i),
      ));
    }

    return CandleSeries(symbol: symbol, range: range, candles: candles, quote: quote);
  }

  static double? _at(Object? list, int i) {
    if (list is! List || i >= list.length) return null;
    final v = list[i];
    return v is num ? v.toDouble() : null;
  }

  static Market _marketOf(Map<String, dynamic> meta, String symbol) {
    final type = (meta['instrumentType'] as String?)?.toUpperCase();
    final ccy = (meta['currency'] as String?)?.toUpperCase();
    return switch (type) {
      'CURRENCY' => Market.fx,
      'INDEX' => Market.stockIndex,
      'CRYPTOCURRENCY' => Market.crypto,
      _ => ccy == 'TWD'
          ? Market.taiwan
          : (parseSymbol(symbol)?.market ?? Market.america),
    };
  }

  static String _guessCcy(String symbol) =>
      symbol.endsWith('TWD=X') || symbol.endsWith('.TW') ? 'TWD' : 'USD';
}

/// 超簡單併發闸门（不拉新依賴）。
///
/// 批量報價端點 `v7/finance/quote` 被 Yahoo 擋掉（實測 `Unauthorized`），所以 N 档要發
/// N 個 request；自選股一多就需要限流，否則 15 分鐘心跳會把自己打進 rate limit。
class _Permit {
  _Permit(this.max);
  final int max;
  int _running = 0;
  final _queue = <Completer<void>>[];

  Future<T> run<T>(Future<T> Function() body) async {
    if (_running >= max) {
      final gate = Completer<void>();
      _queue.add(gate);
      await gate.future;
    }
    _running++;
    try {
      return await body();
    } finally {
      _running--;
      if (_queue.isNotEmpty) _queue.removeAt(0).complete();
    }
  }
}
