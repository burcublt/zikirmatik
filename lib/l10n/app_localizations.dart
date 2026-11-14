import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('tr'),
    Locale('en'),
    Locale('ar'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Zikirmatik'**
  String get appTitle;

  /// Infrastructure loading text
  ///
  /// In en, this message translates to:
  /// **'Preparing your experience'**
  String get loadingInfrastructure;

  /// Accessibility label for the startup screen
  ///
  /// In en, this message translates to:
  /// **'Zikirmatik infrastructure is ready'**
  String get screenReaderInfrastructureReady;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Zikrs navigation label
  ///
  /// In en, this message translates to:
  /// **'Zikrs'**
  String get zikrs;

  /// Quran navigation label
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran;

  /// Statistics navigation label
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Settings navigation label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Menu label
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Search action
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Zikr search hint
  ///
  /// In en, this message translates to:
  /// **'Search zikrs'**
  String get searchZikrs;

  /// Add zikr action
  ///
  /// In en, this message translates to:
  /// **'Add zikr'**
  String get addZikr;

  /// Zikr name field label
  ///
  /// In en, this message translates to:
  /// **'Zikr name'**
  String get zikrName;

  /// Arabic text field label
  ///
  /// In en, this message translates to:
  /// **'Arabic text'**
  String get arabicText;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Select zikr action
  ///
  /// In en, this message translates to:
  /// **'Select zikr'**
  String get selectZikr;

  /// Change zikr action
  ///
  /// In en, this message translates to:
  /// **'Change zikr'**
  String get changeZikr;

  /// Selection confirmation title
  ///
  /// In en, this message translates to:
  /// **'Confirm selection'**
  String get confirmSelection;

  /// Selected zikr label
  ///
  /// In en, this message translates to:
  /// **'Selected zikr'**
  String get selectedZikr;

  /// Counter label
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// Target label
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// Target for a single zikr
  ///
  /// In en, this message translates to:
  /// **'Zikr target'**
  String get zikrTarget;

  /// Daily total goal
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoal;

  /// Daily total count
  ///
  /// In en, this message translates to:
  /// **'Daily total'**
  String get dailyTotal;

  /// Set daily goal action
  ///
  /// In en, this message translates to:
  /// **'Set daily goal'**
  String get setDailyGoal;

  /// Current counter value
  ///
  /// In en, this message translates to:
  /// **'Current count'**
  String get currentCount;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Streak label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Days unit
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Completion status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Counter goal completion message
  ///
  /// In en, this message translates to:
  /// **'Zikr target completed'**
  String get counterGoalCompleted;

  /// Daily goal completion message
  ///
  /// In en, this message translates to:
  /// **'Daily goal completed'**
  String get dailyGoalCompleted;

  /// Plural completion count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No completions yet} =1{1 completion} other{{count} completions}}'**
  String completionCount(int count);

  /// Locale-formatted counter value
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String formattedCount(int count);

  /// Locale-formatted date
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String formattedDate(DateTime date);

  /// Vibration setting
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// Sound setting
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Turkish language name
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// Reminders menu item
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// My goals menu item
  ///
  /// In en, this message translates to:
  /// **'My goals'**
  String get myGoals;

  /// Rate app menu item
  ///
  /// In en, this message translates to:
  /// **'Rate app'**
  String get rateApp;

  /// More menu item
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Share menu item
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Save error message
  ///
  /// In en, this message translates to:
  /// **'Your changes could not be saved.'**
  String get errorSave;

  /// Load error message
  ///
  /// In en, this message translates to:
  /// **'Your data could not be loaded.'**
  String get errorLoad;

  /// Delete confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete zikr?'**
  String get confirmDeleteTitle;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'This zikr will be removed from your list.'**
  String get confirmDeleteMessage;

  /// Confirm action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Close action
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Empty zikrs state
  ///
  /// In en, this message translates to:
  /// **'No zikrs found.'**
  String get noZikrs;

  /// All zikrs filter
  ///
  /// In en, this message translates to:
  /// **'All zikrs'**
  String get allZikrs;

  /// Popular filter
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// Required field validation
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// Target validation
  ///
  /// In en, this message translates to:
  /// **'Enter a valid target greater than zero.'**
  String get invalidTarget;

  /// No description provided for @tapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap to count'**
  String get tapToCount;

  /// No description provided for @zikrSelectChange.
  ///
  /// In en, this message translates to:
  /// **'Select / change zikr'**
  String get zikrSelectChange;

  /// No description provided for @settingsShortcut.
  ///
  /// In en, this message translates to:
  /// **'Settings shortcut'**
  String get settingsShortcut;

  /// No description provided for @noZikrSelected.
  ///
  /// In en, this message translates to:
  /// **'No zikr selected yet'**
  String get noZikrSelected;

  /// No description provided for @vibrationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Vibration on'**
  String get vibrationEnabled;

  /// No description provided for @vibrationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Vibration off'**
  String get vibrationDisabled;

  /// No description provided for @zikrCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No zikrs yet} =1{1 zikr} other{{count} zikrs}}'**
  String zikrCount(num count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search zikrs...'**
  String get searchHint;

  /// No description provided for @noSearchResult.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noSearchResult;

  /// No description provided for @addZikrTitle.
  ///
  /// In en, this message translates to:
  /// **'New Zikr'**
  String get addZikrTitle;

  /// No description provided for @editZikrTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Zikr'**
  String get editZikrTitle;

  /// No description provided for @zikrNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Subhanallah'**
  String get zikrNameHint;

  /// No description provided for @targetHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. 33'**
  String get targetHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get descriptionHint;

  /// No description provided for @deleteZikrConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this zikr?'**
  String get deleteZikrConfirm;

  /// No description provided for @builtInZikrNoDelete.
  ///
  /// In en, this message translates to:
  /// **'Built-in zikrs cannot be deleted.'**
  String get builtInZikrNoDelete;

  /// No description provided for @selectForCounting.
  ///
  /// In en, this message translates to:
  /// **'Select for counting'**
  String get selectForCounting;

  /// No description provided for @zikrAdded.
  ///
  /// In en, this message translates to:
  /// **'Zikr added.'**
  String get zikrAdded;

  /// No description provided for @zikrUpdated.
  ///
  /// In en, this message translates to:
  /// **'Zikr updated.'**
  String get zikrUpdated;

  /// No description provided for @zikrDeleted.
  ///
  /// In en, this message translates to:
  /// **'Zikr deleted.'**
  String get zikrDeleted;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No description provided for @zikrBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Zikr Breakdown'**
  String get zikrBreakdown;

  /// No description provided for @noStatistics.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noStatistics;

  /// No description provided for @weeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get weeklyActivity;

  /// No description provided for @monAbbr.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monAbbr;

  /// No description provided for @tueAbbr.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tueAbbr;

  /// No description provided for @wedAbbr.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wedAbbr;

  /// No description provided for @thuAbbr.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thuAbbr;

  /// No description provided for @friAbbr.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friAbbr;

  /// No description provided for @satAbbr.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get satAbbr;

  /// No description provided for @sunAbbr.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunAbbr;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @privacyOptions.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy options'**
  String get privacyOptions;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @totalDhikr.
  ///
  /// In en, this message translates to:
  /// **'Total Dhikr'**
  String get totalDhikr;

  /// No description provided for @setGoal.
  ///
  /// In en, this message translates to:
  /// **'Set goal'**
  String get setGoal;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @dhikrHistory.
  ///
  /// In en, this message translates to:
  /// **'Dhikr History'**
  String get dhikrHistory;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive app announcements'**
  String get pushNotificationsDescription;

  /// No description provided for @pushSetupRequired.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not connected to a Firebase project yet. Complete the setup steps in the README.'**
  String get pushSetupRequired;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @application.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @peacefulLife.
  ///
  /// In en, this message translates to:
  /// **'For a peaceful life\nZikirmatik'**
  String get peacefulLife;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Count your daily dhikr, set goals and track your progress.'**
  String get appDescription;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications in your device settings to enable them.'**
  String get notificationPermissionRequired;

  /// No description provided for @privacySummary.
  ///
  /// In en, this message translates to:
  /// **'Your dhikr records, favorites and app preferences are stored in a local database on your device. If you enable announcements, Firebase Cloud Messaging processes your device\'s notification token to deliver them. The app uses Google AdMob to display ads. Google may process advertising and device information under its own privacy policy. When required, you can change ad privacy options in Settings. Türkiye and Northern Cyprus timetables are read from the bundled annual dataset. For calculated times in other countries, approximate coordinates are sent to AlAdhan. City and address lookups use the device’s location/address service. Timetable updates can be fetched by region ID from the configured data server. Prayer times and your chosen location are saved on your device for offline use. Your location is not tracked in the background.'**
  String get privacySummary;

  /// No description provided for @googlePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Google Privacy Policy'**
  String get googlePrivacy;

  /// No description provided for @repeatCount.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String repeatCount(int count);

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayer;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get timeRemaining;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @prayerLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading prayer times…'**
  String get prayerLoading;

  /// No description provided for @prayerUseLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get prayerUseLocation;

  /// No description provided for @prayerChooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose a location for times'**
  String get prayerChooseLocation;

  /// No description provided for @prayerCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get prayerCurrentLocation;

  /// No description provided for @prayerSavedLocation.
  ///
  /// In en, this message translates to:
  /// **'Showing times for the last saved location.'**
  String get prayerSavedLocation;

  /// No description provided for @prayerPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. You can select a city instead.'**
  String get prayerPermissionDenied;

  /// No description provided for @prayerLocationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are off. Enable them or select a city.'**
  String get prayerLocationDisabled;

  /// No description provided for @prayerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Prayer times could not be loaded. Check your connection and try again.'**
  String get prayerUnavailable;

  /// No description provided for @prayerLocationExplanation.
  ///
  /// In en, this message translates to:
  /// **'Use your approximate location or select a city to see prayer times.'**
  String get prayerLocationExplanation;

  /// No description provided for @prayerChooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose city'**
  String get prayerChooseCity;

  /// No description provided for @prayerOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open device settings'**
  String get prayerOpenSettings;

  /// No description provided for @prayerTodayDate.
  ///
  /// In en, this message translates to:
  /// **'Today’s Date'**
  String get prayerTodayDate;

  /// No description provided for @prayerSource.
  ///
  /// In en, this message translates to:
  /// **'Source: AlAdhan • Calculated times'**
  String get prayerSource;

  /// No description provided for @prayerCityHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Istanbul, Turkey'**
  String get prayerCityHint;

  /// No description provided for @prayerCityNotFound.
  ///
  /// In en, this message translates to:
  /// **'City not found or times unavailable. Check the city and country name.'**
  String get prayerCityNotFound;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// No description provided for @qiblaNorthInitial.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get qiblaNorthInitial;

  /// No description provided for @qiblaEastInitial.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get qiblaEastInitial;

  /// No description provided for @qiblaSouthInitial.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get qiblaSouthInitial;

  /// No description provided for @qiblaWestInitial.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get qiblaWestInitial;

  /// No description provided for @qiblaWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for compass…'**
  String get qiblaWaiting;

  /// No description provided for @qiblaNoSensor.
  ///
  /// In en, this message translates to:
  /// **'Compass data is unavailable. Your device may not have a compass sensor.'**
  String get qiblaNoSensor;

  /// No description provided for @qiblaCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Move your phone in a figure eight. Move away from metal and magnets.'**
  String get qiblaCalibrate;

  /// No description provided for @qiblaAligned.
  ///
  /// In en, this message translates to:
  /// **'You are facing the Qibla'**
  String get qiblaAligned;

  /// No description provided for @qiblaTurnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn left {degrees}°'**
  String qiblaTurnLeft(int degrees);

  /// No description provided for @qiblaTurnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn right {degrees}°'**
  String qiblaTurnRight(int degrees);

  /// No description provided for @qiblaInstructions.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone flat and turn its top edge toward the arrow.'**
  String get qiblaInstructions;

  /// No description provided for @qiblaTrueNorth.
  ///
  /// In en, this message translates to:
  /// **'Bearing is relative to true north. Compass guidance is approximate.'**
  String get qiblaTrueNorth;

  /// No description provided for @qiblaUndefined.
  ///
  /// In en, this message translates to:
  /// **'Qibla direction cannot be determined at this location.'**
  String get qiblaUndefined;

  /// No description provided for @prayerRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select timetable region'**
  String get prayerRegionTitle;

  /// No description provided for @prayerRegionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search province or timetable region…'**
  String get prayerRegionSearch;

  /// No description provided for @prayerRegionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select the timetable region for your location.'**
  String get prayerRegionPrompt;

  /// No description provided for @prayerAllProvinces.
  ///
  /// In en, this message translates to:
  /// **'All provinces / regions'**
  String get prayerAllProvinces;

  /// No description provided for @prayerInternationalCity.
  ///
  /// In en, this message translates to:
  /// **'Search a city in another country'**
  String get prayerInternationalCity;

  /// No description provided for @prayerAnnualSource.
  ///
  /// In en, this message translates to:
  /// **'Source: Diyanet timetable • İmsakiyem dataset'**
  String get prayerAnnualSource;

  /// No description provided for @prayerCalendarMissing.
  ///
  /// In en, this message translates to:
  /// **'No current timetable is available for this region.'**
  String get prayerCalendarMissing;

  /// No description provided for @prayerRegionNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching timetable region found.'**
  String get prayerRegionNoResults;
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
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
