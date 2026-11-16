import 'dart:convert';

import 'models.dart';
import 'pnl.dart';

/// Flutter ↔ 原生桌面小工具的**資料契約**。
///
/// 定在規畫階段並凍結，是因為 Android 與 iOS 讀的是同一份 JSON：
/// * Android：Kotlin Glance 端 `context.getSharedPreferences("HomeWidget", MODE_PRIVATE)`
/// * iOS（以後）：Swift 端 `UserDefaults(suiteName: "group.<bundle id>")`
///
/// 如果當初把報價拼成 Android 專用的 extras/bundle，iOS 那期就得整個重寫 —— 這一檔就是
/// 為了「保留 iOS 升級空間」而存在的東西。改欄位請**加新欄、不要改既有欄的語意**。
class WidgetContract {
  static const quotesKey = 'quotes';

  /// SharedPreferences 檔名（home_widget 的預設值；iOS 的 App Group ID 請用同一個字串基調，
  /// 見 PLAN.md 附錄「iOS 升級清單」）。
  static const appGroupId = 'com.dennys.dquote';
}

class WidgetRow {
  const WidgetRow({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePct,
    required this.currency,
    required this.market,
  });

  final String symbol;
  final String name;
  final double price;
  final double? change;
  final double? changePct;
  final String currency;
  final Market market;

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'price': price,
        'chg': change,
        'chg_pct': changePct,
        'ccy': currency,
        'market': market.name,
      };

  factory WidgetRow.fromJson(Map<String, dynamic> m) => WidgetRow(
        symbol: m['symbol'] as String,
        name: (m['name'] as String?) ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0,
        change: (m['chg'] as num?)?.toDouble(),
        changePct: (m['chg_pct'] as num?)?.toDouble(),
        currency: (m['ccy'] as String?) ?? 'TWD',
        market: Market.values.firstWhere((e) => e.name == m['market'],
            orElse: () => Market.america),
      );
}

/// 寫進小工具的整個 payload（`quotes` 這個 key）。
class WidgetPayload {
  const WidgetPayload({
    required this.updatedAt,
    required this.baseCcy,
    required this.redIsUp,
    required this.rows,
  });

  final int updatedAt; // epoch seconds
  final String baseCcy;

  /// 紅漲綠跌（台灣慣例）與否則綠漲紅跌。跟著 payload 一起走，小工具才不會跟 app 不同色。
  final bool redIsUp;
  final List<WidgetRow> rows;

  String encode() => jsonEncode({
        'updated_at': updatedAt,
        'base_ccy': baseCcy,
        'red_is_up': redIsUp,
        'rows': [for (final r in rows) r.toJson()],
      });

  static WidgetPayload decode(String s) {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return WidgetPayload(
      updatedAt: (m['updated_at'] as num?)?.toInt() ?? 0,
      baseCcy: (m['base_ccy'] as String?) ?? 'TWD',
      redIsUp: m['red_is_up'] as bool? ?? true, // 舊 payload / 欄位缺失 → 台灣預設紅漲
      rows: [
        for (final r in (m['rows'] as List? ?? const []))
          WidgetRow.fromJson((r as Map).cast<String, dynamic>()),
      ],
    );
  }
}

/// 收盤日報的**內容結構**（不含文案）。文案由通知層用 l10n 組，這樣這層可純測。
class ClosingDigest {
  const ClosingDigest({
    required this.market,
    required this.tradingDate,
    required this.summary,
    required this.gainers,
    required this.losers,
    required this.indexQuote,
  });

  final String market; // TW | US
  final String tradingDate;
  final PortfolioSummary summary;

  /// 漲跌幅排行（各最多 3 筆），用 WidgetRow 同一個形状，方便複用。
  final List<WidgetRow> gainers;
  final List<WidgetRow> losers;
  final Quote? indexQuote;

  static List<WidgetRow> rank(List<WidgetRow> rows, {required bool up, int limit = 3}) {
    final usable = rows.where((r) => r.changePct != null).toList()
      ..sort((a, b) => up
          ? b.changePct!.compareTo(a.changePct!)
          : a.changePct!.compareTo(b.changePct!));
    return usable.take(limit).toList();
  }
}
