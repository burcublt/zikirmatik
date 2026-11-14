# Zikirmatik — Tasarım ve AdMob iş listesi

Kaynak inceleme: 12 Kasım 2026. Referans: 320DEDA7-BAE8-4E93-959D-CDAE28EE36B9.PNG.
Proje: /Users/burcubalta/Desktop/development/zikirmatik.
İlk kaynak incelemesinden sonra Android emülatöründe ana sayfa açılışı ve ekran görüntüsü kontrol edildi. Tam ekran eşleştirmesi ve iOS doğrulaması henüz tamamlanmadı.

## Kapsam ve kabul koşulları

- Beş sekme: Ana Sayfa, Zikirler, Kıble, İstatistik, Ayarlar. Kur’an bu sürümde yok.
- Referansın koyu zümrüt zemini, altın çizgileri, açık yeşil tesbihi, başlıkları ve kompakt kartları hedeflenir.
- Ana sayfa ve ayarlar reklamsızdır. Geçiş veya ödüllü reklam planlanmıyor.
- Zikir listesinde 6–8 gerçek zikirden sonra native reklam. Başlangıç tercihi: 6 zikirden sonra bir reklam; bu ürün varsayımıdır.
- İstatistikte grafiğin altında, alt menünün üzerinde adaptive banner.
- Reklam kreatifindeki fotoğraf ve metin AdMob tarafından sağlanır; referanstaki reklam görseli sabit içerik olarak kopyalanmaz.
- Ekrandaki örnek sayılar gerçek kayıtlarla hesaplanır; sabit 532, %78 veya 2.5 saat gösterilmez.

## Güncel kalan işler — 14 Kasım 2026

Önceki turların ayrıntıları aşağıda tarihsel olarak korunur. Güncel dış bağımlılıklar:

- [ ] Gerçek uygulama ve AdMob yayın kimlikleri, Android upload imzası ve mağaza beyanları.
- [ ] Kullanıcının sonraya bıraktığı gizlilik URL'si ve iletişim e-postası.
- [ ] Duyurular için kullanıcının Firebase projesi, platform yapılandırmaları ve iOS APNs yetkisi.
- [ ] Kullanıcıyla fiziksel konum/kıble kalibrasyonu ve fiziksel iPhone reklam gösterimi kontrolü.
- [x] 2027 namaz takvimini edinme/doğrulama: 880 bölge, 321.200 gün; 2026 korunarak paketlendi.
- [ ] Diğer ülkelerin yerel resmî takvim sağlayıcıları.
- [ ] Takvim CDN/sunucu yayını; kullanıcının kararıyla şimdilik yalnız dağıtım ZIP'i hazır.

Bu turda reklam hata/tekrar/arka plan/kaynak temizliği tamamlandı. Eski iPhone paketi yükleme riskine karşı güncel kaynaktan Profile derlemesi yapan `scripts/build_ios_test.py` eklendi. Saat seçimi, bildirim güncellemesi ve kullanıcının diğer kaynak değişiklikleri korunur.

## Mevcut durum

Flutter + Riverpod + Drift. Sayaç, hedef, günlük kayıt, seri, zikir ekleme/düzenleme/silme ve TR/EN/AR yerelleştirmesi mevcut. Dört sekme mevcut. Başlangıçta AdMob yoktu. İlk uygulama turunda google_mobile_ads 9.2.0, Google test kimlikleri, UMP, liste içi native template ve adaptive banner eklendi.

### 1. Ortak görsel temel — başlandı

- [x] Zümrüt/altın renk paletinin ilk düzenlemesi.
- [x] Dört öğeli, altın ikonlu kompakt alt menü; seçili sekme erişilebilirlik bilgisi.
- [x] Açık yeşil boncuklar, altın imame ve yeşil püskül için ilk painter düzenlemesi; merkez sayacın hizalanması.
- [x] Ortak desenli arka plan, cami silueti, başlık fontu ve altın ayraçlar.
- [x] Ortak altın simgeler ve dairesel artı butonu; yerleşik satırlarda fazladan menü kaldırıldı, uzun basarak düzenleme korundu.
- [x] Küçük ekran, büyük yazı ve Arapça RTL kontrolü.

