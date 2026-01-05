import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wealth Calculator'**
  String get appTitle;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @prices.
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get prices;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @totalWealth.
  ///
  /// In en, this message translates to:
  /// **'Total Wealth'**
  String get totalWealth;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @commodities.
  ///
  /// In en, this message translates to:
  /// **'Commodities'**
  String get commodities;

  /// No description provided for @stocks.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get stocks;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @addNewItem.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addNewItem;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @currentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Price'**
  String get currentPrice;

  /// No description provided for @highest.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get highest;

  /// No description provided for @lowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get lowest;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @selectGold.
  ///
  /// In en, this message translates to:
  /// **'Select Gold'**
  String get selectGold;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @priorities.
  ///
  /// In en, this message translates to:
  /// **'Sort by Priority'**
  String get priorities;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'Sort by Date'**
  String get sortByDate;

  /// No description provided for @sortByAmount.
  ///
  /// In en, this message translates to:
  /// **'Sort by Amount'**
  String get sortByAmount;

  /// No description provided for @unpaidInvoices.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Invoices'**
  String get unpaidInvoices;

  /// No description provided for @paidInvoices.
  ///
  /// In en, this message translates to:
  /// **'Paid Invoices'**
  String get paidInvoices;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @marketData.
  ///
  /// In en, this message translates to:
  /// **'Market Data'**
  String get marketData;

  /// No description provided for @calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// No description provided for @wealthCalculator.
  ///
  /// In en, this message translates to:
  /// **'Wealth Calculator'**
  String get wealthCalculator;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoiceTitle;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @importance.
  ///
  /// In en, this message translates to:
  /// **'Importance'**
  String get importance;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @addAsset.
  ///
  /// In en, this message translates to:
  /// **'Add Asset'**
  String get addAsset;

  /// No description provided for @totalAssets.
  ///
  /// In en, this message translates to:
  /// **'Total Assets'**
  String get totalAssets;

  /// No description provided for @assetHistory.
  ///
  /// In en, this message translates to:
  /// **'Asset History'**
  String get assetHistory;

  /// No description provided for @assetDistribution.
  ///
  /// In en, this message translates to:
  /// **'Asset Distribution'**
  String get assetDistribution;

  /// No description provided for @goldPrices.
  ///
  /// In en, this message translates to:
  /// **'Gold Prices'**
  String get goldPrices;

  /// No description provided for @currencyPrices.
  ///
  /// In en, this message translates to:
  /// **'Currency Prices'**
  String get currencyPrices;

  /// No description provided for @stocksBist.
  ///
  /// In en, this message translates to:
  /// **'BIST 100 Index'**
  String get stocksBist;

  /// No description provided for @commoditiesPrices.
  ///
  /// In en, this message translates to:
  /// **'Commodities Prices'**
  String get commoditiesPrices;

  /// No description provided for @portfolioIndividual.
  ///
  /// In en, this message translates to:
  /// **'Personal Portfolio'**
  String get portfolioIndividual;

  /// No description provided for @swipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get swipe;

  /// No description provided for @milyar.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get milyar;

  /// No description provided for @milyon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get milyon;

  /// No description provided for @bin.
  ///
  /// In en, this message translates to:
  /// **'K'**
  String get bin;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
