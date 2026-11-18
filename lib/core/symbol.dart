import 'models.dart';

/// 使用者輸入 → Yahoo symbol 的解析器。**純函式、不打網路**，所以所有情況都能測。
///
/// 規則全部以 2026-11 實測為準（見 PLAN.md「代號解析」節）：
/// * 4 碼數字 → `<code>.TW`；實測**上市、上櫃、ETF 都是 `.TW`**，`.TWO` 一律 Not Found，
///   所以 `.TWO` 一律改寫成 `.TW`（不留雙猜的複雜度）。
/// * 不帶後綴的 `2330`／`0050` Yahoo 回 Not Found → 必須自己補 `.TW`。
/// * 匯率採統一格式 `<BASE><TARGET>=X`（實測 `USDTWD=X` 與 Yahoo 慣用的 `TWD=X` 同值，
///   所以 USD 不需要特例）。
/// * **不支援中文搜尋**（實測 Yahoo 搜尋端點對「台積電」回 0 筆），也**不做**英文 fuzzy
///   搜尋（`tsmc` 會排在巴西 DR 後面；真正的 ADR 是 `TSM`）。
class ParsedSymbol {
  const ParsedSymbol(this.yahooSymbol, this.market, {this.baseCcy, this.targetCcy});

  final String yahooSymbol;
  final Market market;

  /// 只有匯率有值，供匯率Tab顯示幣別名稱用。
  final String? baseCcy;
  final String? targetCcy;

  bool get isFx => market == Market.fx;
}

/// 匯率分頁用的固定清單（**匯率不做搜尋**，幣別就這幾種）。
const knownFxBases = [
  'USD', 'JPY', 'CNY', 'EUR', 'GBP', 'SGD', 'HKD', 'AUD', 'CAD', 'KRW', 'THB', 'VND',
  'CHF', 'NZD', 'MYR',
];

/// 拿来辨識「這是不是貨幣對」用的幣別表 = 上面的清單再加基礎幣。
/// **TWD 一定要在裡面**，否則 `USDTWD` 會被當成美股 ticker 放行
/// （實測過 Yahoo 沒有這種 6 碼股票，會查無代號）。要加幣別只改 `knownFxBases` 一處。
const _currencies = <String>{'TWD', ...knownFxBases};

/// 產生匯率 symbol。`fxSymbol('USD')` → `USDTWD=X`；`fxSymbol('USD','JPY')` → `USDJPY=X`。
ParsedSymbol fxSymbol(String base, [String target = 'TWD']) {
  final b = base.toUpperCase(), t = target.toUpperCase();
  // Yahoo 對 USD/TWD 慣用 `TWD=X`；實測 `USDTWD=X` 同值，為統一規則一律用後者。
  return ParsedSymbol('$b$t=X', Market.fx, baseCcy: b, targetCcy: t);
}

/// 解析使用者輸入；無法辨識回 null（UI 顯示「無法辨識的代號」，不要瞎猜）。
ParsedSymbol? parseSymbol(String raw) {
  var s = raw.trim().toUpperCase();
  if (s.isEmpty || s.length > 16) return null;

  // 大盤指數：^TWII（加權）。實測 ^TSEC／TWII.TW 不存在。
  if (s.startsWith('^')) {
    final body = s.substring(1);
    if (!_isTailingTicker(body)) return null;
    return ParsedSymbol('^$body', Market.stockIndex);
  }

  // 明確的匯率寫法之一：USDTWD=X / TWD=X / USD/TWD / USD-TWD / USD>TWD
  if (s.contains('=')) {
    final body = s.split('=').first;
    if (body.isEmpty) return null;
    if (body.length == 3) {
      // `TWD=X` 是 Yahoo 對「1 USD = ? TWD」的慣用寫法；統一換成 <BASE><TARGET>=X。
      return ParsedSymbol('USD$body=X', Market.fx, baseCcy: 'USD', targetCcy: body);
    }
    if (body.length == 6 && _isLetters(body)) {
      return ParsedSymbol('$body=X', Market.fx,
          baseCcy: body.substring(0, 3), targetCcy: body.substring(3));
    }
    return null;
  }

  for (final sep in const ['/', '>', ':']) {
    if (s.contains(sep)) {
      final parts = s.split(sep).where((e) => e.isNotEmpty).toList();
      if (parts.length != 2) return null;
      final a = parts.first, b = parts.last;
      if (!_isLetters(a) || !_isLetters(b) || a.length != 3 || b.length != 3) return null;
      // 本 app 只顯示「1 外幣 = ? 台幣」這個方向，所以把 TWD/USD 這類反向輸入對調。
      if (a == 'TWD') return fxSymbol(b);
      return fxSymbol(a, b);
    }
  }

  // 6 碼幣對：USDTWD / EURTWD
  if (_isLetters(s) && s.length == 6 && _currencies.contains(s.substring(3))) {
    return fxSymbol(s.substring(0, 3), s.substring(3));
  }

  // 台股代號：4 碼數字（上市／上櫃／ETF），或明寫 .TW/.TWO
  final twMatch = RegExp(r'^(\d{4})(?:\.(TW|TWO))?$').firstMatch(s);
  if (twMatch != null) {
    return ParsedSymbol('${twMatch.group(1)}.TW', Market.taiwan);
  }

  // 加密／其他附屬代號：BTC-USD 這種含 '-' 的一律原樣放行（24/7，不受交易時段限制）
  if (s.contains('-')) {
    // 例外：USD-TWD 這種「用連字號寫的貨幣對」→ 只有兩邊都是 3 碼且其中一邊是台幣才算匯率，
    // 否則 BTC-USD / ETH-USD 會被誤判成貨幣對（USD 是合法幣別，不能靠「是不是幣別」判斷）。
    final parts = s.split('-');
    if (parts.length == 2 &&
        _isLetters(parts[0]) &&
        _isLetters(parts[1]) &&
        parts[0].length == 3 &&
        parts[1].length == 3 &&
        (parts[0] == 'TWD' || parts[1] == 'TWD')) {
      return parts[0] == 'TWD' ? fxSymbol(parts[1]) : fxSymbol(parts[0], parts[1]);
    }
    if (!_isTailingTicker(s)) return null;
    return ParsedSymbol(s, Market.crypto);
  }

  // 美股 / ADR：TSM、NVDA、BRK.B。注意 3 碼（TSM、AMD、IBM）是美股，**不是**匯率。
  if (RegExp(r'^[A-Z][A-Z0-9.]{0,9}$').hasMatch(s)) {
    return ParsedSymbol(s, Market.america);
  }

  return null;
}

bool _isLetters(String s) => RegExp(r'^[A-Z]+$').hasMatch(s);

bool _isTailingTicker(String s) => RegExp(r'^[A-Z0-9][A-Z0-9.\-]{0,14}$').hasMatch(s);
