import '../core/alerts.dart';
import '../core/money.dart';
import '../core/widget_data.dart';

/// 通知用的文案（標題、日報各行標籤、提醒條件的文字）。
///
/// 為什麼不直接用 AppLocalizations：WorkManager 與小工具的回調在**另一個 entrypoint** 跑，
/// 那裡沒有 widget tree、沒有 `BuildContext`。所以文案由呼叫端組好傳進來 —— 前景
/// `AppLocalizations.of(context)`、背景 `lookupAppLocalizations(裝置語系)`，兩邊同一份
/// arb key（見 `di.dart` 的 [digestStringsOf]）。
///
/// **刻意不給預設值**：以前這裡有個硬編碼的 `DigestStrings.zh()` 當預設，結果英文介面
/// 的使用者永遠收到中文通知，而且不會有人發現。少了預設，忘了接線就會編不過。
class DigestStrings {
  const DigestStrings({
    required this.twTitle,
    required this.usTitle,
    required this.totalAssets,
    required this.pnlLabel,
    required this.gainersLabel,
    required this.losersLabel,
    required this.indexLabel,
    required this.updatedLabel,
    required this.noData,
    required this.alertTitle,
    required this.kindLabels,
  });

  final String twTitle, usTitle, totalAssets, pnlLabel, gainersLabel, losersLabel;
  final String indexLabel, updatedLabel, noData, alertTitle;

  /// 提醒條件的文字（`above` → 「價格突破」）。以前通知裡直接印 `AlertKind.name`，
  /// 中文使用者看到的是「dQuote 提醒 above 210」這種半英文。
  final Map<AlertKind, String> kindLabels;

  String kindName(AlertKind kind) => kindLabels[kind] ?? kind.name;
}

class DigestText {
  const DigestText(this.title, this.body);
  final String title;
  final String body;
}

/// 把 [ClosingDigest] 組成人看的兩行。純函式，可在 test/ 裡驗內容。
DigestText buildDigestText(
  ClosingDigest d,
  DigestStrings s,
  MoneyFormatter fmt,
  DateTime? updatedAt,
) {
  final title = d.market == 'TW' ? s.twTitle : s.usTitle;

  final lines = <String>[];
  final idx = d.indexQuote;
  if (idx != null) {
    lines.add('${s.indexLabel} ${fmt.amount(idx.price, idx.currency, decimals: 0)}'
        '${idx.changePct == null ? '' : ' ${fmt.pct(idx.changePct!)}'}');
  }

  final total = d.summary.totalAssetsBase;
  lines.add('${s.totalAssets} ${fmt.base(total)} · '
      '${s.pnlLabel} ${d.summary.pnlPct == null ? s.noData : fmt.pct(d.summary.pnlPct!)}');

  // 一檔一行。以前三檔擠在同一行用「 / 」隔開，通知裡（BigText 的摺疊視圖只給一行）
  // 看起來就是一串分不清邊界的數字。
  void addRank(String label, List<WidgetRow> rows) {
    if (rows.isEmpty) return;
    lines.add(label);
    for (final r in rows) {
      lines.add('${r.name.isEmpty ? r.symbol : r.name} ${fmt.pct(r.changePct ?? 0)}');
    }
  }

  addRank(s.gainersLabel, d.gainers);
  addRank(s.losersLabel, d.losers);
  if (updatedAt != null) lines.add('${s.updatedLabel} ${MoneyFormatter.clock(updatedAt)}');

  return DigestText(title, lines.join('\n'));
}
