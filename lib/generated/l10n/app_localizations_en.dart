// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'dQuote';

  @override
  String get tabWatchlist => 'Watchlist';

  @override
  String get tabPortfolio => 'Portfolio';

  @override
  String get tabAlerts => 'Alerts';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionClose => 'Close';

  @override
  String get fieldSymbol => 'Symbol';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldShares => 'Shares';

  @override
  String get fieldCostPrice => 'Cost price';

  @override
  String get fieldAmount => 'Amount';

  @override
  String get fieldCostRate => 'Acquired rate';

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldThreshold => 'Threshold';

  @override
  String get labelPrice => 'Price';

  @override
  String get labelChange => 'Chg';

  @override
  String get labelChangePct => 'Chg %';

  @override
  String get labelMarketValue => 'Value';

  @override
  String get labelPnl => 'P/L';

  @override
  String get labelPnlPct => 'P/L %';

  @override
  String get labelTotalAssets => 'Total assets';

  @override
  String get labelSecuritiesPnl => 'Securities P/L';

  @override
  String get labelFxPnl => 'FX P/L';

  @override
  String get labelCombinedPnl => 'Total (base ccy)';

  @override
  String get labelAllocation => 'Allocation';

  @override
  String get labelCash => 'Cash';

  @override
  String get labelForeignCash => 'Foreign cash';

  @override
  String get labelHoldings => 'Holdings';

  @override
  String get labelBuyingPower => 'Buying power';

  @override
  String get labelLastCheck => 'Last check';

  @override
  String get labelDelayedQuote => 'Delayed quote';

  @override
  String updatedOn(String time) {
    return 'Updated $time';
  }

  @override
  String ofBase(String amount, String twd) {
    return '$amount ≈ $twd';
  }

  @override
  String get range1d => '1D';

  @override
  String get range5d => '5D';

  @override
  String get range1m => '1M';

  @override
  String get range3m => '3M';

  @override
  String get range1y => '1Y';

  @override
  String get range5y => '5Y';

  @override
  String get labelVolume => 'Volume';

  @override
  String get labelCostLine => 'Cost line';

  @override
  String get noData => 'No data';

  @override
  String get loadFailed => 'Could not load';

  @override
  String get loadFailedHint =>
      'Check the network, or the quote source may have changed.';

  @override
  String get addInstrumentTitle => 'Add to watchlist';

  @override
  String get addInstrumentHint => '2330 · TSM · NVDA · USD/TWD · ^TWII';

  @override
  String get symbolUnrecognized => 'Unrecognized symbol';

  @override
  String get symbolNotFound => 'Symbol not found';

  @override
  String get alreadyAdded => 'Already in your watchlist';

  @override
  String get emptyWatchlist => 'Nothing here yet. Tap + to add a symbol.';

  @override
  String get emptyAlerts => 'No alert rules yet. Tap + to add one.';

  @override
  String get addHoldingTitle => 'Add holding';

  @override
  String get addCashTitle => 'Add cash / foreign currency';

  @override
  String get cashKindBroker => 'Broker';

  @override
  String get cashKindBank => 'Bank';

  @override
  String get cashKindWallet => 'Cash on hand';

  @override
  String get emptyPortfolio => 'No holdings yet.';

  @override
  String get addAlertTitle => 'Add alert';

  @override
  String get addToWidget => 'Add to home widget';

  @override
  String get removeFromWidget => 'Remove from home widget';

  @override
  String get addedToWidget => 'Added to home widget';

  @override
  String get removedFromWidget => 'Removed from home widget';

  @override
  String get widgetRowLimit =>
      'Home widget is full — raise the row limit in Settings to show this one.';

  @override
  String get alertKindClosingDigest => 'Closing digest';

  @override
  String get alertKindAbove => 'Price above';

  @override
  String get alertKindBelow => 'Price below';

  @override
  String get alertKindDayChange => 'Daily change %';

  @override
  String get alertKindPnl => 'Position P/L %';

  @override
  String get alertKindFx => 'FX breaks level';

  @override
  String get alertEnabled => 'Enabled';

  @override
  String get alertScopeSingle => 'This symbol';

  @override
  String get alertScopePortfolio => 'Whole portfolio';

  @override
  String get alertHistory => 'Notification history';

  @override
  String get alertHistoryEmpty => 'Nothing fired yet.';

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
    return '$name $price ($chgPct) — threshold $threshold';
  }

  @override
  String get channelDigestDesc => 'Closing summary';

  @override
  String get channelPriceDesc => 'Price level hit';

  @override
  String get channelPnlDesc => 'Position P/L warning';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsBaseCurrency => 'Base currency';

  @override
  String get settingsRedIsUp => 'Red for up (TW convention)';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsWidgetRows => 'Rows in home-screen widget';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDeveloper => 'Developer';

  @override
  String get settingsRunTickNow => 'Run one heartbeat now';

  @override
  String get settingsRunTickViaScheduler => 'Run once via WorkManager';

  @override
  String get settingsTickScheduled =>
      'Queued in the background; check the last-check time.';

  @override
  String get settingsBatteryOptimization => 'Battery optimization settings';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get notifPermRationale =>
      'dQuote only notifies for alerts you create.';

  @override
  String get notifPermissionMissing =>
      'Notifications are blocked — alerts and closing digests will not arrive.';

  @override
  String get actionUnchanged => 'unchanged';
}
