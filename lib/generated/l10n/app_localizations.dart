import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'dQuote'**
  String get appTitle;

  /// No description provided for @tabWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get tabWatchlist;

  /// No description provided for @tabPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get tabPortfolio;

  /// No description provided for @tabAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get tabAlerts;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @fieldSymbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get fieldSymbol;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @pickSymbol.
  ///
  /// In en, this message translates to:
  /// **'Pick from watchlist'**
  String get pickSymbol;

  /// No description provided for @actionAlias.
  ///
  /// In en, this message translates to:
  /// **'Set alias'**
  String get actionAlias;

  /// No description provided for @aliasTitle.
  ///
  /// In en, this message translates to:
  /// **'Alias (display only)'**
  String get aliasTitle;

  /// No description provided for @aliasHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to use the source name'**
  String get aliasHint;

  /// No description provided for @fieldShares.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get fieldShares;

  /// No description provided for @fieldCostPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost price'**
  String get fieldCostPrice;

  /// No description provided for @fieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get fieldAmount;

  /// No description provided for @fieldCostRate.
  ///
  /// In en, this message translates to:
  /// **'Acquired rate'**
  String get fieldCostRate;

  /// No description provided for @fieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get fieldNote;

  /// No description provided for @fieldThreshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get fieldThreshold;

  /// No description provided for @labelPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get labelPrice;

  /// No description provided for @labelChange.
  ///
  /// In en, this message translates to:
  /// **'Chg'**
  String get labelChange;

  /// No description provided for @labelChangePct.
  ///
  /// In en, this message translates to:
  /// **'Chg %'**
  String get labelChangePct;

  /// No description provided for @labelMarketValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get labelMarketValue;

  /// No description provided for @labelPnl.
  ///
  /// In en, this message translates to:
  /// **'P/L'**
  String get labelPnl;

  /// No description provided for @labelPnlPct.
  ///
  /// In en, this message translates to:
  /// **'P/L %'**
  String get labelPnlPct;

  /// No description provided for @labelTotalAssets.
  ///
  /// In en, this message translates to:
  /// **'Total assets'**
  String get labelTotalAssets;

  /// No description provided for @labelSecuritiesPnl.
  ///
  /// In en, this message translates to:
  /// **'Securities P/L'**
  String get labelSecuritiesPnl;

  /// No description provided for @labelFxPnl.
  ///
  /// In en, this message translates to:
  /// **'FX P/L'**
  String get labelFxPnl;

  /// No description provided for @labelCombinedPnl.
  ///
  /// In en, this message translates to:
  /// **'Total (base ccy)'**
  String get labelCombinedPnl;

  /// No description provided for @labelAllocation.
  ///
  /// In en, this message translates to:
  /// **'Allocation'**
  String get labelAllocation;

  /// No description provided for @labelCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get labelCash;

  /// No description provided for @labelForeignCash.
  ///
  /// In en, this message translates to:
  /// **'Foreign cash'**
  String get labelForeignCash;

  /// No description provided for @labelHoldings.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get labelHoldings;

  /// No description provided for @labelBuyingPower.
  ///
  /// In en, this message translates to:
  /// **'Buying power'**
  String get labelBuyingPower;

  /// No description provided for @labelLastCheck.
  ///
  /// In en, this message translates to:
  /// **'Last check'**
  String get labelLastCheck;

  /// No description provided for @labelDelayedQuote.
  ///
  /// In en, this message translates to:
  /// **'Delayed quote'**
  String get labelDelayedQuote;

  /// No description provided for @updatedOn.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updatedOn(String time);

  /// No description provided for @ofBase.
  ///
  /// In en, this message translates to:
  /// **'{amount} ≈ {twd}'**
  String ofBase(String amount, String twd);

  /// No description provided for @range1d.
  ///
  /// In en, this message translates to:
  /// **'1D'**
  String get range1d;

  /// No description provided for @range5d.
  ///
  /// In en, this message translates to:
  /// **'5D'**
  String get range5d;

  /// No description provided for @range1m.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get range1m;

  /// No description provided for @range3m.
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get range3m;

  /// No description provided for @range1y.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get range1y;

  /// No description provided for @range5y.
  ///
  /// In en, this message translates to:
  /// **'5Y'**
  String get range5y;

  /// No description provided for @labelVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get labelVolume;

  /// No description provided for @labelCostLine.
  ///
  /// In en, this message translates to:
  /// **'Cost line'**
  String get labelCostLine;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load'**
  String get loadFailed;

  /// No description provided for @loadFailedHint.
  ///
  /// In en, this message translates to:
  /// **'Check the network, or the quote source may have changed.'**
  String get loadFailedHint;

  /// No description provided for @addInstrumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to watchlist'**
  String get addInstrumentTitle;

  /// No description provided for @addInstrumentHint.
  ///
  /// In en, this message translates to:
  /// **'2330 · TSM · NVDA · USD/TWD · ^TWII'**
  String get addInstrumentHint;

  /// No description provided for @symbolUnrecognized.
  ///
  /// In en, this message translates to:
  /// **'Unrecognized symbol'**
  String get symbolUnrecognized;

  /// No description provided for @symbolNotFound.
  ///
  /// In en, this message translates to:
  /// **'Symbol not found'**
  String get symbolNotFound;

  /// No description provided for @alreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Already in your watchlist'**
  String get alreadyAdded;

  /// No description provided for @emptyWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Tap + to add a symbol.'**
  String get emptyWatchlist;

  /// No description provided for @emptyAlerts.
  ///
  /// In en, this message translates to:
  /// **'No alert rules yet. Tap + to add one.'**
  String get emptyAlerts;

  /// No description provided for @addHoldingTitle.
  ///
  /// In en, this message translates to:
  /// **'Add holding'**
  String get addHoldingTitle;

  /// No description provided for @addCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Add cash / foreign currency'**
  String get addCashTitle;

  /// No description provided for @cashKindBroker.
  ///
  /// In en, this message translates to:
  /// **'Broker'**
  String get cashKindBroker;

  /// No description provided for @cashKindBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get cashKindBank;

  /// No description provided for @cashKindWallet.
  ///
  /// In en, this message translates to:
  /// **'Cash on hand'**
  String get cashKindWallet;

  /// No description provided for @emptyPortfolio.
  ///
  /// In en, this message translates to:
  /// **'No holdings yet.'**
  String get emptyPortfolio;

  /// No description provided for @addAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Add alert'**
  String get addAlertTitle;

  /// No description provided for @addToWidget.
  ///
  /// In en, this message translates to:
  /// **'Add to home widget'**
  String get addToWidget;

  /// No description provided for @removeFromWidget.
  ///
  /// In en, this message translates to:
  /// **'Remove from home widget'**
  String get removeFromWidget;

  /// No description provided for @addedToWidget.
  ///
  /// In en, this message translates to:
  /// **'Added to home widget'**
  String get addedToWidget;

  /// No description provided for @removedFromWidget.
  ///
  /// In en, this message translates to:
  /// **'Removed from home widget'**
  String get removedFromWidget;

  /// No description provided for @widgetRowLimit.
  ///
  /// In en, this message translates to:
  /// **'Home widget is full — raise the row limit in Settings to show this one.'**
  String get widgetRowLimit;

  /// No description provided for @alertKindClosingDigest.
  ///
  /// In en, this message translates to:
  /// **'Closing digest'**
  String get alertKindClosingDigest;

  /// No description provided for @alertKindAbove.
  ///
  /// In en, this message translates to:
  /// **'Price above'**
  String get alertKindAbove;

  /// No description provided for @alertKindBelow.
  ///
  /// In en, this message translates to:
  /// **'Price below'**
  String get alertKindBelow;

  /// No description provided for @alertKindDayChange.
  ///
  /// In en, this message translates to:
  /// **'Daily change %'**
  String get alertKindDayChange;

  /// No description provided for @alertKindPnl.
  ///
  /// In en, this message translates to:
  /// **'Position P/L %'**
  String get alertKindPnl;

  /// No description provided for @alertKindFx.
  ///
  /// In en, this message translates to:
  /// **'FX breaks level'**
  String get alertKindFx;

  /// No description provided for @alertEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get alertEnabled;

  /// No description provided for @alertScopeSingle.
  ///
  /// In en, this message translates to:
  /// **'This symbol'**
  String get alertScopeSingle;

  /// No description provided for @alertScopePortfolio.
  ///
  /// In en, this message translates to:
  /// **'Whole portfolio'**
  String get alertScopePortfolio;

  /// No description provided for @alertHistory.
  ///
  /// In en, this message translates to:
  /// **'Notification history'**
  String get alertHistory;

  /// No description provided for @alertHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing fired yet.'**
  String get alertHistoryEmpty;

  /// No description provided for @alertFiredAt.
  ///
  /// In en, this message translates to:
  /// **'{time} · {value}'**
  String alertFiredAt(String time, String value);

  /// No description provided for @alertTriggeredBody.
  ///
  /// In en, this message translates to:
  /// **'{name} {price} ({chgPct}) — threshold {threshold}'**
  String alertTriggeredBody(
    String name,
    String price,
    String chgPct,
    String threshold,
  );

  /// No description provided for @channelDigestDesc.
  ///
  /// In en, this message translates to:
  /// **'Closing summary'**
  String get channelDigestDesc;

  /// No description provided for @channelPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price level hit'**
  String get channelPriceDesc;

  /// No description provided for @channelPnlDesc.
  ///
  /// In en, this message translates to:
  /// **'Position P/L warning'**
  String get channelPnlDesc;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsBaseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get settingsBaseCurrency;

  /// No description provided for @settingsRedIsUp.
  ///
  /// In en, this message translates to:
  /// **'Red for up (TW convention)'**
  String get settingsRedIsUp;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsWidgetRows.
  ///
  /// In en, this message translates to:
  /// **'Rows in home-screen widget'**
  String get settingsWidgetRows;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsDeveloper;

  /// No description provided for @settingsRunTickNow.
  ///
  /// In en, this message translates to:
  /// **'Run one heartbeat now'**
  String get settingsRunTickNow;

  /// No description provided for @settingsRunTickViaScheduler.
  ///
  /// In en, this message translates to:
  /// **'Run once via WorkManager'**
  String get settingsRunTickViaScheduler;

  /// No description provided for @settingsTickScheduled.
  ///
  /// In en, this message translates to:
  /// **'Queued in the background; check the last-check time.'**
  String get settingsTickScheduled;

  /// No description provided for @settingsBatteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Battery optimization settings'**
  String get settingsBatteryOptimization;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @notifPermRationale.
  ///
  /// In en, this message translates to:
  /// **'dQuote only notifies for alerts you create.'**
  String get notifPermRationale;

  /// No description provided for @notifPermissionMissing.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked — alerts and closing digests will not arrive.'**
  String get notifPermissionMissing;

  /// No description provided for @actionUnchanged.
  ///
  /// In en, this message translates to:
  /// **'unchanged'**
  String get actionUnchanged;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
