# dQuote｜行情 · 匯率 · 持股

台股 / 美股 / 外匯的報價、走勢、持股損益與提醒。第一階段 **Android only**。

- 報價來源：公開 Yahoo Finance chart API（`v8/finance/chart/<symbol>`），**不自建後端**。
- 基礎貨幣固定 `TWD`；個股顯示原幣，所有加總／損益一律經 `MoneyFormatter` 換算。
- 通知與桌面小工具走「輪詢 + 冪等」路線，不用精確鬧鐘（見下方「排程設計」）。

---

## 建立

只需要一條指令（Linux/aarch64 開發機，debug）：

```bash
flutter build apk --debug --target-platform android-arm64
```

產物：`build/app/outputs/flutter-apk/app-debug.apk`（約 109 MB，只含 `arm64-v8a`）。

**Release / AOT 這台主機做不了**：Google 只發 x86-64 host 的 `gen_snapshot`。要出正式包請在
x86-64 機器或 CI 上做（`android/app/build.gradle.kts` 目前 release 仍掛 debug signing）。

其他常用指令：

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 改過 drift 表結構後必跑
flutter gen-l10n                                           # 改過 lib/l10n/*.arb 後必跑
flutter analyze
flutter test
```

`pubspec_overrides.yaml` 是**本機专用**（gitignored）：把 `path_provider_android` 釘在沒有 jni
native 編譯的版本，讓 aarch64 主機也能 build；CI／正式版用乾淨依賴集，不受影響。

## 測試

`flutter test`（136 支，全部離線、不打網路、不用裝置）：

| 測試檔 | 守的是什麼 |
| --- | --- |
| `trading_calendar_test.dart` | 台/美開盤時段、美國 DST 邊界、傳 local 時間不會差 8 小時、日報時窗 |
| `symbol_parser_test.dart` | 代號解析（`2330→2330.TW`、`USDTWD→USDTWD=X`、無法辨識要回 null） |
| `money_formatter_test.dart` | 金額／漲跌幅顯示，匯率缺失時要顯示「—」而不是偷偷變 0 |
| `pnl_test.dart` | 證券損益與匯兌損益的拆分、**證券 + 匯兌 == 合計**、部位占比、可買力 |
| `alert_engine_test.dart` | **re-arm 去重**：條件成立期間不重複轟，回到未成立才重新武裝 |
| `quote_repository_test.dart` | 快取優先、單檔失敗不拖垮整批、走勢快取與 TTL、**網路壞掉時退回舊圖** |
| `fx_service_test.dart` | 匯率要有 TTL：抓過一次就永遠不重抓 → 總資產會用舊匯率算 |
| `instrument_repository_test.dart` | 分頁 ↔ market 歸屬（加了卻哪個分頁都看不到的那個坑）、拖曳排序寫回 |
| `heartbeat_test.dart` | 心跳整合：時段判斷 → 抓價 → 觸發 → 日報冪等 → **日報開關** → 小工具發布（含列數上限） |
| `widget_data_test.dart` | Flutter ↔ Kotlin 小工具的 JSON 契約（改欄位名會被擋） |
| `app_smoke_test.dart` | 五個分頁＋個股頁＋設定頁真的 pump 得起來（**這支抓到過無限重建迴圈**，見下）、同檔買兩次改對列、紅漲綠跌真的換色、通知 deep link |
| `repo_hygiene_test.dart` | 版控裡不許出現機器名／內網 IP／帳號路徑（repo 是 public） |

`test/fakes.dart` 提供假的報價來源／通知閘門／小工具橋，所以心跳可以在固定假時間下整條跑完。

跑測試請加 timeout（`timeout 400 flutter test`）：build 方法一旦有無限重建，`flutter test`
會**掛住而不是報錯**，沒有人先 kill 就會這樣燒掉幾十分鐘。

### 已經被測試抓到的真 bug（留檔，別縮回去）

- **drift 的 stream 在 `build()` 裡建立** → StreamBuilder 每次重建都重新訂閱 → drift 推初值
  → setState → 無限重建。手機上會把一顆 CPU 燒滿、電吃掉一半，`analyze` 完全查不出來。
  守則：**`stream:`／`future:` 的參數一律來自 State 欄位（`late final`），不在 build 裡 new**。
- **seed 的 market 打成 `'index'`（正確是 `'stockIndex'`）**，加上分頁是字串比對 → 加權指數
  在**任何**分頁都不顯示。現在 seed 一律用 `Market` 常數，並有測試掃「每一筆都必須有分頁會顯示」。
- 可買力沒把外幣價格乘上匯率（`sharesAffordable`）。
- 匯率幣別表漏了 `TWD`，導致 `USDTWD` 被當成美股 ticker。
- 收盤日報用來源給的名字（Yahoo 對某些台股不给 name → 日報出現代號而不是 Stocks 名）。
- **同檔買兩次時用 symbol 反查持股列** → 長按第二筆編輯，改到的卻是第一筆（另一筆的成本被踩掉）。
  守則：編輯／刪除一律用 `PositionPnl.id` / `CashPnl.id`（資料庫列 id），**不用業務欄位反查**。
- **外幣現金的匯差只進匯兌、不進合計** → 卡面變成「證券 +50,000、匯兌 +6,000、合計 +50,000」。
  契約寫在 `pnl.dart` 檔頭：`securitiesPnlBase + fxPnlBase == pnlBase`。
- `buildTheme` 收了 `redIsUp` 卻沒讀它 → 設定頁那個開關只是裝飾（Kotlin 端也寫死紅漲）。
  現在兩邊都讀同一個 `red_is_up`，而且它在 `WidgetPayload` 裡，小工具不會跟 app 不同色。
- 小工具列數滑桿没人讀：心跳把 `in_widget` 的全部發出去。現在走 `InstrumentRepository.forWidget(limit:)`。
- `closingDigest` 這個 kind 完全沒人讀：設了不會觸發、不想收日報也沒地方關。
  現在它就是日報的開關（`Heartbeat` 讀那條規則的 `enabled`；沒建規則 = 預設開）。
- 通知的 `payload['deep']` 沒人被讀 → 點通知只是把 app 帶到前景。現在 `takePendingDeepLink()`
  在啟動與 resume 時各問一次（resume 那條很重要：熱啟動**不會重跑 `main()`**）。
- 三個自選股分頁各一個 30 秒 `Timer.periodic`，app 進背景後**還是會跑**（Android 不凍 isolate）
  → 15 分鐘心跳的省電設計被抵銷。現在用 `WidgetsBindingObserver` 只在前景輪詢。
- 走勢圖：快取過期 + 網路壞掉 = 錯誤頁（明明還有圖可畫）。現在 `history()` 退回快取，
  從未抓過才把錯誤丟給 UI。

## 架構

```
lib/
  core/        純 Dart、無 Flutter、無 I/O —— 所有易錯的判斷都集中在這裡，也最好測
    models.dart          Market / QuoteRange / Quote / Candle
    symbol.dart          代號解析（純規則，不打網路、不做中文搜尋）
    money.dart           MoneyFormatter：金額顯示的唯一出口
    pnl.dart             證券損益 / 匯兌損益 / 合計 / 占比 / 可買力
    trading_calendar.dart 開盤時段、美國 DST 自己算、日報時窗與冪等 key
    alerts.dart          AlertEngine（re-arm 狀態機）
    widget_data.dart     桌面小工具 JSON 契約（Kotlin 端讀同一份）
    clock.dart           注入時間，讓上述邏輯可用假時間測
  data/
    db/database.dart     drift 表：Instruments / Holdings / CashPositions / Candles /
                         QuoteCache / Alerts / AlertLogs / Settings
    datasources/yahoo_datasource.dart   Yahoo chart API（唯一出網口）
    repositories/        quote / instrument / portfolio / alert / settings
  domain/
    heartbeat.dart       排程進來後真正跑的那一段（見下）
    portfolio_service.dart  從持股 + 現金 + 報價 + 匯率算出總覽（全站只此一处）
    fx_service.dart      匯率查表（走報價快取，**帶 TTL**：沒 TTL 會用早上的匯率算傍晚的資產）
    digest_text.dart     收盤日報的文字組裝（背景執行時沒有 l10n context）
  platform/
    platform.dart            可替換介面：通知 / 排程 / 小工具
    awesome_gateway.dart     awesome_notifications（三個 channel）
    workmanager_scheduler.dart  15 分鐘 periodic work
    home_widget_bridge.dart  寫 SharedPreferences 給 Glance 小工具
  pages/          行情列表、個股走勢、持股、提醒、設定
  di.dart         get_it 裝配 + WorkManager 的 Dart 進入點
