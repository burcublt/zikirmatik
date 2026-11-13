// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'السبحة';

  @override
  String get loadingInfrastructure => 'جارٍ تجهيز تجربتك';

  @override
  String get screenReaderInfrastructureReady =>
      'البنية الأساسية لتطبيق السبحة جاهزة';

  @override
  String get home => 'الرئيسية';

  @override
  String get zikrs => 'الأذكار';

  @override
  String get quran => 'القرآن';

  @override
  String get statistics => 'الإحصاءات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get menu => 'القائمة';

  @override
  String get search => 'بحث';

  @override
  String get searchZikrs => 'ابحث في الأذكار';

  @override
  String get addZikr => 'إضافة ذكر';

  @override
  String get zikrName => 'اسم الذكر';

  @override
  String get arabicText => 'النص العربي';

  @override
  String get description => 'الوصف';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get selectZikr => 'اختر ذكراً';

  @override
  String get changeZikr => 'تغيير الذكر';

  @override
  String get confirmSelection => 'تأكيد الاختيار';

  @override
  String get selectedZikr => 'الذكر المختار';

  @override
  String get counter => 'العداد';

  @override
  String get target => 'الهدف';

  @override
  String get zikrTarget => 'هدف الذكر';

  @override
  String get dailyGoal => 'الهدف اليومي';

  @override
  String get dailyTotal => 'المجموع اليومي';

  @override
  String get setDailyGoal => 'تحديد الهدف اليومي';

  @override
  String get currentCount => 'العدد الحالي';

  @override
  String get today => 'اليوم';

  @override
  String get streak => 'السلسلة';

  @override
  String get days => 'أيام';

  @override
  String get total => 'المجموع';

  @override
  String get completed => 'مكتمل';

  @override
  String get counterGoalCompleted => 'اكتمل هدف الذكر';

  @override
  String get dailyGoalCompleted => 'اكتمل الهدف اليومي';

  @override
  String completionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إكمالات',
      one: 'إكمال واحد',
      zero: 'لا توجد إكمالات بعد',
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
  String get vibration => 'الاهتزاز';

  @override
  String get sound => 'الصوت';

  @override
  String get language => 'اللغة';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get myGoals => 'أهدافي';

  @override
  String get rateApp => 'قيّم التطبيق';

  @override
  String get more => 'المزيد';

  @override
  String get share => 'مشاركة';

  @override
  String get about => 'حول التطبيق';

  @override
  String get errorGeneric => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get errorSave => 'تعذر حفظ التغييرات.';

  @override
  String get errorLoad => 'تعذر تحميل البيانات.';

  @override
  String get confirmDeleteTitle => 'حذف الذكر؟';

  @override
  String get confirmDeleteMessage => 'سيُزال هذا الذكر من قائمتك.';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noZikrs => 'لم يتم العثور على أذكار.';

  @override
  String get allZikrs => 'كل الأذكار';

  @override
  String get popular => 'شائع';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب.';

  @override
  String get invalidTarget => 'أدخل هدفاً صالحاً أكبر من صفر.';

  @override
  String get tapToCount => 'انقر للعدّ';

  @override
  String get zikrSelectChange => 'اختر / غيّر الذكر';

  @override
  String get settingsShortcut => 'اختصار الإعدادات';

  @override
  String get noZikrSelected => 'لم يتم اختيار ذكر بعد';

  @override
  String get vibrationEnabled => 'الاهتزاز مفعّل';

  @override
  String get vibrationDisabled => 'الاهتزاز معطّل';

  @override
  String zikrCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أذكار',
      one: 'ذكر واحد',
      zero: 'لا أذكار بعد',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'ابحث في الأذكار...';

  @override
  String get noSearchResult => 'لم يتم العثور على نتائج.';

  @override
  String get addZikrTitle => 'ذكر جديد';

  @override
  String get editZikrTitle => 'تعديل الذكر';

  @override
  String get zikrNameHint => 'مثال: سبحان الله';

  @override
  String get targetHint => 'مثال: 33';

  @override
  String get descriptionHint => 'ملاحظة اختيارية';

  @override
  String get deleteZikrConfirm => 'هل أنت متأكد أنك تريد حذف هذا الذكر؟';

  @override
  String get builtInZikrNoDelete => 'لا يمكن حذف الأذكار المدمجة.';

  @override
  String get selectForCounting => 'اختر للعدّ';

  @override
  String get zikrAdded => 'تمت إضافة الذكر.';

  @override
  String get zikrUpdated => 'تم تحديث الذكر.';

  @override
  String get zikrDeleted => 'تم حذف الذكر.';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get allTime => 'كل الأوقات';

  @override
  String get longestStreak => 'أطول سلسلة';

  @override
  String get zikrBreakdown => 'توزيع الأذكار';

  @override
  String get noStatistics => 'لا بيانات بعد';

  @override
  String get weeklyActivity => 'النشاط الأسبوعي';

  @override
  String get monAbbr => 'إث';

  @override
  String get tueAbbr => 'ثل';

  @override
  String get wedAbbr => 'أر';

  @override
  String get thuAbbr => 'خم';

  @override
  String get friAbbr => 'جم';

  @override
  String get satAbbr => 'سب';

  @override
  String get sunAbbr => 'أح';

  @override
  String get addFavorite => 'إضافة إلى المفضلة';

  @override
  String get removeFavorite => 'إزالة من المفضلة';

  @override
  String get privacyOptions => 'خيارات خصوصية الإعلانات';

  @override
  String get daily => 'يومي';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get totalDhikr => 'مجموع الأذكار';

  @override
  String get setGoal => 'تحديد';

  @override
  String get duration => 'المدة';

  @override
  String get dhikrHistory => 'سجل الأذكار';

  @override
  String get generalSettings => 'الإعدادات العامة';

  @override
  String get theme => 'المظهر';

  @override
  String get darkTheme => 'داكن';

  @override
  String get lightTheme => 'فاتح';

  @override
  String get systemTheme => 'النظام';

  @override
  String get dailyReminder => 'تذكير يومي';

  @override
  String get reminderTime => 'وقت التذكير';

  @override
  String get application => 'التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get peacefulLife => 'لحياة مليئة بالسكينة\nالسبحة';

  @override
  String get appDescription => 'احسب أذكارك اليومية وحدد أهدافك وتابع تقدمك.';

  @override
  String get notificationPermissionRequired =>
      'اسمح بالإشعارات في إعدادات جهازك لتفعيل التذكيرات.';

  @override
  String get privacySummary =>
      'تُحفظ سجلات الأذكار والمفضلة وتفضيلات التطبيق في قاعدة بيانات محلية على جهازك. يستخدم التطبيق Google AdMob لعرض الإعلانات. قد تعالج Google معلومات الإعلانات والجهاز وفق سياسة الخصوصية الخاصة بها. عند الحاجة يمكنك تغيير خيارات خصوصية الإعلانات من الإعدادات. تُقرأ تقاويم تركيا وشمال قبرص من البيانات السنوية المحفوظة في التطبيق. للأوقات المحسوبة في البلدان الأخرى تُرسل الإحداثيات التقريبية إلى AlAdhan. تستخدم عمليات البحث عن المدن والعناوين خدمة الجهاز. يمكن جلب تحديثات التقويم بمعرّف المنطقة من خادم البيانات المحدد. تُحفظ المواقيت والموقع المختار على جهازك للاستخدام دون اتصال. لا يُتتبع الموقع في الخلفية.';

  @override
  String get googlePrivacy => 'سياسة خصوصية Google';

  @override
  String repeatCount(int count) {
    return '$count مرة';
  }

  @override
  String get prayerTimes => 'مواقيت الصلاة';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String get timeRemaining => 'متبقي';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get prayerLoading => 'جارٍ تحميل المواقيت…';

  @override
  String get prayerUseLocation => 'استخدام موقعي';

  @override
  String get prayerChooseLocation => 'اختر موقعًا للمواقيت';

  @override
  String get prayerCurrentLocation => 'موقعي';

  @override
  String get prayerSavedLocation => 'تُعرض مواقيت آخر موقع محفوظ.';

  @override
  String get prayerPermissionDenied =>
      'لم يُمنح إذن الموقع. يمكنك اختيار مدينة بدلًا من ذلك.';

  @override
  String get prayerLocationDisabled =>
      'خدمات الموقع مغلقة. فعّلها أو اختر مدينة.';

  @override
  String get prayerUnavailable =>
      'تعذر تحميل المواقيت. تحقق من الاتصال وحاول مجددًا.';

  @override
  String get prayerLocationExplanation =>
      'استخدم موقعك التقريبي أو اختر مدينة لعرض مواقيت الصلاة.';

  @override
  String get prayerChooseCity => 'اختر مدينة';

  @override
  String get prayerOpenSettings => 'فتح إعدادات الجهاز';

  @override
  String get prayerTodayDate => 'تاريخ اليوم';

  @override
  String get prayerSource => 'المصدر: AlAdhan • أوقات محسوبة';

  @override
  String get prayerCityHint => 'مثال: إسطنبول، تركيا';

  @override
  String get prayerCityNotFound =>
      'لم تُعثر على المدينة أو المواقيت. تحقق من اسم المدينة والدولة.';

  @override
  String get qibla => 'القبلة';

  @override
  String get qiblaDirection => 'اتجاه القبلة';

  @override
  String get qiblaNorthInitial => 'ش';

  @override
  String get qiblaEastInitial => 'م';

  @override
  String get qiblaSouthInitial => 'ج';

  @override
  String get qiblaWestInitial => 'غ';

  @override
  String get qiblaWaiting => 'بانتظار البوصلة…';

  @override
  String get qiblaNoSensor =>
      'بيانات البوصلة غير متاحة. قد لا يحتوي جهازك على مستشعر بوصلة.';

  @override
  String get qiblaCalibrate =>
      'حرّك هاتفك على شكل الرقم ثمانية وابتعد عن المعادن والمغناطيس.';

  @override
  String get qiblaAligned => 'أنت تواجه القبلة';

  @override
  String qiblaTurnLeft(int degrees) {
    return 'اتجه يسارًا $degrees°';
  }

  @override
  String qiblaTurnRight(int degrees) {
    return 'اتجه يمينًا $degrees°';
  }

  @override
  String get qiblaInstructions =>
      'أمسك هاتفك بشكل مسطح ووجّه حافته العلوية نحو السهم.';

  @override
  String get qiblaTrueNorth =>
      'الزاوية بالنسبة إلى الشمال الحقيقي. إرشاد البوصلة تقريبي.';

  @override
  String get qiblaUndefined => 'لا يمكن تحديد اتجاه القبلة في هذا الموقع.';

  @override
  String get prayerRegionTitle => 'اختر منطقة التقويم';

  @override
  String get prayerRegionSearch => 'ابحث عن المحافظة أو منطقة التقويم…';

  @override
  String get prayerRegionPrompt => 'اختر منطقة التقويم المطابقة لموقعك.';

  @override
  String get prayerAllProvinces => 'جميع المحافظات / المناطق';

  @override
  String get prayerInternationalCity => 'ابحث عن مدينة في بلد آخر';

  @override
  String get prayerAnnualSource => 'المصدر: تقويم ديانت • بيانات إمساكيام';

  @override
  String get prayerCalendarMissing => 'لا يوجد تقويم حديث لهذه المنطقة.';

  @override
  String get prayerRegionNoResults => 'لم يتم العثور على منطقة تقويم مطابقة.';
}
