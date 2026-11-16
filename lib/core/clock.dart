/// 全域唯一的时间來源。
///
/// 存在的理由只有一個：`DateTime.now()` 回傳的是「本地」DateTime，把它直接餵給
/// [TradingCalendar] 雖然已經有防呆（內部會 `toUtc()`），但**排程與去重 key 都必須用同一個
/// 時間基準**，否則測試無法決定時間、也無法重現「收盤日報在 Doze 之後補發」這類情況。
/// 需要可測的元件一律注入 [Clock]，production 傳 [nowUtc]，測試傳固定時間。
typedef Clock = DateTime Function();

/// 取得「現在」的絕對時刻（UTC）。這是全專案唯一該用的 now。
DateTime nowUtc() => DateTime.now().toUtc();

/// 測試用：固定時間的 Clock。
Clock fixedClock(DateTime t) => () => t;
