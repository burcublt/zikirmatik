// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Zikirmatik';

  @override
  String get loadingInfrastructure => 'Deneyiminiz hazırlanıyor';

  @override
  String get screenReaderInfrastructureReady => 'Zikirmatik altyapısı hazır';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get zikrs => 'Zikirler';

  @override
  String get quran => 'Kur\'an';

  @override
  String get statistics => 'İstatistik';

  @override
  String get settings => 'Ayarlar';

  @override
  String get menu => 'Menü';

  @override
  String get search => 'Ara';

  @override
  String get searchZikrs => 'Zikirlerde ara';

  @override
  String get addZikr => 'Zikir ekle';

  @override
  String get zikrName => 'Zikir adı';

  @override
  String get arabicText => 'Arapça metin';

  @override
  String get description => 'Açıklama';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get selectZikr => 'Zikir seç';

  @override
  String get changeZikr => 'Zikir değiştir';

  @override
  String get confirmSelection => 'Seçimi onayla';

  @override
  String get selectedZikr => 'Seçili zikir';

  @override
  String get counter => 'Sayaç';

  @override
  String get target => 'Hedef';

  @override
  String get zikrTarget => 'Zikir hedefi';

  @override
  String get dailyGoal => 'Günlük hedef';

  @override
  String get dailyTotal => 'Günlük toplam';

  @override
  String get setDailyGoal => 'Günlük hedef belirle';

  @override
  String get currentCount => 'Mevcut sayı';

  @override
  String get today => 'Bugün';

  @override
  String get streak => 'Seri';

  @override
  String get days => 'gün';

  @override
  String get total => 'Toplam';

  @override
  String get completed => 'Tamamlandı';

  @override
  String get counterGoalCompleted => 'Zikir hedefi tamamlandı';

  @override
  String get dailyGoalCompleted => 'Günlük hedef tamamlandı';

  @override
  String completionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tamamlanma',
      one: '1 tamamlanma',
      zero: 'Henüz tamamlanma yok',
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
  String get vibration => 'Titreşim';

  @override
  String get sound => 'Ses';

  @override
  String get language => 'Dil';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get reminders => 'Hatırlatmalar';

  @override
  String get myGoals => 'Hedeflerim';

  @override
  String get rateApp => 'Değerlendir';

  @override
  String get more => 'Daha fazla';

  @override
  String get share => 'Paylaş';

  @override
  String get about => 'Hakkında';

  @override
  String get errorGeneric => 'Bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get errorSave => 'Değişiklikleriniz kaydedilemedi.';

  @override
  String get errorLoad => 'Verileriniz yüklenemedi.';

  @override
  String get confirmDeleteTitle => 'Zikir silinsin mi?';

  @override
  String get confirmDeleteMessage => 'Bu zikir listenizden kaldırılacak.';

  @override
  String get confirm => 'Onayla';

  @override
  String get close => 'Kapat';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get noZikrs => 'Zikir bulunamadı.';

  @override
  String get allZikrs => 'Tüm zikirler';

  @override
  String get popular => 'Popüler';

  @override
  String get fieldRequired => 'Bu alan zorunludur.';

  @override
  String get invalidTarget => 'Sıfırdan büyük geçerli bir hedef girin.';

  @override
  String get tapToCount => 'Saymak için dokun';

  @override
  String get zikrSelectChange => 'Zikir seç / değiştir';

  @override
  String get settingsShortcut => 'Ayarlar kısayolu';

  @override
  String get noZikrSelected => 'Henüz zikir seçilmedi';

  @override
  String get vibrationEnabled => 'Titreşim açık';

  @override
  String get vibrationDisabled => 'Titreşim kapalı';

  @override
  String zikrCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zikir',
      one: '1 zikir',
      zero: 'Henüz zikir yok',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Zikirlerde ara...';

  @override
  String get noSearchResult => 'Arama sonucu bulunamadı.';

  @override
  String get addZikrTitle => 'Yeni Zikir';

  @override
  String get editZikrTitle => 'Zikir Düzenle';

  @override
  String get zikrNameHint => 'Örn: Sübhanallah';

  @override
  String get targetHint => 'Örn: 33';

  @override
  String get descriptionHint => 'İsteğe bağlı açıklama';

  @override
  String get deleteZikrConfirm =>
      'Bu zikri silmek istediğinizden emin misiniz?';

  @override
  String get builtInZikrNoDelete => 'Yerleşik zikirler silinemez.';

  @override
  String get selectForCounting => 'Saymak için seç';

  @override
  String get zikrAdded => 'Zikir eklendi.';

  @override
  String get zikrUpdated => 'Zikir güncellendi.';

  @override
  String get zikrDeleted => 'Zikir silindi.';

  @override
  String get thisWeek => 'Bu Hafta';

  @override
  String get thisMonth => 'Bu Ay';

  @override
  String get allTime => 'Tüm Zamanlar';

  @override
  String get longestStreak => 'En Uzun Seri';

  @override
  String get zikrBreakdown => 'Zikir Dağılımı';

  @override
  String get noStatistics => 'Henüz veri yok';

  @override
  String get weeklyActivity => 'Haftalık Aktivite';

  @override
  String get monAbbr => 'Pzt';

  @override
  String get tueAbbr => 'Sal';

  @override
  String get wedAbbr => 'Çar';

  @override
  String get thuAbbr => 'Per';

  @override
  String get friAbbr => 'Cum';

  @override
  String get satAbbr => 'Cmt';

  @override
  String get sunAbbr => 'Paz';

  @override
  String get addFavorite => 'Favorilere ekle';

  @override
  String get removeFavorite => 'Favorilerden çıkar';

  @override
  String get privacyOptions => 'Reklam gizlilik tercihleri';

  @override
  String get daily => 'Günlük';

  @override
  String get weekly => 'Haftalık';

  @override
  String get monthly => 'Aylık';

  @override
  String get totalDhikr => 'Toplam Zikir';

  @override
  String get setGoal => 'Belirle';

  @override
  String get duration => 'Süre';

  @override
  String get dhikrHistory => 'Zikir Geçmişi';

  @override
  String get generalSettings => 'Genel Ayarlar';

  @override
  String get theme => 'Tema';

  @override
  String get darkTheme => 'Koyu';

  @override
  String get lightTheme => 'Açık';

  @override
  String get systemTheme => 'Sistem';

  @override
  String get dailyReminder => 'Günlük Hatırlatma';

  @override
  String get reminderTime => 'Hatırlatma Saati';

  @override
  String get application => 'Uygulama';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get contactUs => 'Bize Ulaşın';

  @override
  String get peacefulLife => 'Huzur dolu bir yaşam için\nZikirmatik';

  @override
  String get appDescription =>
      'Günlük zikirlerinizi sayın, hedeflerinizi belirleyin ve ilerlemenizi takip edin.';

  @override
  String get notificationPermissionRequired =>
      'Hatırlatma için cihaz ayarlarından bildirim izni vermelisiniz.';

  @override
  String get privacySummary =>
      'Zikir kayıtlarınız, favorileriniz ve uygulama tercihleriniz cihazınızdaki yerel veritabanında saklanır. Uygulama reklam göstermek için Google AdMob kullanır. Google, reklam ve cihaz bilgilerini kendi gizlilik politikası kapsamında işleyebilir. Gerektiğinde reklam gizlilik tercihlerinizi Ayarlar ekranından değiştirebilirsiniz. Türkiye ve KKTC takvimleri cihazdaki yıllık veri setinden okunur. Diğer ülkelerde hesaplanan vakitler için yaklaşık koordinatlar AlAdhan servisine gönderilir. Şehir ve adres sorguları cihazın konum/adres hizmetini kullanır. Takvim güncellemeleri yapılandırılmış veri sunucusundan bölge kimliğiyle alınabilir. Alınan vakitler ve seçtiğiniz konum çevrim dışı kullanım için cihazda saklanır. Konum arka planda takip edilmez.';

  @override
  String get googlePrivacy => 'Google Gizlilik Politikası';

  @override
  String repeatCount(int count) {
    return '$count defa';
  }

  @override
  String get prayerTimes => 'Namaz Vakitleri';

  @override
  String get nextPrayer => 'Sıradaki Namaz';

  @override
  String get timeRemaining => 'kaldı';

  @override
  String get prayerFajr => 'İmsak';

  @override
  String get prayerSunrise => 'Güneş';

  @override
  String get prayerDhuhr => 'Öğle';

  @override
  String get prayerAsr => 'İkindi';

  @override
  String get prayerMaghrib => 'Akşam';

  @override
  String get prayerIsha => 'Yatsı';

  @override
  String get prayerLoading => 'Vakitler yükleniyor…';

  @override
  String get prayerUseLocation => 'Konumu kullan';

  @override
  String get prayerChooseLocation => 'Vakitler için konum seçin';

  @override
  String get prayerCurrentLocation => 'Konumum';

  @override
  String get prayerSavedLocation =>
      'Son kayıtlı konumun vakitleri gösteriliyor.';

  @override
  String get prayerPermissionDenied =>
      'Konum izni verilmedi. Şehir seçerek de vakitleri görebilirsiniz.';

  @override
  String get prayerLocationDisabled =>
      'Konum servisi kapalı. Servisi açabilir veya şehir seçebilirsiniz.';

  @override
  String get prayerUnavailable =>
      'Vakitler alınamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get prayerLocationExplanation =>
      'Namaz vakitleri için yaklaşık konumunuzu kullanabilir veya şehir seçebilirsiniz.';

  @override
  String get prayerChooseCity => 'Şehir seç';

  @override
  String get prayerOpenSettings => 'Cihaz ayarlarını aç';

  @override
  String get prayerTodayDate => 'Bugünün Tarihi';

  @override
  String get prayerSource => 'Kaynak: AlAdhan • Hesaplanan vakitler';

  @override
  String get prayerCityHint => 'Örn. İstanbul, Türkiye';

  @override
  String get prayerCityNotFound =>
      'Şehir bulunamadı veya vakitler alınamadı. Şehir ve ülke adını kontrol edin.';

  @override
  String get qibla => 'Kıble';

  @override
  String get qiblaDirection => 'Kıble Yönü';

  @override
  String get qiblaNorthInitial => 'K';

  @override
  String get qiblaEastInitial => 'D';

  @override
  String get qiblaSouthInitial => 'G';

  @override
  String get qiblaWestInitial => 'B';

  @override
  String get qiblaWaiting => 'Pusula bekleniyor…';

  @override
  String get qiblaNoSensor =>
      'Pusula verisi alınamıyor. Cihazınızda pusula sensörü olmayabilir.';

  @override
  String get qiblaCalibrate =>
      'Telefonunuzu sekiz çizerek hareket ettirin. Metal ve mıknatıslardan uzaklaşın.';

  @override
  String get qiblaAligned => 'Kıble yönündesiniz';

  @override
  String qiblaTurnLeft(int degrees) {
    return 'Sola $degrees° dönün';
  }

  @override
  String qiblaTurnRight(int degrees) {
    return 'Sağa $degrees° dönün';
  }

  @override
  String get qiblaInstructions =>
      'Telefonunuzu düz tutun ve üst kenarını ok yönüne çevirin.';

  @override
  String get qiblaTrueNorth =>
      'Açı gerçek kuzeye göredir. Pusula ölçümü yaklaşık bir yönlendirmedir.';

  @override
  String get qiblaUndefined => 'Bu konumda kıble yönü hesaplanamıyor.';

  @override
  String get prayerRegionTitle => 'Takvim bölgesi seç';

  @override
  String get prayerRegionSearch => 'İl veya takvim bölgesi ara…';

  @override
  String get prayerRegionPrompt =>
      'Konumunuzla eşleşen takvim bölgesini seçin.';

  @override
  String get prayerAllProvinces => 'Tüm iller / bölgeler';

  @override
  String get prayerInternationalCity => 'Diğer ülkelerde şehir ara';

  @override
  String get prayerAnnualSource =>
      'Kaynak: Diyanet takvimi • İmsakiyem veri seti';

  @override
  String get prayerCalendarMissing => 'Bu bölge için güncel takvim bulunamadı.';

  @override
  String get prayerRegionNoResults => 'Eşleşen takvim bölgesi bulunamadı.';
}