android/app/src/main/kotlin/com/dennys/dquote/
  DquoteWidget.kt   Glance 桌面小工具 + 讀 SharedPreferences 的解析（純邏輯、壞掉不崩）
```

## 排程設計（為什麼不用精確鬧鐘）

通知要帶**即時資料**，所以一定要在 app 醒著時才發得出來；精確鬧鐘（`SCHEDULE_EXACT_ALARM`）
换来的是「可能弹不出內容」加上要使用者去開特殊權限。因此：

- **一條 15 分鐘的 WorkManager 心跳**（`dquote.heartbeat`），不用 foreground service。
- 每個 tick：看是否需要抓價（盤中 / 有日報欠著 / 手動觸發）→ 評估提醒 → 發日報 → 發布小工具。
- **時間窗口 + 冪等 key**，不是精確時間點：`TradingCalendar.twDigestKey()` 只在收盤後的時窗內
  回傳 key（`TW-2026-11-20`），發過就寫進 `Settings`。被 Doze 延後到晚上補發也不會重發，
  同一個交易日重複 tick 也不會重發。
- 美股日報的時窗故意設在台北 05:00 之後 —— 收盤是台北凌晨 4 點，不該在那時吵人。
- 提醒的「發過了沒」存在 `AlertLogs`：條件成立期間保持解除武裝，回到未成立才重新武裝。
- 收盤日報的開關就是提醒頁那條 `closingDigest` 規則（`enabled=false` 就不發；**沒建這條 = 預設開**）。
- 通知發送**失敗時不標記已發**，下次 tick 會重試（不會靜態吞掉日報）。
- 前景只在前景輪詢：三個分頁各一個 30 秒 `Timer.periodic`，用 `WidgetsBindingObserver` 在
  `resumed` 起、其他狀態停 —— Dart 的 timer 在 Android 背景**不會被凍結**，不管就會一直打網路。
- 設定頁有兩顆按鈕：「立即執行一次檢查」在 UI isolate 裡跑心跳（看得到結果數字），
  「經排程（WorkManager）執行一次」走真正上線那條路（另一個 isolate，會自己 initialize 通知 channel）。
  **兩顆都要按過**才算驗到排程。
- 點通知會開到對應頁面：冷啟動由 `main.dart` 讀 `takePendingDeepLink()`，app 已在背景時由
  `app.dart` 在 resume 時補問（熱啟動不會重跑 `main()`）。

## 已知取捨 / 未做

- **還沒上過真機**。通知權限、排程在 Doze 下的實際延遲、小工具點擊與顏色，都需要 Pixel 8 實測。
- 小工具點擊在 app 已於背景運行時只把 app 帶到前景，不會跳到該档（`FlutterActivity` 不會把
  新 intent 轉給 Dart）。要修就得加 `onNewIntent` + MethodChannel。（通知點擊已走 payload 的
  deep link，不需要 `onNewIntent`。）
- 小工具的列數與紅漲綠跌是**心跳發布時**帶過去的，改了設定要等下一次心跳（最多 15 分鐘）才生效；
  app 內的顏色是立即生效。
- 指數跟加密**不另開分頁**：指數顯示在台股分頁、加密顯示在美股分頁（見 `marketTabs`）。
- 代號解析是純規則：台積電股票代码一律 `2330.TW`（上櫃 `.TWO` 實測不可用，也改寫 `.TW`）；
  `TSMC` 這種不存在，美股 ADR 要用 `TSM`。不做中文搜尋 —— Yahoo 的搜尋對中文不可靠。
- 批量報價 API（`v7/finance/quote`）對一般使用者關閉（回 `Unauthorized`），所以多档請求是
  多條 chart 請求並行（並發上限 5）。
- Yahoo chart 沒有 `regularMarketChange`，漲跌一律用 `previousClose` 自己算。
- 匯率幣別表只有一處：`symbol.dart` 的 `knownFxBases`（`_currencies` 由它加 `TWD` 組出）。
  新增幣別只改那一個清單，否則 `USDTWD` 這種會被當成美股 ticker（有測試擋著）。
- iOS 目錄留著但沒動：跨平台契約在 `core/`，iOS WidgetKit 還沒做。
- 台股放假／補班目前**沒算**（只辨週末）。要準確得放一份行事曆資料。