### 2. Ana sayfa

- [x] Başlıktaki titreşim düğmesini referanstaki artı eylemiyle değiştirme; titreşim ayarlarda kalır.
- [x] Ortadaki dokunma simgesi, sayaç ve hedef oranlarını referansla eşleştirme.
- [x] Alt zikir seçme alanını dairesel artı + açıklama olarak düzenleme.
- [x] Günlük / seri / toplam kartını referanstaki ölçülere getirme.
- [x] Reklam olmadan sayma, hedef tamamlama, yeniden açılış ve hızlı dokunma doğrulaması.

### 3. Zikirler

- [x] Kompakt satır: yuvarlak simge, ad, tekrar sayısı, favori yıldızı.
- [x] Favori alanı, repository ve veri kaybı olmadan DB migration.
- [x] Eksik hazır zikirleri ekleme: Lâ ilâhe illallah (33), Estağfirullah (100), Salavat (100).
- [x] Seed işlemini inceleme: mevcut insertOnConflictUpdate düzenlenen hazır zikirleri açılışta ezebilir; kullanıcının düzenlemeleri korunmalı.
- [x] Düzenle/sil eylemlerini koruyarak fazla seçim düğmesi ve yinelenen ekleme FAB’ını kaldırma.
- [x] Native reklamı listeye ekleme; kısa/filtrelenmiş listelerde boş reklam alanı bırakmama.

### 4. İstatistik

- [x] Günlük / haftalık / aylık dönem seçimi ve gerçek veri sorguları.
- [x] Üst halka grafik, ortada toplam; altta gün / hedef yüzdesi / süre kartları.
- [x] Günlük hedef verisini yüzde hesabına bağlama; sıfır hedef için güvenli gösterim.
- [x] Süre kaydı altyapısı: yalnız etkin sayım oturumunu ölçme; arka planda geçen zamanı saymama. Süre v4 şemasında tutulur; eski kayıtlarda 0’dan başlar.
- [x] Referanstaki altın/yeşil sütun grafik.
- [x] Pull-to-refresh düzeltmesi: mevcut onRefresh boş.
- [x] Grafikten sonra adaptive banner.

### 5. Ayarlar

- [x] Genel ayarlar: tema seçimi, ses, mevcut titreşim kontrolü.
- [x] Tema ve ses tercihlerinin kalıcı kaydı; ses oynatma altyapısı.
- [x] Günlük hatırlatma anahtarı, saat seçici, bildirim izni ve yerel bildirim planlaması.
- [ ] Gizlilik politikası ve bize ulaşın bağlantıları; gerçek URL/adres gerekli.
- [x] Hakkında alanı ve referanstaki alt mesaj.
- [x] Mevcut dil seçimini koruyarak yeni görünüme uyarlama.

### 6. AdMob altyapısı

- [x] google_mobile_ads paketini ekleme ve sürüm/platform gereksinimlerini kontrol etme.
- [x] AndroidManifest ve iOS Info.plist app ID’leri; geliştirmede Google örnek kimlikleri.
- [x] UMP akışı: her açılışta consent bilgisi güncelleme, gerekli form ve canRequestAds kontrolü.
- [x] Gerekirse Ayarlar içinde gizlilik tercihlerini yeniden açma.
- [x] SDK başlangıcını ve platform desteğini yönetme; web/masaüstünde reklam isteği yapmama.
- [x] Native kart: Android/iOS özel layout; medya, metin, çağrı düğmesi, Ad etiketi ve SDK tıklama yönetimi.
- [x] Banner: ekran genişliğine uygun adaptive boyut ve güvenli alan.
- [x] Yükleme hatasında alanı kapatma; kaynak temizliği, sınırlı tekrar deneme, arka plan ve geç yanıt yönetimi. 12 hedefli reklam testi başarılı.
- [x] Android Play Store emülatöründe ve iOS simülatöründe native/banner Google test reklamları doğrulandı.
- [ ] Fiziksel iPhone üzerinde native/banner gösterimini ayrıca doğrulama; canlı reklamlarla geliştirme testi yapılmaz.
- [ ] Yayın öncesi gerçek app ID + native/banner unit ID, AdMob gizlilik mesajı ve mağaza beyanları.

