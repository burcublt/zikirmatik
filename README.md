# Zikirmatik

Flutter / Riverpod / Drift tabanlı, çevrim dışı zikir sayacı. TR, EN ve AR dilleri desteklenir. Bu sürümde Kur’an bölümü yoktur.

## Çalıştırma

```sh
flutter pub get
flutter run
```

Veritabanı veya çeviri kaynakları değişirse:

```sh
flutter pub run build_runner build
flutter gen-l10n
```

## Reklam yerleşimi

- Ana Sayfa ve Ayarlar: reklam yok.
- Zikirler: en az altı sonuç olduğunda altıncı zikrin ardından bir native reklam.
- İstatistik: haftalık grafikten sonra adaptive banner.
- Geliştirme derlemeleri Google test reklam kimliklerini kullanır.
- UMP her açılışta güncellenir; yalnız `canRequestAds` izin verdiğinde SDK başlatılır ve reklam istenir.
- Gerekli olduğunda Ayarlar içindeki reklam gizlilik tercihleri bağlantısı gösterilir.
- Reklam yüklenmezse boş kutu bırakılmaz. Web ve masaüstünde reklam isteği yapılmaz.

## Yerel yayın yapılandırması

Gerçek yayın kimlikleri henüz tanımlı değil; debug geliştirme derlemeleri Google test kimlikleriyle çalışır.

1. `config/release.example.json` dosyasını `config/release.local.json` olarak kopyalayın ve ilgili platformun gerçek uygulama/AdMob kimliklerini doldurun. Gizlilik URL’si ve iletişim e-postası daha sonra eklenebilir.
2. Android için `android/key.properties.example` dosyasını `android/key.properties` olarak kopyalayıp mevcut upload keystore bilgilerini girin. Yeni anahtar otomatik oluşturulmaz. `storeFile`, android dizinine göre göreli veya mutlak yoldur.
3. Girdi kontrolü için:

```sh
python3 scripts/build_release.py --platform android --check-only
python3 scripts/build_release.py --platform ios --check-only
```

4. Yerel paket üretimi için:

```sh
python3 scripts/build_release.py --platform android
python3 scripts/build_release.py --platform ios
```

Flutter PATH içinde değilse `--flutter /tam/yol/flutter` ekleyin. Bu komutlar mağazaya yükleme yapmaz.

Android yapılandırması applicationId ve AdMob App ID’yi aynı JSON dosyasından okur. Release, debug anahtarıyla imzalanmaz. Doğrudan Flutter/Gradle ile release derlemesi başlatılsa bile eksik veya örnek kimlikleri `validateReleaseConfiguration` durdurur.

iOS yayın komutu JSON içindeki Bundle ID/App ID’den `ios/Flutter/Release.generated.xcconfig` dosyasını üretir. Xcode Release aşaması bu native değerlerin Dart yapılandırmasıyla eşleşmesini denetler. İmzalama ve Apple takımına kayıtlı Bundle ID ayrıca gereklidir. İmzalama sertifikası veya kimlik sahipliği yerel biçim kontrolüyle doğrulanmaz.

`release.local.json`, `key.properties`, keystore ve oluşturulan yerel xcconfig dosyaları gitignore kapsamındadır. JSON dosyasına şifre veya imza anahtarı koymayın.

### iPhone geliştirme kimliği

Telefon testi için `com.burcubalta.zikirmatik.dev` geliştirme kimliği mevcut Apple takımına kaydedildi; imzalı debug paket bağlı iPhone 14 Pro’ya başarıyla kuruldu. Yerel `ios/Flutter/Environment.local.xcconfig` bu kimliği kullanır ve gitignore kapsamındadır. Üretim kimliği hâlâ ayrıca seçilecektir. Başka bir Mac’te `.example` dosyasından yerel yapılandırma oluşturun.

## Yalnız yayın altyapısının testleri

```sh
python3 -B -m unittest discover -s tests/release -p test_release_config.py -v
```

Bu komut ekranları test etmez; yalnız yayın kimliklerini, imzalama alanlarını ve iOS yapılandırma eşleşmesini kontrol eder.

