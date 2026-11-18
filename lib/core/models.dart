/// 報價與走勢的資料模型（純 Dart，不依賴 Flutter，方便在 test/ 裡直接測）。
library;

enum Market { taiwan, america, fx, stockIndex, crypto }

/// 走勢區間 → Yahoo 的 `range` / `interval` 參數對照。
///
/// 檔位是刻意縮到 6 個（使用者只看得懂這幾個），名稱為 UI 字串，由 l10n 提供。
enum QuoteRange {
  d1('1d', '5m'),
  d5('5d', '30m'),
  m1('1mo', '1d'),
  m3('3mo', '1d'),
  y1('1y', '1d'),
  y5('5y', '1wk');

  const QuoteRange(this.range, this.interval);
  final String range;
  final String interval;
}

/// 一檔的最新報價。
///
/// [change] / [changePct] 一律**自己用 previousClose 算**：實測 Yahoo 的 chart 端點
/// 不提供 `regularMarketChange`（只有 `regularMarketChangePercent`），兩者的四捨五入
/// 與「對比哪天」在停牌/除息日會不一致，所以統一由本檔決定基準。
class Quote {
  const Quote({
    required this.symbol,
    required this.name,
    required this.currency,
    required this.market,
    required this.price,
    required this.previousClose,
    required this.marketTime,
    this.volume,
  });

  final String symbol;
  final String name;
  final String currency;
  final Market market;
  final double price;
  final double? previousClose;

  /// 只換顯示名用（通知要把使用者自訂的**別名**放上去，但別名不進 Quote 本身 ——
  /// 它是 instruments 表的欄位，不該散到報價模型裡）。
  Quote copyWith({String? name}) => Quote(
        symbol: symbol,
        name: name ?? this.name,
        currency: currency,
        market: market,
        price: price,
        previousClose: previousClose,
        marketTime: marketTime,
        volume: volume,
      );

  /// 交易所時間（epoch seconds），用於顯示「更新於」與判斷是否為盤中價。
  final int? marketTime;
  final double? volume;

  double? get change {
    final prev = previousClose;
    return prev == null || prev == 0 ? null : price - prev;
  }

  double? get changePct {
    final prev = previousClose;
    return prev == null || prev == 0 ? null : (price - prev) / prev * 100;
  }

  bool get isUp => (change ?? 0) > 0;
}

/// 一根 K 線／走勢點。
class Candle {
  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });

  final int time; // epoch seconds
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;
}