### 7. Doğrulama ve yayın

- [x] flutter analyze ve mevcut testler.
- [x] Favori migration, süre/istatistik hesapları ve reklam yerleşimi için davranış testleri.
- [ ] Android/iOS ekran görüntülerini aynı boyutta referansla karşılaştırma; henüz birebir eşleşme iddiası yok.
- [ ] Offline açılış, reklam gelmemesi, izin reddi, büyük metin, RTL ve uygulamaya geri dönüş testi.
- [ ] Gerçek Android yayın kimliği ve upload imzasını sağlama. Release debug imzası fallback kaldırıldı; doğrulama altyapısı hazır.
- [x] README ve kurulum/yayın talimatları.

## Önerilen uygulama sırası

1. Ortak görsel temel + ana sayfa.
2. Zikir listesi + favoriler + eksik hazır içerik.
3. İstatistik görünümü + eksik metrikler.
4. AdMob test entegrasyonu ve iki yerleşim.
5. Ayarlar işlevleri, cihazda görsel kontrol ve yayın hazırlığı.

Canlı AdMob kimlikleri ilk geliştirme adımını engellemez; test kimlikleriyle ilerlenebilir. Gerçek politika URL’si, iletişim adresi ve yayın kimlikleri yayın öncesinde alınmalı.

## Resmî teknik kaynaklar

- https://developers.google.com/admob/flutter/quick-start
- https://developers.google.com/admob/flutter/native/templates
- https://developers.google.com/admob/flutter/privacy

## İlk uygulama turu doğrulaması

- flutter analyze: temiz.
- 19 birim/widget testi: başarılı; favori yeniden açılışı, v2→v3 veri koruma, sayaç dokunması ve büyük metin/RTL kontrolleri dahil.
- Android debug APK: derlendi ve API 32 emülatörde açıldı.
- Native reklam şu an SDK small template kullanıyor. Referanstaki fotoğraflı özel kreatif düzeniyle birebir eşleşme tamamlanmadı.
- İstatistik ve Ayarlar içerik dönüşümü ikinci uygulama turunda tamamlandı; tam görsel eşleştirme ve iOS kontrolü ayrı doğrulama maddesi olarak sürüyor.

### Android reklam cihaz testi sonucu

- UMP canRequestAds: true.
- Banner test reklamı: cihazda başarıyla yüklendi.
- Ana sayfa/Ayarlar: AdWidget yok; navigasyon hatasız.
- Native: SDK error 0 / Internal error. Logcat: `Incorrect native ad response. Click actions were not properly specified`. Native gösterimi doğrulanmış sayılmıyor.
- AVD: API 32 google_apis, PlayStore.enabled=false. Play Store içeren Android cihaz/emülatör ile strict native entegrasyon testi tekrar çalıştırılmalı. Mevcut ortamda `integration_test/admob_smoke_test.dart` native beklentisinde başarısızdır; bu kontrol gevşetilmedi.
- iOS SDK yapılandırması eklendi, iOS derleme/cihaz doğrulaması bu turda yapılmadı.
- Benzer emülatör durumuyla ilgili SDK geliştirici desteği: https://groups.google.com/g/google-admob-ads-sdk/c/kB4itOh71Zk/m/LGJXZLdaAwAJ

## İkinci uygulama turu

