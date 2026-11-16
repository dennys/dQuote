# dQuote — 待辦與分期

主線：Android debug。目前**代碼写完但尚未上真機**。

## 第 0 期：探雷（已完成）

- [x] Glance + Compose 在 Flutter template（AGP 9.1 / Kotlin 2.4 / built-in Kotlin 遷移中途）
      能不能 build → **可以**，`flutter build apk --debug` 通過，compose 相關 AAR 下載量很小
      （遠低於 100 MB）。
- [x] drift + `sqlite3_flutter_libs` 的原生編譯在 aarch64 主機可跑（APK 內有 `libsqlite3.so`）。
- [x] 通知／排程／小工具三個 platform 介面可 fake，全部邏輯離線可測。

## 第 0.5 期：無裝置下的品質（已完成）

- [x] 114 支測試全過（含 UI 冒煙測試），`flutter analyze` 乾淨，debug APK build 通過。
- [x] 無限重建迴圈修正（見 README「已經被測試抓到的真 bug」）。

## 第 1 期：真機驗收（需要 Pixel 8）

現在就只能等人。逐項打勾：

- [ ] 首次進入提醒頁會請求通知權限；拒絕時其他功能不受影響。
- [ ] 設定頁「立即執行一次檢查」→ 立刻收到通知（先驗通道，再驗排程）。
- [ ] 15 分鐘 periodic work 在 Doze／淺眠下會延遲，但**收盤日報要在當天補發出來**；
      設定頁「上次檢查」時間要跟著更新。
- [ ] 通知點擊 → 跳到該档走勢頁（`dquote://quote/<symbol>`）。
- [ ] 價格上穿／下穿只發一次；跌回去再突破才會再發（`AlertLogs` 的 re-arm）。
- [ ] 桌面小工具：新增到桌面、顯示自選股、紅漲綠跌、點擊進個股頁、下拉更新後數字會變。
- [ ] 斷網時：顯示上次報價 + 「更新於 HH:mm」，不白畫面、不閃錯誤頁。
- [ ] 美股時段（台灣凌晨）不會在 04:00 推送，05:00 後才發。

## 第 2 期：做完第一階段的細節

- [ ] 台股行事曆（放假／補班）——目前只辨週末，假日會誤判成「收盤日」。
- [ ] 持股頁新增／編輯的表單驗證完整走一遍（含負數、0 股、成本為 0）。
- [x] ~~自選股拖曳排序~~ 已做（`ReorderableListView.builder` + 長按拖曳，`InstrumentRepository.reorder`）。
- [x] ~~持股／現金不能編輯~~ 已做（長按一列 → 編輯／刪除；代號與幣別鎖定，改股數/成本/金額/取得匯率）。
- [x] ~~通知權限只藏在設定頁~~ 已做（進提醒頁就問，被拒時頁面留紅色提示 + 重試）。
- [ ] 提醒歷史頁（`AlertLogs` 已有資料，只有提醒頁底部顯示最近幾筆）。
- [ ] 匯率分頁的幣別清單補齊（只改 `symbol.dart` 的 `knownFxBases` 一處就好，`_currencies` 由它推導）。

## 第 3 期：正式包

- [ ] 在 x86-64 機器／CI 出 release（這台 aarch64 沒有 AOT 的 `gen_snapshot`）。
- [ ] signing：比照 family 專案讀 `key.properties`（鑰**不進版控**），目前 release 仍掛 debug signing。
- [ ] R8／minify 開起來後再驗一次通知與小工具（Glance 偶爾需要 keep 規則）。
- [ ] 小工具預覽圖（現在暫借 `ic_launcher`）、app icon 換掉 Flutter 預設。
- [ ] 體積檢查：debug APK 109 MB 含 debug 資產與未 strip 的 `.so`，release 會小很多，
      但仍要確認 `libsqlite3.so` 有被 strip。

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

## 全庫審查（2026-11-11）——已完成

這一輪照 README「怎麼保證沒 bug」的方法走：先掃易錯邏輯，再為每個修改補一支**會紅**的測試。

- [x] 持股／現金的編輯與刪除改用**列 id**（`PositionPnl.id` / `CashPnl.id`）：同檔買兩次時，
      之前拿 symbol 反查會永遠改到第一筆，另一筆的成本悄悄被踩掉。
- [x] `computePnl` 把外幣現金的匯差也計入合計，並定下契約 `securitiesPnlBase + fxPnlBase == pnlBase`；
      台幣現金歸為支付工具（不進損益、也不進報酬率分母）。
- [x] `FxService` 加 TTL 與 `force`：之前一個幣別抓過一次就永遠不重抓，開一整天的 app 會拿
      早上的匯率算傍晚的總資產（畫面上看不出來）。
- [x] 三個自選股分頁的前景輪詢接 `WidgetsBindingObserver`，進背景就停（Dart timer 在 Android 背景不會凍）。
- [x] `redIsUp` 接回 theme 與小工具（放進 `WidgetPayload.red_is_up`；舊 payload 預設紅漲）。
- [x] 小工具列數改用 `InstrumentRepository.forWidget(limit: settings.widgetRows())`；
      `closingDigest` 規則變成日報開關（沒建 = 預設開）。
- [x] 點通知真的跳頁：`NotificationGateway.takePendingDeepLink()`；冷啟動在 `main.dart`、
      熱啟動在 `app.dart` 的 resume（熱啟動不會重跑 `main()`）。
- [x] 走勢圖：快取過期 + 網路壞掉時退回最後抓到的圖（之前變成錯誤頁，與 README 的承諾相反）。
- [x] 清死碼（無人讀的 getter、只寫不讀的 `widget_prefs` 欄位與 `WidgetContract.prefsKey`、
      没人呼叫的 `cancel()` / `clearHistoryFor` / `setBaseCcy` 等）；設定頁補「經排程執行一次」。
- [ ] 真機驗證（Pixel 8）：通知點擊三條路（冷啟動 / 熱啟動 / app 已死）、小工具顏色與列數、
      設定頁兩顆按鈕（含 WorkManager 那顆）各按一次。
