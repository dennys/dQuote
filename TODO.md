# dQuote — 待辦與分期

主線：Android debug。已經上過真機，測過的在第 1 期打勾了；沒測的都括號寫了怎麼測。

## 第 0 期：探雷（已完成）

- [x] Glance + Compose 在 Flutter template（AGP 9.1 / Kotlin 2.4 / built-in Kotlin 遷移中途）
      能不能 build → **可以**，`flutter build apk --debug` 通過，compose 相關 AAR 下載量很小
      （遠低於 100 MB）。
- [x] drift 的 `libsqlite3.so` 在 aarch64 主機進得了 APK。**不要**因此加 `sqlite3_flutter_libs`
      —— 它由 sqlite3 3.8+ 的 native-assets hook 提供（pubspec 那行註解為準，以前這裡寫相反）。
- [x] 通知／排程／小工具三個 platform 介面可 fake，全部邏輯離線可測。

## 第 0.5 期：無裝置下的品質（已完成）

- [x] 114 支測試全過（2026-11-16 的數）＋ `flutter analyze` 乾淨＋ debug APK build 通過。
      現在 134 支（2026-11-17 補了小工具開關與匯率漲跌格式各一支）。
- [x] 無限重建迴圈修正（見 README「已經被測試抓到的真 bug」）。

## 第 1 期：真機驗收

逐項打勾。沒測的都在括號裡寫了要怎麼測，不要憑感覺勾。

- [x] 首次進入提醒頁會請求通知權限；拒絕時其他功能不受影響。
- [x] 設定頁「立即執行一次檢查」→ 立刻收到通知（通道這條通了，排程那條在下面）。
- [x] 斷網時：顯示上次報價 + 「更新於 HH:mm」，不白畫面、不閃錯誤頁。
- [x] 桌面小工具：新增到桌面、顯示自選股、紅漲綠跌、點擊進個股頁。
- [ ] **小工具「↻」→ 背景重抓報價，數字與「更新於」都變。**
      這是我方最新一個功能、也是**唯一還沒有人路測過**的一條：走 `HomeWidgetBackgroundReceiver`
      → WorkManager → headless engine，跟設定頁那顆按鈕（前景 isolate）不是同一條路。
      必測個案：**app 完全沒開過時按 ↻**（`registerInteractivityCallback` 的 handle 要 app 開過
      一次才存得進 SharedPreferences）。卡住時看 `adb logcat | grep -i HomeWidgetBackgroundWorker`
      有沒有起引擎。
- [ ] 「更新於」在收盤後要是**報價的時間**，不是現在（2026-11-17 review 修的：小工具以前打
      `clock()`，長按加入股票會讓它報一個比 app 還新的時間）。真機再確認一次。
- [ ] 盤中下拉更新後數字會變。**收盤時測不到** —— 數字本來就不會動，要嘛盤中測，要嘛按 ↻。
- [ ] 15 分鐘 periodic work 在 Doze／淺眠下會延遲，但**收盤日報要在當天補發出來**；
      設定頁「上次檢查」時間要跟著更新。（別開 app，放一整天看當天有沒有補發）
- [ ] 通知點擊 → 跳到該档走勢頁（`dquote://quote/<symbol>`）。三條路都要走：冷啟動／熱啟動／app 已死。
- [ ] 價格上穿／下穿只發一次；跌回去再突破才會再發（`AlertLogs` 的 re-arm）。
      （設一個就在現價附近的門檻，幾分鐘內就能看到兩邊行為）
- [ ] 美股時段（台灣凌晨）不會在 04:00 推送，05:00 後才發。（睡前設好，早上看通知時間）

## 第 2 期：做完第一階段的細節