- Günlük = bugün, haftalık = bugün dahil son 7 takvim günü, aylık = bu ayın başlangıcından bugüne. Gelecekteki kayıtlar hesaplara alınmaz.
- Halka ve yüzde, yalnız açıkça hedef belirlenen günlerin günlük başarılarının toplamını hedef toplamına böler; her günün başarısı kendi hedefiyle sınırlıdır. Hedefsiz günler yüzdeyi şişirmez.
- Kullanıcı İstatistik ekranından bugünün günlük hedefini değiştirebilir; zikir bazındaki tekrar hedefi ayrıdır.
- Süre: aynı gün ardışık dokunuşlar arasında 30 saniyeye kadar geçen süre. İlk dokunuş, daha uzun boşluk, sekme geçişi ve arka plan süresi sayılmaz. Eski sayımlar korunur, geçmiş süre tahmin edilmez.
- DB v3→v4: daily_activities.active_milliseconds, varsayılan 0. v2→v4 yükseltme testi eski sayımları ve zikirleri koruduğunu doğrular.
- Sayaç hedefe ulaşınca tamamlandı durumu görünür; sonraki dokunuş yeni turu 1’den başlatır. UI ve DB aynı davranır; hızlı dokunuşlar sırayla kalıcı yazılır.
- Açık/koyu/sistem temaları, yerel ses varlığı ve kalıcı tercih kaydı. Tema/ses değişikliği seçili zikri sıfırlamaz.
- Android/iOS günlük yerel bildirim hizmeti, seçilen saat, cihaz IANA saat dilimi, izin reddi yönetimi; Android’de inexactAllowWhileIdle kullanılır, işletim sistemi teslimatı seçilen saatten geciktirebilir.
- Hatırlatıcı kapanınca yalnız uygulamanın 1001 numaralı bildirimi iptal edilir. Açılışta etkin hatırlatma saat dilimi/dil için güncellenir. Android boot receiver yapılandırıldı.
- Gizlilik URL’si yoksa yerel veri işleme özeti ve Google gizlilik bağlantısı açılır. Gerçek yayın politikası bağlantısı hâlâ gereklidir. CONTACT_EMAIL verilene kadar Bize Ulaşın satırı gösterilmez; uydurma adres eklenmedi.
- 29 birim/widget testi başarılı; kod analizi temiz. Android debug APK derlendi.
- Android cihaz entegrasyon testi başarılı: gerçek sayım, günlük/haftalık/aylık seçim, açık tema ve sistemde bekleyen hatırlatma oluşturma/iptal etme.
- Örnek test verili önizlemeler: build/design-preview/statistics.png ve settings.png.
- Önceki native reklam error 0 sorunu üçüncü turda Play Store’lu emülatörde doğrulandı ve kapandı; iOS derlemesi başarılı, iOS fiziksel cihaz kontrolü yapılmadı.

## Üçüncü uygulama turu — 13 Kasım 2026

- Son seçilen zikir, UserPreferences id=4 üzerinden kalıcı. Seçim ve tekrar hedefi aynı transaction içinde kaydedilir. Yeniden açılışta aynı zikir, sayaç ve hedef yüklenir; arşivlenmiş seçim mevcutsa ilk aktif zikre dönülür.
- Arka plandan dönüşte günlük/genel toplam ve seri yenilenir. Gün değişiminde önceki günün toplamı yeni güne taşınmaz; eşzamanlı dokunuş eski yenileme sonucuyla ezilmez.
- Noto Serif uygulamaya ve lisans listesine eklendi; başlıklar cihazın font kurulumuna bağlı değil. Kaynak: https://github.com/google/fonts/tree/main/ofl/notoserif (OFL).
- Arka plan geometrisi azaltılıp yukarıdan aşağı soluklaştırıldı. Yerleşik zikir satırlarındaki üç nokta menüsü kaldırıldı; uzun basarak düzenleme sürüyor. Tekrar alt başlığı “33 defa” biçiminde.
- Native reklam: Android Kotlin ve iOS Swift fabrikaları, solda 120×120 medya, sağda başlık/ayrıntı/altın CTA, belirgin Ad etiketi. Yükseklik 132; video medyasını çok küçük alana sıkıştırmamak için referanstaki düz reklam yüksekliğinden farklıdır.
- Play Store içeren ayrı Zikirmatik_Play_API_35 emülatörü kuruldu. Strict AdMob cihaz testi başarıyla geçti: nativeLoaded=true, bannerLoaded=true, consentCanRequest=true; ana sayfa ve ayarlar reklamsız. Eski API 32 Google APIs emülatöründeki hata yeni ortamda tekrarlanmadı.
- iOS imzasız debug derlemesi başarılı; özel native reklam fabrikası Swift derlemesinden geçti. Bu, iOS fiziksel cihaz testi veya mağazaya hazır imzalı paket anlamına gelmez.
- 32 birim/widget testi başarılı; kaynak analizi temiz. Yeniden açılış ve gece yarısı için üç yeni davranış testi var.
- Kullanıcının kararı: iletişim e-postası ve gerçek gizlilik URL’si hazır olunca eklenecek; bu tur için istenmiyor.