## Kontroller

```sh
flutter analyze
flutter test
flutter test integration_test/admob_smoke_test.dart -d emulator-5554
```

Entegrasyon testi internet, Google Play Services ve Play Store bulunan bir Android cihaz/emülatör gerektirir; gerçek SDK test reklamlarının yüklenmesini doğrular. API 32 Google APIs emülatöründe native SDK error 0 döndürür. Play Store içeren Zikirmatik_Play_API_35 emülatöründe hem native hem banner strict entegrasyon testi başarıyla doğrulandı.

macOS üzerinde gerçek fontlarla ana sayfa önizlemesi üretmek için:

```sh
flutter test test/design/home_design_test.dart --dart-define=UPDATE_PREVIEWS=true
```

Çıktı: `build/design-preview/home.png`. Bu önizleme örnek test verileri kullanır; uygulama gerçek kayıtları gösterir.

Ayrıntılı yapılacaklar: [Tasarım ve AdMob iş listesi](docs/design-admob-backlog.md).

Teknik kaynaklar: [Kurulum](https://developers.google.com/admob/flutter/quick-start), [Native](https://developers.google.com/admob/flutter/native/templates), [Banner](https://developers.google.com/admob/flutter/banner), [UMP](https://developers.google.com/admob/flutter/privacy).

## İstatistik, tema ve hatırlatmalar

- Günlük / son 7 gün / bu ay filtreleri gerçek yerel kayıtlarla hesaplanır.
- Günlük hedef İstatistik sayfasından belirlenir. Hedefsiz günler başarı yüzdesine katılmaz.
- Aktif süre yalnız ardışık sayımlar arasında ölçülür; 30 saniyeden uzun boşluklar ve arka planda geçen süreler dışlanır. Geçmişe dönük süre üretilmez.
- Açık, koyu ve sistem temaları; kalıcı ses/titreşim tercihleri desteklenir.
- Android/iOS hatırlatmaları cihazın yerel IANA saat dilimine göre günlük planlanır. Android bildirimi yaklaşık zamanlıdır; sistem geciktirebilir.
- İzin yalnız hatırlatma açılırken istenir; reddedilirse tercih kapalı kalır.
- Yayın bağlantıları için `--dart-define=PRIVACY_POLICY_URL=https://...` ve `--dart-define=CONTACT_EMAIL=...` verin. URL yoksa yerel gizlilik özeti açılır; e-posta yoksa iletişim satırı gösterilmez.

## Uzaktan duyurular (Firebase Cloud Messaging)

Duyurular özelliği Android ve iOS'ta, kullanıcı Ayarlar > Hatırlatmalar bölümündeki **Duyurular** anahtarını açınca izin ister ve cihazı `announcements` konusuna abone eder. Firebase Console'da yeni bildirim oluştururken konu (`announcements`) hedeflenebilir. Uygulama açıkken de bildirim gösterilir; kapalıyken sistem bildirimi gösterir.

Firebase projesi bu depoya bağlı değildir. Bildirimleri etkinleştirmeden önce:

1. Firebase Console'da proje oluşturup Android uygulamasını `com.example.zikirmatik` geliştirme kimliğiyle ve iOS uygulamasını kullandığınız Bundle ID ile kaydedin. Yayın kimlikleri değişirse Firebase'e yayın kimliklerini de ekleyin.
2. FlutterFire CLI ile platform yapılandırmalarını ekleyin: `dart pub global activate flutterfire_cli` ve `flutterfire configure --project=<firebase-project-id>`. iOS için Firebase Console'da APNs anahtarını da yükleyin ve Xcode'da Push Notifications yeteneğini etkinleştirin.
3. Uygulamayı Android/iOS cihazda çalıştırın, Duyurular anahtarını açıp izin verin. Firebase Console'dan `announcements` konusuna test bildirimi gönderin.

Firebase yapılandırması yoksa uygulama mevcut özelliklerle çalışmaya devam eder; Duyurular anahtarını açma girişimi kurulum yönergesini gösterir. FCM, Firebase'in fiyatlandırmasında ücretsiz üründür; Console'dan elle gönderim için bu projede sunucu veya Cloud Functions gerekmez.

Android emülatörü API 32 üzerinde yeni özelliklerin testi:

```sh
flutter test integration_test/statistics_settings_smoke_test.dart -d emulator-5554
```

Bu test gerçek bildirim planlama/iptali, gerçek sayım, dönem seçimi ve tema değişimini kontrol eder. Test bir kez sayacı artırır. Android 13+ cihazda bildirim izni sistem arayüzünden verilmelidir.

İstatistik/Ayarlar örnek verili ekran önizlemeleri:

```sh
flutter test test/design/statistics_settings_design_test.dart --dart-define=UPDATE_PREVIEWS=true
```

Çıktılar `build/design-preview/statistics.png` ve `build/design-preview/settings.png`. iOS tarafının derleme ve cihaz doğrulaması hâlâ yapılmalıdır.

## Görsel ve devamlılık doğrulaması

- Son seçilen zikir ve kendi tekrar hedefi uygulama yeniden açıldığında korunur.
- Günlük toplam gece yarısında ve uygulamaya geri dönünce yenilenir.
- Başlık fontu Noto Serif, OFL lisansıyla `assets/fonts` altında; lisans Hakkında menüsünden görülebilir.
- Native reklam özel `zikrCard` fabrikasıyla Android ve iOS üzerinde oluşturulur; kreatif ve tıklamalar SDK’ya aittir.
- Play Store’lu yeni emülatör üzerinde reklam testi için cihaz kimliğini `flutter devices` ile bulun; mevcut kurulumda `emulator-5556`:

```sh
flutter test integration_test/admob_smoke_test.dart -d emulator-5556
```

iOS için `flutter build ios --debug --no-codesign` başarılıdır; imzalama ve fiziksel iOS cihaz kontrolleri yayından önce ayrıca tamamlanmalıdır.

## Namaz vakitleri

Türkiye ve KKTC için 2026 ve 2027 yıllık Diyanet kaynaklı takvimler, İmsakiyem verisinden doğrulanıp uygulamaya eklendi. Her yıl 880 takvim bölgesini kapsar. İl/takvim bölgesi seçimi ve vakitler internet olmadan çalışır. GPS bölge adlarıyla tam eşleşmezse kullanıcı seçim yapar; rastgele yakın bölge seçilmez. Eski AlAdhan Türkiye kayıtları bu takvimle karıştırılmaz.

Ana sayfanın üst kartı sıradaki namazı ve geri sayımı gösterir; “kaldı” yanında ok yoktur. Kart günlük altı vakit listesine açılır. Diğer ülkelerde mevcut AlAdhan hesaplanan vakit yolu sürer ve kaynak ayrı belirtilir.

- iOS konum derlemesi için `BYPASS_PERMISSION_LOCATION_ALWAYS=1` kullanılır.
- Konum izni yalnız kullanıcı eylemiyle istenir. Elle takvim seçimi konum iznine bağlı değildir.
- 2026 korunur; yerel tarih 2027 olduğunda 2027 takvimi otomatik kullanılır. 31 Aralık gecesi ertesi yılın imsak vakti de yüklenir. Olmayan 2028 takvimi tahmin edilmez.
- Şu an sunucu/CDN yok. `build/prayer-data-2026-2027.zip` HTTPS statik barındırmaya hazırdır; henüz yayımlanmadı.
- Sunucu hazır olduğunda `--dart-define=PRAYER_DATA_BASE_URL=https://...` ile yıllık güncelleme açılabilir. Varsayılan paketli takvimdir.

Yalnız ilgili kontroller:

```sh
flutter test test/features/prayer_times test/features/qibla/qibla_location_test.dart
python3 -B -m unittest discover -s tests/prayer_data -v
python3 scripts/package_prayer_distribution.py
```

Kaynak, doğrulama, dağıtım ve yeni yıl güncelleme adımları: [Yıllık takvim verisi](docs/prayer-data.md).

## Kıble

Alt menü: Ana Sayfa / Zikirler / Kıble / İstatistik / Ayarlar. Kıble ekranı yaklaşık konumdan Kâbe'ye büyük çember başlangıç açısını hesaplar. Telefon pusulasının manyetik yönü `true_compass` paketinin çevrim dışı WMM2025 modeliyle gerçek kuzeye çevrilir; ekranın üst kenarı yön referansıdır. [Paket ve platform belgeleri](https://pub.dev/packages/true_compass).

- Konum izni açılışta istenmez; “Konumu kullan” eylemiyle istenir. Namaz ekranındaki elle şehir seçimi korunur. Kayıtlı konuma dönülürse kullanıcıya belirtilir. Kıble hesabı namaz API yanıtına bağlı değildir.
- Yüksek sensör doğruluğunda ±5° içinde hizalama gösterilir; diğer doğruluklarda kalibrasyon istenir. Sensör bulunmazsa veya sekiz saniye geçerli veri gelmezse hata ve tekrar deneme görünür; sahte pusula değeri gösterilmez.
- Arka plana geçince ve sekmeden ayrılınca pusula aboneliği kapanır. Yeni arka plan konumu veya izin eklenmedi.
- WMM2025 modeli 2030 başına kadar geçerlidir. Model süresi bitince yön gösterimi durur; model/paket yayından sonra güncel tutulmalıdır. Android derlemesi başarılıdır; eklentinin Kotlin Gradle geçiş uyarısı gelecekteki Flutter yükseltmelerinde takip edilmelidir.

Yalnız bu özelliğin kontrolleri:

```sh
flutter test test/features/qibla
```

12 hedefli test başarılı; Android ve imzasız iOS debug derlemesi başarılı. Gerçek telefonun pusula sensörü, manyetik etkileşim ve yön doğruluğu fiziksel cihazda ayrıca doğrulanmalıdır. Önizleme testi örnek İstanbul konumu ve sensör verisi kullanır; gerçek ölçüm değildir.

## Reklam hataları ve iPhone test paketi

- Başarısız reklam alanı tamamen kapanır; ilk isteğin ardından en fazla üç yeniden deneme 30 / 60 / 120 saniye bekler.
- Arka planda reklam isteği yapılmaz. Geri dönüşte en az 30 saniyelik istek aralığı korunur. Ekran kapatılınca ve reklam izni kalkınca istek, zamanlayıcı ve kaynaklar bırakılır. Geç yanıt yeni reklamın durumunu değiştirmez.
- Başarılı banner için uygulama ek yenileme başlatmaz; varsa SDK'nın kendi yenilemesi sürer. Yükleme/hazırlık yanıtı 25 saniyede gelmezse alan kapatılıp aynı sınırlı hata akışı kullanılır.

Yalnız bu değişiklikleri doğrulamak için:

```sh
flutter test test/core/ads/ad_slot_lifecycle_test.dart
flutter test integration_test/ad_slot_smoke_test.dart -d TEST_CIHAZI
python3 -B -m unittest discover -s tests/ios_test_build -v
```

SDK testi yalnız native/banner bileşenlerini açar; diğer uygulama ekranlarını dolaşmaz, reklamları tıklamaz ve Google test kimliklerini zorunlu tutar. 14 Kasım 2026'da iOS simülatöründe ikisi de yüklendi. Fiziksel iOS reklam gösterimi ayrıca doğrulanmalıdır.

Eski iPhone paketi kurulumunu önlemek için güncel kaynaktan derleyen komut:

```sh
python3 scripts/build_ios_test.py --flutter /tam/yol/flutter
python3 scripts/build_ios_test.py --flutter /tam/yol/flutter --device IPHONE_UDID
```

İlk komut yalnız Profile test paketi üretir; ikinci komut belirtilen telefona kurup açar. Kaynak/varlık özeti derlemenin öncesinde ve sonrasında karşılaştırılır; değişiklik olursa kurulum durur. Debug snapshot ve simülatör paketleri fiziksel telefona kurulmaz. `build/ios/test-build.json` kaynak özeti, kullanılan paket yolu ve derleme bilgilerini tutar. Mağazaya yükleme yapılmaz; release yapılandırması değiştirilmez.
