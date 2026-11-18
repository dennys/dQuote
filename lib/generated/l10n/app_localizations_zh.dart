// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'dQuote｜行情·匯率·持股';

  @override
  String get tabWatchlist => '自選';

  @override
  String get tabPortfolio => '持股';

  @override
  String get tabAlerts => '提醒';

  @override
  String get actionAdd => '新增';

  @override
  String get actionDelete => '刪除';

  @override
  String get actionSave => '儲存';

  @override
  String get actionCancel => '取消';

  @override
  String get actionEdit => '編輯';

  @override
  String get actionRetry => '重試';

  @override
  String get actionClose => '關閉';

  @override
  String get fieldSymbol => '代號';

  @override
  String get fieldName => '名稱';

  @override
  String get pickSymbol => '從自選股選擇';

  @override
  String get actionAlias => '改別名';

  @override
  String get aliasTitle => '別名（只影響顯示）';

  @override
  String get aliasHint => '留空＝用來源的名稱';

  @override
  String get fieldShares => '股數';

  @override
  String get fieldCostPrice => '成本';

  @override
  String get fieldAmount => '金額';

  @override
  String get fieldCostRate => '取得匯率';

  @override
  String get fieldNote => '備註';

  @override
  String get fieldThreshold => '觸發值';

  @override
  String get labelPrice => '價格';

  @override
  String get labelChange => '漲跌';

  @override
  String get labelChangePct => '漲跌%';

  @override
  String get labelMarketValue => '市值';

  @override
  String get labelPnl => '損益';

  @override
  String get labelPnlPct => '損益%';

  @override
  String get labelTotalAssets => '總資產';

  @override
  String get labelSecuritiesPnl => '證券損益';

  @override
  String get labelFxPnl => '匯兌損益';

  @override
  String get labelCombinedPnl => '合計（基礎幣）';

  @override
  String get labelAllocation => '資產配置';

  @override
  String get labelCash => '現金';

  @override
  String get labelForeignCash => '外幣';

  @override
  String get labelHoldings => '持股';

  @override
  String get labelBuyingPower => '可買力';

  @override
  String get labelLastCheck => '上次檢查';

  @override
  String get labelDelayedQuote => '延遲報價';

  @override
  String updatedOn(String time) {
    return '更新於 $time';
  }

  @override
  String ofBase(String amount, String twd) {
    return '$amount ≈ $twd';
  }

  @override
  String get range1d => '1日';

  @override
  String get range5d => '5日';

  @override
  String get range1m => '1月';

  @override
  String get range3m => '3月';

  @override
  String get range1y => '1年';

  @override
  String get range5y => '5年';

  @override
  String get labelVolume => '成交量';

  @override
  String get labelCostLine => '成本線';

  @override
  String get noData => '無資料';

  @override
  String get loadFailed => '載入失敗';

  @override
  String get loadFailedHint => '檢查網路，或報價來源可能已變更。';

  @override
  String get addInstrumentTitle => '加入自選股';

  @override
  String get addInstrumentHint => '2330 · TSM · NVDA · USD/TWD · ^TWII';

  @override
  String get symbolUnrecognized => '無法辨識的代號';

  @override
  String get symbolNotFound => '找不到這個代號';

  @override
  String get alreadyAdded => '已經在自選股裡';

  @override
  String get emptyWatchlist => '還沒有資料，點 + 加入代號。';

  @override
  String get emptyAlerts => '還沒有提醒規則，點 + 新增一條。';

  @override
  String get addHoldingTitle => '新增持股';

  @override
  String get addCashTitle => '新增現金／外幣';

  @override
  String get cashKindBroker => '券商帳戶';

  @override
  String get cashKindBank => '銀行';

  @override
  String get cashKindWallet => '手頭現金';

  @override
  String get emptyPortfolio => '還沒有持股。';

  @override
  String get addAlertTitle => '新增提醒';

  @override
  String get addToWidget => '加入桌面小工具';

  @override
  String get removeFromWidget => '移出桌面小工具';

  @override
  String get addedToWidget => '已加入桌面小工具';

  @override
  String get removedFromWidget => '已移出桌面小工具';

  @override
  String get widgetRowLimit => '小工具列數已滿 — 到設定頁調高列數才會顯示這档。';

  @override
  String get alertKindClosingDigest => '收盤日報';

  @override
  String get alertKindAbove => '價格以上';

  @override
  String get alertKindBelow => '價格以下';

  @override
  String get alertKindDayChange => '單日漲跌幅';

  @override
  String get alertKindPnl => '持股損益%';

  @override
  String get alertKindFx => '匯率突破';

  @override
  String get alertEnabled => '啟用';

  @override
  String get alertScopeSingle => '這檔';

  @override
  String get alertScopePortfolio => '整體投資組合';

  @override
  String get alertHistory => '通知歷史';

  @override
  String get alertHistoryEmpty => '還沒有觸發紀錄。';

  @override
  String alertFiredAt(String time, String value) {
    return '$time · $value';
  }

  @override
  String alertTriggeredBody(
    String name,
    String price,
    String chgPct,
    String threshold,
  ) {
    return '$name $price（$chgPct）— 觸發值 $threshold';
  }

  @override
  String get channelDigestDesc => '收盤摘要';

  @override
  String get channelPriceDesc => '價位觸發';

  @override
  String get channelPnlDesc => '損益警示';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsBaseCurrency => '基礎貨幣';

  @override
  String get settingsRedIsUp => '紅漲綠跌（台灣慣例）';

  @override
  String get settingsTheme => '主題';

  @override
  String get settingsThemeSystem => '跟隨系統';

  @override
  String get settingsThemeLight => '淺色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsWidgetRows => '桌面小工具顯示幾列';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsDeveloper => '開發者';

  @override
  String get settingsRunTickNow => '立即執行一次檢查';

  @override
  String get settingsRunTickViaScheduler => '經排程（WorkManager）執行一次';

  @override
  String get settingsTickScheduled => '已排入背景執行，看「上次檢查」的時間確認。';

  @override
  String get settingsBatteryOptimization => '電池最佳化設定';

  @override
  String get settingsAbout => '關於';

  @override
  String get settingsVersion => '版本';

  @override
  String get notifPermRationale => 'dQuote 只在你自己設定的提醒觸發時發通知。';

  @override
  String get notifPermissionMissing => '通知被擋住 —— 提醒與收盤日報都不會送達。';

  @override
  String get actionUnchanged => '不修改';
}