## Yayın altyapısı turu — 13 Kasım 2026

- Kullanıcı talebi: yalnız değiştirilen işler test edilecek; tüm ekran testleri bu turda yeniden çalıştırılmadı.
- Gerçek uygulama ve AdMob kimlikleri hazır değil. `config/release.example.json`, yerel JSON akışı, Android upload imzası şablonu ve iOS xcconfig akışı hazırlandı.
- Android release için debug imzası fallback kaldırıldı. Application ID/AdMob kimlikleri ve upload anahtarı yoksa Gradle release kontrolü paketi durdurur.
- iOS Release aşaması Bundle ID/App ID ile Dart reklam kimliklerinin eşleşmesini denetler. Yerel yayın komutu yalnız paket üretir; mağazaya göndermez, yeni Apple kimliği/sertifika veya keystore oluşturmaz.
- 7 yeni yayın yapılandırması testi başarılı. Yalnız etkilenen Android/iOS native ayarlarını doğrulayan debug derlemeleri başarılı.
- Fiziksel iPhone kurulumu denendi: Apple, mevcut `com.example.zikirmatik` Bundle ID’sini bu takıma kaydetmeyi reddetti; provisioning profili yok. Yeni üretim kimliği uydurulmadı. Kayıtlı benzersiz kimlik hazır olana kadar fiziksel iPhone testi açık.
- E-posta/gizlilik URL’si kullanıcının önceki kararıyla sonraya bırakıldı.

## Namaz vakitleri — 13 Kasım 2026

- [x] Ana sayfanın üstünde sıradaki namaz ve saniyelik geri sayım kartı; “kaldı” yanında ok yok.
- [x] Karttan günlük vakitler ekranına geçiş, şehir seçimi ve konum yenileme.
- [x] Kullanıcı eylemiyle ön plan konum izni; reddetme/kalıcı ret/servis kapalı durumları.
- [x] Elle şehir seçimi ve kalıcılık; yaklaşık konum, saat dilimi ve geçerli çevrim dışı önbellek.
- [x] Yatsı sonrası ertesi gün, ay sonu ve cihazdan farklı saat dilimi kontrolleri.
- [x] TR/EN/AR metinleri ve küçük ekranda büyük yazı kontrolü.
- [x] Özelliğe özel 12 test geçti; diğer ekran testleri yeniden çalıştırılmadı. Android ve imzasız iOS debug derleme çıktıları üretildi.
- [ ] Fiziksel cihazda gerçek konum izni ve konum doğruluğu kontrolü.
- Veri kaynağı AlAdhan yöntem 13’tür; resmî Diyanet takvimiyle birebir eşleşme iddiası yoktur.

## Kıble — 13 Kasım 2026

- [x] Alt menüde bağımsız Kıble sekmesi; İstatistik/Ayarlar indisleri güncellendi.
- [x] Konuma göre Kâbe açısı, gerçek kuzey düzeltmesi ve canlı pusula.
- [x] Zümrüt/altın kadran, Kâbe simgesi, sağ/sol dönüş ve hizalama bilgisi.
- [x] Konum reddi, elle şehir seçimi, kayıtlı konum ve sensör yokluğu durumları.
- [x] Düşük doğrulukta kalibrasyon; arka planda/sekme çıkışında sensör kapatma.
- [x] Yalnız bu özelliğin 12 testi ve kod analizi başarılı; Android/iOS imzasız debug derlemeleri başarılı.
- [ ] Fiziksel telefonda pusula kalibrasyonu ve namaz/kıble konumunun doğrulanması.
- [ ] 2030 öncesi manyetik model güncellemesi; Flutter yükseltmelerinde eklentinin KGP uyumluluğu takibi.

## İl/ilçe yıllık takvime geçiş — 13 Kasım 2026