- [ ] 台股行事曆（放假／補班）——目前只辨週末，假日會誤判成「收盤日」。
- [ ] 持股頁新增／編輯的表單驗證完整走一遍（含負數、0 股、成本為 0）。
- [x] ~~自選股拖曳排序~~ 已做（`ReorderableListView.builder` + 長按拖曳，`InstrumentRepository.reorder`）。
- [x] ~~持股／現金不能編輯~~ 已做（長按一列 → 編輯／刪除；代號與幣別鎖定，改股數/成本/金額/取得匯率）。
- [x] ~~通知權限只藏在設定頁~~ 已做（進提醒頁就問，被拒時頁面留紅色提示 + 重試）。
- [ ] 提醒歷史頁（`AlertLogs` 已有資料，只有提醒頁底部顯示最近幾筆）。
- [ ] 匯率幣別清單補齊（自選頁那幾列匯率；只改 `symbol.dart` 的 `knownFxBases` 一處就好，
      `_currencies` 由它推導）。

## 第 3 期：正式包

- [x] 在 x86-64 機器／CI 出 release（這台 aarch64 沒有 AOT 的 `gen_snapshot`）：CI 的
      `flutter build apk --release` 已跑綠（2026-11-16 run #1–#3 全成功，含簽章與 artifact）。
- [x] signing：讀 `android/app/key.properties` ＋ `dquote.keystore`，兩者都不進版控。
      2026-11-17 修正：**沒有 `key.properties` 時不再指定 `signingConfig`** —— 以前留 null 的
      `storeFile` 會讓 AGP 的 `ValidateSigningTask` 直接失敗，而不是像註解說的「退回未簽章」。
  - [ ] ⚠️ 鑰目前只**確定**存在 GitHub secrets（`KEYSTORE_B64`／`KEY_PROPERTIES`，寫進去就讀不出來），
        開發機上沒有 → 實質上只有一份。人手的事：取副本分存三處（本機／第二台機器或 NAS／密碼管理器），
        `sha256sum` 核對一致後把實際位置記回這裡。
  - [ ] 「沒鑰就跑 release」這條分支 CI 驗不到（CI 一律有 secrets），本機也驗不了（沒有 AOT）；
        只驗過 gradle configuration 與 debug build。要驗得在 x86-64 機器上故意不放 `key.properties`。
- [ ] R8／minify 開起來後再驗一次通知與小工具（Glance 偶爾需要 keep 規則）。
- [ ] 小工具預覽圖（現在暫借 `ic_launcher`）。
- [x] app icon 換掉 Flutter 預設（`flutter_launcher_icons` ＋ `assets/images/icon.png`；
      它不在 pubspec 的 `assets:` 清單裡 → 只佔 repo 體積，不會進 APK）。
- [ ] 體積檢查：debug APK 109 MB 含 debug 資產與未 strip 的 `.so`（實測 2026-11-17），release 會小很多，
      但仍要確認 `libsqlite3.so` 有被 strip。
- [ ] CI 穩定後試關回 `kotlin.incremental`（現為躲多模組平行編譯搶 FilePageCache 先關掉，
      代價是 CI 每次都全量編 Kotlin）。
- [ ] 小工具的漲跌格式與 app 是**兩份實作**（Dart `quoteChangeText` / Kotlin `Row.changeText`），
      改一邊不會提醒你另一邊 —— 2026-11-17 就抓到兩邊印不一樣的數字（`+15` vs `+15.00`）。
      要嘛補一支 Kotlin 端的小測試，要嘛把樣本固定成兩側共讀的 contract fixture。

## 第 4 期：iOS（尚未開始）

- [ ] `ios/` 目前只有 `flutter create` 的預設內容；跨平台契約都在 `lib/core/`，Dart 這側不需改。
- [ ] 需要另行實作：WidgetKit target（讀同一份 JSON 契約）、`CFBundleURLTypes` 的 `dquote` scheme、
      APNs／`UNCalendarNotificationTrigger` 或背景 fetch 對應 WorkManager 那一層。
- [ ]  decision 點：iOS 端要不要用同一套 re-arm 邏輯（建議要，`AlertEngine` 是純 Dart，可直接重用）。

## 明確不做（避免日後又被加回來）

