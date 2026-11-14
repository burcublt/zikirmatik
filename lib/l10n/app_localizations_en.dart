// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zikirmatik';

  @override
  String get loadingInfrastructure => 'Preparing your experience';

  @override
  String get screenReaderInfrastructureReady =>
      'Zikirmatik infrastructure is ready';

  @override
  String get home => 'Home';

  @override
  String get zikrs => 'Zikrs';

  @override
  String get quran => 'Quran';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get menu => 'Menu';

  @override
  String get search => 'Search';

  @override
  String get searchZikrs => 'Search zikrs';

  @override
  String get addZikr => 'Add zikr';

  @override
  String get zikrName => 'Zikr name';

  @override
  String get arabicText => 'Arabic text';

  @override
  String get description => 'Description';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get selectZikr => 'Select zikr';

  @override
  String get changeZikr => 'Change zikr';

  @override
  String get confirmSelection => 'Confirm selection';

  @override
  String get selectedZikr => 'Selected zikr';

  @override
  String get counter => 'Counter';

  @override
  String get target => 'Target';

  @override
  String get zikrTarget => 'Zikr target';

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String get dailyTotal => 'Daily total';

  @override
  String get setDailyGoal => 'Set daily goal';

  @override
  String get currentCount => 'Current count';

  @override
  String get today => 'Today';

  @override
  String get streak => 'Streak';

  @override
  String get days => 'days';

  @override
  String get total => 'Total';

  @override
  String get completed => 'Completed';

  @override
  String get counterGoalCompleted => 'Zikr target completed';

  @override
  String get dailyGoalCompleted => 'Daily goal completed';

  @override
  String completionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completions',
      one: '1 completion',
      zero: 'No completions yet',
    );
    return '$_temp0';
  }

  @override
  String formattedCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString';
  }

  @override
  String formattedDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get vibration => 'Vibration';

  @override
  String get sound => 'Sound';

  @override
  String get language => 'Language';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get reminders => 'Reminders';

  @override
  String get myGoals => 'My goals';

  @override
  String get rateApp => 'Rate app';

  @override
  String get more => 'More';

  @override
  String get share => 'Share';

  @override
  String get about => 'About';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorSave => 'Your changes could not be saved.';

  @override
  String get errorLoad => 'Your data could not be loaded.';

  @override
  String get confirmDeleteTitle => 'Delete zikr?';

  @override
  String get confirmDeleteMessage =>
      'This zikr will be removed from your list.';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get noZikrs => 'No zikrs found.';

  @override
  String get allZikrs => 'All zikrs';

  @override
  String get popular => 'Popular';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get invalidTarget => 'Enter a valid target greater than zero.';

  @override
  String get tapToCount => 'Tap to count';

  @override
  String get zikrSelectChange => 'Select / change zikr';

  @override
  String get settingsShortcut => 'Settings shortcut';

  @override
  String get noZikrSelected => 'No zikr selected yet';

  @override
  String get vibrationEnabled => 'Vibration on';

  @override
  String get vibrationDisabled => 'Vibration off';

  @override
  String zikrCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zikrs',
      one: '1 zikr',
      zero: 'No zikrs yet',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Search zikrs...';

  @override
  String get noSearchResult => 'No results found.';

  @override
  String get addZikrTitle => 'New Zikr';

  @override
  String get editZikrTitle => 'Edit Zikr';

  @override
  String get zikrNameHint => 'E.g. Subhanallah';

  @override
  String get targetHint => 'E.g. 33';

  @override
  String get descriptionHint => 'Optional note';

  @override
  String get deleteZikrConfirm => 'Are you sure you want to delete this zikr?';

  @override
  String get builtInZikrNoDelete => 'Built-in zikrs cannot be deleted.';

  @override
  String get selectForCounting => 'Select for counting';

  @override
  String get zikrAdded => 'Zikr added.';

  @override
  String get zikrUpdated => 'Zikr updated.';

  @override
  String get zikrDeleted => 'Zikr deleted.';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get allTime => 'All Time';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get zikrBreakdown => 'Zikr Breakdown';

  @override
  String get noStatistics => 'No data yet';

  @override
  String get weeklyActivity => 'Weekly Activity';

  @override
  String get monAbbr => 'Mon';

  @override
  String get tueAbbr => 'Tue';

  @override
  String get wedAbbr => 'Wed';

  @override
  String get thuAbbr => 'Thu';

  @override
  String get friAbbr => 'Fri';

  @override
  String get satAbbr => 'Sat';

  @override
  String get sunAbbr => 'Sun';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get privacyOptions => 'Ad privacy options';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get totalDhikr => 'Total Dhikr';

  @override
  String get setGoal => 'Set goal';

  @override
  String get duration => 'Duration';

  @override
  String get dhikrHistory => 'Dhikr History';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get theme => 'Theme';

  @override
  String get darkTheme => 'Dark';

  @override
  String get lightTheme => 'Light';

  @override
  String get systemTheme => 'System';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get pushNotifications => 'Announcements';

  @override
  String get pushNotificationsDescription => 'Receive app announcements';

  @override
  String get pushSetupRequired =>
      'Notifications are not connected to a Firebase project yet. Complete the setup steps in the README.';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get application => 'Application';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get peacefulLife => 'For a peaceful life\nZikirmatik';

  @override
  String get appDescription =>
      'Count your daily dhikr, set goals and track your progress.';

  @override
  String get notificationPermissionRequired =>
      'Allow notifications in your device settings to enable them.';

  @override
  String get privacySummary =>
      'Your dhikr records, favorites and app preferences are stored in a local database on your device. If you enable announcements, Firebase Cloud Messaging processes your device\'s notification token to deliver them. The app uses Google AdMob to display ads. Google may process advertising and device information under its own privacy policy. When required, you can change ad privacy options in Settings. Türkiye and Northern Cyprus timetables are read from the bundled annual dataset. For calculated times in other countries, approximate coordinates are sent to AlAdhan. City and address lookups use the device’s location/address service. Timetable updates can be fetched by region ID from the configured data server. Prayer times and your chosen location are saved on your device for offline use. Your location is not tracked in the background.';

  @override
  String get googlePrivacy => 'Google Privacy Policy';

  @override
  String repeatCount(int count) {
    return '$count times';
  }

  @override
  String get prayerTimes => 'Prayer Times';

  @override
  String get nextPrayer => 'Next Prayer';

  @override
  String get timeRemaining => 'remaining';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerLoading => 'Loading prayer times…';

  @override
  String get prayerUseLocation => 'Use my location';

  @override
  String get prayerChooseLocation => 'Choose a location for times';

  @override
  String get prayerCurrentLocation => 'My location';

  @override
  String get prayerSavedLocation =>
      'Showing times for the last saved location.';

  @override
  String get prayerPermissionDenied =>
      'Location permission was denied. You can select a city instead.';

  @override
  String get prayerLocationDisabled =>
      'Location services are off. Enable them or select a city.';

  @override
  String get prayerUnavailable =>
      'Prayer times could not be loaded. Check your connection and try again.';

  @override
  String get prayerLocationExplanation =>
      'Use your approximate location or select a city to see prayer times.';

  @override
  String get prayerChooseCity => 'Choose city';

  @override
  String get prayerOpenSettings => 'Open device settings';

  @override
  String get prayerTodayDate => 'Today’s Date';

  @override
  String get prayerSource => 'Source: AlAdhan • Calculated times';

  @override
  String get prayerCityHint => 'E.g. Istanbul, Turkey';

  @override
  String get prayerCityNotFound =>
      'City not found or times unavailable. Check the city and country name.';

  @override
  String get qibla => 'Qibla';

  @override
  String get qiblaDirection => 'Qibla Direction';

  @override
  String get qiblaNorthInitial => 'N';

  @override
  String get qiblaEastInitial => 'E';

  @override
  String get qiblaSouthInitial => 'S';

  @override
  String get qiblaWestInitial => 'W';

  @override
  String get qiblaWaiting => 'Waiting for compass…';

  @override
  String get qiblaNoSensor =>
      'Compass data is unavailable. Your device may not have a compass sensor.';

  @override
  String get qiblaCalibrate =>
      'Move your phone in a figure eight. Move away from metal and magnets.';

  @override
  String get qiblaAligned => 'You are facing the Qibla';

  @override
  String qiblaTurnLeft(int degrees) {
    return 'Turn left $degrees°';
  }

  @override
  String qiblaTurnRight(int degrees) {
    return 'Turn right $degrees°';
  }

  @override
  String get qiblaInstructions =>
      'Hold your phone flat and turn its top edge toward the arrow.';

  @override
  String get qiblaTrueNorth =>
      'Bearing is relative to true north. Compass guidance is approximate.';

  @override
  String get qiblaUndefined =>
      'Qibla direction cannot be determined at this location.';

  @override
  String get prayerRegionTitle => 'Select timetable region';

  @override
  String get prayerRegionSearch => 'Search province or timetable region…';

  @override
  String get prayerRegionPrompt =>
      'Select the timetable region for your location.';

  @override
  String get prayerAllProvinces => 'All provinces / regions';

  @override
  String get prayerInternationalCity => 'Search a city in another country';

  @override
  String get prayerAnnualSource =>
      'Source: Diyanet timetable • İmsakiyem dataset';

  @override
  String get prayerCalendarMissing =>
      'No current timetable is available for this region.';

  @override
  String get prayerRegionNoResults => 'No matching timetable region found.';
}