- [x] 2026 İmsakiyem/Diyanet kaynaklı veriyi doğrulama: 880 takvim bölgesi, 321.200 gün.
- [x] İstanbul/Ankara/İzmir için 1.095 resmî takvim gününün altı vaktinde eşleşme.
- [x] Bölge seçimi, paketli yıllık veri, kalıcı çevrim dışı kayıt ve eski AlAdhan kaydını ayırma.
- [x] HTTPS yıllık dosya güncelleme altyapısı, geçerli yerel veriye dönüş; Türkiye'de hesaplamaya sessiz geçiş yok.
- [x] Veri dönüştürücü ve manifest özeti doğrulayan dağıtım ZIP'i.
- [x] Kullanıcı kararı: sunucu şu an yok; yalnız yüklenmeye hazır paket hazırlanacak.
- [ ] HTTPS sunucu/CDN yayımlama ve uygulama adresini yapılandırma.
- [x] 2027 verisini edinme, doğrulama ve yerel dağıtım paketine ekleme; sunucuya yayımlama ertelendi.
- [ ] Diğer ülkelerin yerel resmî takvim sağlayıcıları; mevcut hesaplanan vakit akışı ayrı kaynak etiketiyle sürüyor.

## Son doğrulama — 14 Kasım 2026

- İlgili 27 Flutter testi ve 4 veri hazırlama testi başarılı; tüm ekran testleri çalıştırılmadı.
- Kod analizi temiz. Android debug ve imzalı iOS profile test paketleri derlendi.
- Güncel iOS paketi bağlı iPhone 14 Pro'ya kuruldu; com.burcubalta.zikirmatik.dev uygulaması başarıyla başlatıldı. Bölge seçimi ve saatlerin fiziksel ekranda kullanıcıyla kontrolü ayrıca yapılacak.
- build/prayer-data-2026.zip: 4.043.811 bayt, 884 ZIP girdisi; dosya özetleri ve ZIP bütünlüğü doğrulandı. Sunucuya yayımlanmadı.

## Reklam yaşam döngüsü ve test kurulumu — 14 Kasım 2026

- 12 reklam davranış testi başarılı: geri çekilme aralığı, deneme sınırı, kaynak temizliği, izin değişimi, arka plan, boyut değişimi, zaman aşımı ve geç yanıtlar.
- Hedefli iOS simülatör SDK testinde nativeLoaded=true, bannerLoaded=true, consentCanRequest=true. Diğer ekranlar test edilmedi.
- Güncel iPhone test paketi için kaynak özeti doğrulaması ve AOT/Profile kontrolü eklendi; 5 Python testi başarılı.
- Bu turda yalnız reklam kodu, ilgili testler, test paketleme aracı ve iş listesi/README değiştirildi.

## 2027 yıllık takvim — 14 Kasım 2026

- 2026 ve 2027 birlikte paketlenir; yıl değişimi yerel tarihle otomatik olur.
- 31 Aralık önbelleği ertesi yılın imsak vaktini içermezse yeniden yüklenir.
- Yılları birleştirme mevcut dosya özetlerini doğrular; 2026 verisini değiştirmez.
- Sağlayıcının saat dilimi etiketi tutarsızsa tüm yılın saatleri v1 yanıtıyla ayrıca karşılaştırılır; saat dönüşümü veya vakit tahmini yapılmaz.
- Yalnız yıllık veri, yıl geçişi ve ilgili paketleme kontrolleri çalıştırılır; diğer ekranlar yeniden test edilmez.
- Sunucu, gerçek uygulama/AdMob kimlikleri ve diğer yayın bilgileri kullanıcı kararıyla en sona bırakıldı.

### 2027 hedefli kontrol sonucu

- Yalnız yıllık takvim ve yıl geçişinin 14 Flutter testi ile 12 veri testi başarılı; diğer ekranlar yeniden test edilmedi.
- Değişen üç Dart dosyasının analizi temiz.
- Dağıtım: `build/prayer-data-2026-2027.zip`, 8.066.684 bayt, 1.764 ZIP girdisi; bütünlük ve manifestteki tüm özetler doğrulandı.
- 2026 bölge dosyaları ve katalog değişmedi; kullanıcının ayarlar/saat seçimi, reklam ve bildirim dosyaları korundu.
- Güncel kaynakla imzalı iOS Profile derlemesi başarılı; paketin 880 adet 2027 dosyası kaynakla birebir doğrulandı. Fiziksel iPhone erişilemediği için bu sürüm telefona kurulmadı.
