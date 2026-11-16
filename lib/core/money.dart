import 'package:intl/intl.dart';

/// 全部金額顯示的**唯一出口**。
///
/// 規畫階段的契約：任何地方都不准自己寫 `'NT\$' + x.toString()`，否則以後要支援
/// 「切換基礎貨幣」就會到处返工。基礎貨幣目前固定 TWD（[SettingsRepository.baseCcy]），
/// UI 只從這裡拿字串。
class MoneyFormatter {
  const MoneyFormatter({
    required this.baseCcy,
    required this.rateOf,
    this.zeroDecimalCurrencies = const {'JPY', 'KRW', 'VND', 'IDR'},
  });

  /// 加總與換算用的基礎貨幣（现阶段固定 `TWD`）。
  final String baseCcy;

  /// 每 1 個 [ccy] 值多少基礎貨幣。回 null 代表沒有匯率（此時不硬猜，讓呼叫端顯示 `—`）。
  final double? Function(String ccy) rateOf;

  final Set<String> zeroDecimalCurrencies;

  static const _symbols = {
    'TWD': 'NT\$', 'USD': 'US\$', 'JPY': '¥', 'CNY': '¥', 'EUR': '€', 'GBP': '£',
    'KRW': '₩', 'SGD': 'S\$', 'HKD': 'HK\$', 'AUD': 'A\$', 'CAD': 'C\$', 'CHF': 'CHF ',
    'NZD': 'NZ\$', 'THB': '฿', 'VND': '₫', 'MYR': 'RM',
  };

  static String symbolOf(String ccy) => _symbols[ccy.toUpperCase()] ?? '${ccy.toUpperCase()} ';

  int _decimalsFor(double v, String ccy, int? explicit) {
    if (explicit != null) return explicit;
    if (v.abs() < 1 && v != 0) return 4; // 匯率小數（JPYTWD 0.2043）
    if (zeroDecimalCurrencies.contains(ccy.toUpperCase())) return 0;
    if (v.abs() >= 1000 && v == v.roundToDouble()) return 0;
    return 2;
  }

  /// 一般金額：`2,295`、`150.50`、`¥1,200`
  String amount(double v, String ccy, {int? decimals, bool withSymbol = true}) {
    final d = _decimalsFor(v, ccy, decimals);
    final body = NumberFormat.currency(
      locale: 'en_US', // 刻意用 en_US：千分位逗號，不受裝置 locale 影響（繁體中文也用逗號分位）
      symbol: '',
      decimalDigits: d,
    ).format(v);
    return withSymbol ? '${symbolOf(ccy)}$body' : body;
  }

  /// 帶正負號的金額（漲跌、損益）：`+2,295`、`-3.10`
  String signed(double v, String ccy, {int? decimals, bool withSymbol = true}) {
    final body = amount(v.abs(), ccy, decimals: decimals, withSymbol: withSymbol);
    if (v > 0) return '+$body';
    if (v < 0) return '-$body';
    return body;
  }

  /// 百分比（呼叫端給的是「百分之幾」，不是小數）：`+2.34%`
  String pct(double v, {int decimals = 2, bool alwaysSign = true}) {
    final body = NumberFormat.decimalPatternDigits(locale: 'en_US', decimalDigits: decimals).format(v.abs());
    if (v > 0) return alwaysSign ? '+$body%' : '$body%';
    if (v < 0) return '-$body%';
    return '$body%';
  }

  /// 換算成基礎貨幣；沒有匯率時回 null（**不硬猜**，讓 UI 顯示 `—`）。
  double? toBase(double v, String ccy) {
    final c = ccy.toUpperCase();
    if (c == baseCcy.toUpperCase()) return v;
    final r = rateOf(c);
    return r == null ? null : v * r;
  }

  /// 基礎貨幣金額（總資產、合計損益都用這支）。
  String base(double v, {int? decimals, bool withSymbol = true}) =>
      amount(v, baseCcy, decimals: decimals, withSymbol: withSymbol);

  String signedBase(double v, {int? decimals, bool withSymbol = true}) =>
      signed(v, baseCcy, decimals: decimals, withSymbol: withSymbol);

  /// `HH:mm`，給「更新於」用；null → `—`
  /// 先 `toLocal()`：DateFormat 不會換時區，UTC 時間會直接印成 UTC+0。
  static String clock(DateTime? t) =>
      t == null ? '—' : DateFormat('HH:mm').format(t.toLocal());
}
