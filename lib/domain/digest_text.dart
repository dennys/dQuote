import '../core/money.dart';
import '../core/widget_data.dart';

/// 背景通知用的文案。
///
/// 為什麼不用 AppLocalizations：WorkManager 的回調在**另一個 entrypoint** 跑，那裡沒有
/// widget tree、沒有 `BuildContext`，拿不到生成的 l10n 類別。所以這裡用一般 const 字串，
/// 由 [Heartbeat] 直接組出 title/body。app 在前景時（設定頁那顆「立即執行一次檢查」）
/// 會把本地端翻好的 [DigestStrings] 傳進來，兩邊共用同一個組裝函式。
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
  });

  const DigestStrings.zh()
      : twTitle = '台股收盤',
        usTitle = '美股收盤',
        totalAssets = '總資產',
        pnlLabel = '損益',
        gainersLabel = '漲幅前 3',
        losersLabel = '跌幅前 3',
        indexLabel = '大盤',
        updatedLabel = '更新於',
        noData = '無資料',
        alertTitle = 'dQuote 提醒';

  const DigestStrings.en()
      : twTitle = 'TW close',
        usTitle = 'US close',
        totalAssets = 'Total',
        pnlLabel = 'P/L',
        gainersLabel = 'Gainers',
        losersLabel = 'Losers',
        indexLabel = 'Index',
        updatedLabel = 'Updated',
        noData = 'no data',
        alertTitle = 'dQuote alert';

  final String twTitle, usTitle, totalAssets, pnlLabel, gainersLabel, losersLabel;
  final String indexLabel, updatedLabel, noData, alertTitle;
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