- 不做懸浮窗（Android 需要 overlay 權限，且與省電目標衝突）。
- 不做中文關鍵字搜尋（Yahoo 搜尋對中文不可靠）；改用代號規則解析。
- 不自建後端／不代理 Yahoo；批量 quote API 對一般使用者關閉，也就不強求。
- 不用精確鬧鐘（`SCHEDULE_EXACT_ALARM`）；一律「輪詢 + 時間窗 + 冪等 key」。
- 不引入 `shared_preferences`（設定進 drift `Settings`）、`http`（用 dio）、
  `timezone`（DST 自己算）、`flutter_local_notifications`（用 awesome_notifications）。
  小工具的 `HomeWidgetPreferences` 是 home_widget 在 Android 端**自己**用原生 SharedPreferences
  存的，不靠那個 plugin（pubspec.lock 裡查不到它）。

## 全庫審查（2026-11-11）——已完成

這一輪照 README「怎麼保證沒 bug」的方法走：先掃易錯邏輯，再為每個修改補一支**會紅**的測試。

- [x] 持股／現金的編輯與刪除改用**列 id**（`PositionPnl.id` / `CashPnl.id`）：同檔買兩次時，
      之前拿 symbol 反查會永遠改到第一筆，另一筆的成本悄悄被踩掉。
- [x] `computePnl` 把外幣現金的匯差也計入合計，並定下契約 `securitiesPnlBase + fxPnlBase == pnlBase`；
      台幣現金歸為支付工具（不進損益、也不進報酬率分母）。
- [x] `FxService` 加 TTL 與 `force`：之前一個幣別抓過一次就永遠不重抓，開一整天的 app 會拿
      早上的匯率算傍晚的總資產（畫面上看不出來）。
- [x] 自選頁的前景輪詢接 `WidgetsBindingObserver`，進背景就停（Dart timer 在 Android 背景不會凍）。
- [x] `redIsUp` 接回 theme 與小工具（放進 `WidgetPayload.red_is_up`；舊 payload 預設紅漲）。
- [x] 小工具列數改用 `InstrumentRepository.forWidget(limit: settings.widgetRows())`；
      `closingDigest` 規則變成日報開關（沒建 = 預設開）。
- [x] 點通知真的跳頁：`NotificationGateway.takePendingDeepLink()`；冷啟動在 `main.dart`、
      熱啟動在 `app.dart` 的 resume（熱啟動不會重跑 `main()`）。
- [x] 走勢圖：快取過期 + 網路壞掉時退回最後抓到的圖（之前變成錯誤頁，與 README 的承諾相反）。
- [x] 清死碼（無人讀的 getter、只寫不讀的 `widget_prefs` 欄位與 `WidgetContract.prefsKey`、
      没人呼叫的 `cancel()` / `clearHistoryFor` / `setBaseCcy` 等）；設定頁補「經排程執行一次」。
- [ ] 真機驗證還差：通知點擊三條路（冷啟動／熱啟動／app 已死）、設定頁「經排程（WorkManager）執行一次」
      那顆。已測：小工具顏色與列數、「立即執行一次檢查」。

## 代碼審查（2026-11-17）——已完成

範圍：`be3d99e`（CI／簽章）之後的 4 個 commit。修掉的：

- [x] `build.gradle.kts`：缺 `key.properties` 時不再指定 `signingConfig`（否則 AGP 9.1 的
      `ValidateSigningTask` 會報「Keystore file not set for signing config release」）；
      CI 的 secrets 驗證補 `storeFile=`。
- [x] 小工具「更新於」改用快取批次時間（`quotes.lastUpdated()`），不再是 `clock()`。
- [x] Kotlin 的 `fmt` 補 `minimumFractionDigits` → 小工具與 app 印一樣的數字（`+15.00`／`+0.1000`）。
- [x] 小工具開關收斂成 `Heartbeat.setInWidget()`：一個入口、兩頁共用，並回傳「有沒有真的進到小工具」
      —— 超過列數上限時改顯示「列數已滿」，不再假裝已加入。
- [x] 測試補齊：匯率漲跌 4 位小數、長按進出小工具（含列數滿了那條分支）。
- [x] 清死碼：`InstrumentRepository.byMarket`（合併成單一自選頁後沒人用了）與指向舊分頁機制的註解。
