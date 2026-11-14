# Yıllık namaz takvimi verisi

## Mevcut sürüm

- Türkiye ve KKTC: İmsakiyem'in Diyanet kaynaklı olarak yayımladığı 2026 ve 2027 yıllık verileri; her yıl 880 takvim bölgesi ve 321.200 günlük kayıt (toplam 642.400 kayıt). Kaynak resmî Diyanet API'si değildir.
- İl/ilçe listesi idari ilçelerin tamamı gibi kabul edilmez. Liste, kaynakta bulunan takvim bölgelerini gösterir. GPS yalnız ülke/il/bölge adları tam ve tekil eşleşirse otomatik seçer; aksi durumda kullanıcı bölge seçer. Yakın bölge tahmini yapılmaz.
- Tüm bölgelerin 2026 ve 2027 verisi uygulamayla paketlenir; yalnız seçili bölge belleğe alınır ve yerel veritabanına kaydedilir. İki yılın bölge dosyaları yaklaşık 41 MB ham veridir; yalnız seçili bölgenin yıllık dosyası okunur.
- Yıllık kaydın tarihleri yerel takvim günü, saatleri HH:mm'dir. Türkiye Europe/Istanbul, KKTC Asia/Nicosia saat dilimindedir. Kaynaktaki gece yarısı ISO zaman damgası bir UTC vakti olarak çevrilmez.
- Diğer ülkeler için mevcut AlAdhan hesaplama yolu devam eder. Kaynak ekranda “hesaplanan vakitler” olarak ayrılır; resmî yerel takvimle eşleşme iddiası yoktur. Yeni yerel resmî sağlayıcı entegrasyonu bu turda yapılmadı.
- Eski Türkiye AlAdhan önbelleği Diyanet takvimi olarak kullanılmaz. Yıllık takvim UserPreferences id=6 içinde saklanır; veritabanı şeması değişmez.

## Kaynak ve doğrulama

Kaynak proje: https://github.com/karademirmustafa/ezanvakti-imsakiyem-api

2026 ihracı: https://github.com/karademirmustafa/ezanvakti-imsakiyem-api/releases/download/v1.0.0/prayer-times.2026.json

İndirilen ham dosyanın SHA-256 değeri:
`3daff42d5ce5e973e1566510c5145d670d7e3bce040d6bd038bd9bd954c71dc4`

Dönüştürücü her bölgede yılın tüm günlerini, artık yılı, tekil/sıralı tarihleri, altı geçerli ve sıralı saati ve ülke/il/bölge hiyerarşisini denetler. Eksik vakit veya gün tahmin etmez. 13 Kasım 2026 kontrolünde İstanbul (9541), Ankara (9206) ve İzmir (9560) yıllık resmî Diyanet tablolarının 1.095 günü/6.570 vaktiyle fark bulunmadı. Bu örnek doğrulama diğer 877 bölgenin resmî kaynakla karşılaştırıldığı anlamına gelmez. Referanslar test/fixtures/prayer_diyanet_reference_2026.json içindedir.

Kaynak lisansı SOURCE-LICENSE.txt olarak, kaynak bilgisi ATTRIBUTION.txt olarak hem uygulamada hem dağıtımda korunur. Lisans Hakkında ekranındaki lisanslar arasında da yer alır. Yazılım lisansı ile takvim verisinin ticari yeniden dağıtım koşulları ayrı değerlendirilmelidir; haricî yayın bu turda yapılmadı.

## Yeniden üretme

Ham yıllık JSON, kaynak projenin ilçe/il JSON dosyaları ve LICENSE dosyasını edindikten sonra:

```sh
python3 scripts/prepare_prayer_data.py \
  --source /dosyalar/prayer-times.2026.json \
  --districts /dosyalar/prayer-times.districts.json \
  --states /dosyalar/prayer-times.states.json \
  --license /dosyalar/LICENSE \
  --output /yeni/klasor/prayer-times
```

Çıktı klasörü yeni olmalıdır. Takvimleri doğrulamadan mevcut yayımlanmış dosyaların üzerine yazmaz. regions.json katalogdur; v1/YIL/BOLGE.json yıllık dosyalardır. manifest.json kaynak ve çıktı dosyası özetlerini içerir. Uygulamaya yeni yıl eklenirse pubspec.yaml asset dizini de eklenmelidir.

## Yüklenmeye hazır dağıtım paketi

```sh
python3 scripts/package_prayer_distribution.py
```

Komut manifest içindeki dosya özetlerini doğrular ve manifestteki yıllara göre build/prayer-data-2026-2027.zip üretir. ZIP'i açıp içeriğini HTTPS statik sunucu/CDN köküne koymak yeterlidir. Bu betik hiçbir sunucuya yükleme yapmaz. Kişisel konum, kullanıcı verisi veya anahtar içermez.

Beklenen dosya örnekleri:

- https://ornek.sunucu/namaz/regions.json
- https://ornek.sunucu/namaz/v1/2026/9541.json
- https://ornek.sunucu/namaz/manifest.json

Uygulama derlemesinde `--dart-define=PRAYER_DATA_BASE_URL=https://ornek.sunucu/namaz` kullanılır. Değer boşsa yalnız paketli takvim kullanılır. HTTP kabul edilmez. Düzeltmeler aynı yıl/bölge yoluna gelebileceği için bu dosyalara immutable cache başlığı vermeyin; örneğin sunucuda Cache-Control: public,max-age=3600 kullanılabilir.

Uygulama geçerli yerel kaydı 24 saat yeniden kullanır. Kullanıcı sayfayı aşağı çekerek yenilerse sunucu kontrolü zorlanır. Sunucu yoksa/yanıtı bozuksa aynı kaynağın paketli takvimi veya geçerli önbelleği kullanılır. Türkiye için AlAdhan'a sessiz geçiş yapılmaz. Uygulama her gelen yıllık dosyanın bölgesini, yılını, saat dilimini ve tüm günlerini doğrular.

## Sınırlar ve kalan işler

- Kullanıcının kararıyla şu an HTTPS sunucu/CDN yok; yalnız dağıtım paketi hazırlandı.
- 2026 ve 2027 paketlidir. Yıl değişimi yerel tarihle otomatik yapılır; 31 Aralık gecesinde sonraki yıl da yüklenir. 2028 verisi yoktur; mevcut olmayan gelecek yıl için vakit üretilmez.
- Yeni bölge eklenirse katalog ve uygulama varlıkları birlikte güncellenmelidir.
- İlçe takvimi seçmek fiziksel koordinat üretmez. Kıble, gerçek GPS koordinatı veya ayrıca çözülmüş şehir koordinatı kullanır; 0/0 temsili değeri pusulaya verilmez.
- Fiziksel cihazda yeni bölge seçimi kullanıcıyla ayrıca doğrulanır.

## Son doğrulama — 14 Kasım 2026

- İlgili 27 Flutter testi ve 4 veri hazırlama testi başarılı; tüm ekran testleri çalıştırılmadı.
- Kod analizi temiz. Android debug ve imzalı iOS profile test paketleri derlendi.
- Güncel iOS paketi bağlı iPhone 14 Pro'ya kuruldu; com.burcubalta.zikirmatik.dev uygulaması başarıyla başlatıldı. Bölge seçimi ve saatlerin fiziksel ekranda kullanıcıyla kontrolü ayrıca yapılacak.
- build/prayer-data-2026.zip: 4.043.811 bayt, 884 ZIP girdisi; dosya özetleri ve ZIP bütünlüğü doğrulandı. Sunucuya yayımlanmadı.

### iPhone test paketinin doğru çıktısı

Bu makinede bağımsız açılabilen son paket `build/ios/Profile-iphoneos/Runner.app` içindedir. `build/ios/iphoneos/Runner.app` altında önceki debug paketinin kalabildiği görüldü. Kurulumdan önce App.framework/flutter_assets altında kernel_blob.bin bulunmadığı ve gerçek Profile çıktısının kullanıldığı doğrulandı; 14 Kasım kurulumunda Profile-iphoneos yolu kullanıldı. Debug paketini hata ayıklayıcı olmadan açmak iOS'ta uygulamayı sonlandırır.

## 2027 güncellemesi — 14 Kasım 2026

2027 verisi, yayımlanmış `/api/v2/times?district=BOLGE&date=2027-01-01&period=yearly` yanıtlarından alındı. Eski yılın tarihleri değiştirilmedi; 2026 dosyaları aynı baytlarla korundu. Her bölgede tüm 365 tarih, altı vaktin biçimi/sırası, ülke ve bölge kimliği doğrulandı. 2026 için yukarıda belirtilen resmî Diyanet karşılaştırması, 2027 için bağımsız resmî karşılaştırma yapıldığı anlamına gelmez.

İndirme sağlayıcının 100 istek / 5 dakika sınırını korur ve kesilirse geçerli önbellekten devam eder:

```sh
python3 scripts/fetch_prayer_year.py \
  --year 2027 --catalog assets/prayer_times/regions.json \
  --cache /dosyalar/namaz-cache --output /dosyalar/prayer-times.2027.json
python3 scripts/prepare_prayer_data.py \
  --source /dosyalar/prayer-times.2027.json \
  --districts /dosyalar/prayer-times.districts.json \
  --states /dosyalar/prayer-times.states.json \
  --license /dosyalar/LICENSE \
  --merge-from assets/prayer_times --output /yeni/klasor/prayer-times
```

Bazı sınır bölgelerinde sağlayıcının coğrafi saat dilimi etiketi ülkenin takvim saat dilimiyle uyuşmaz. Böyle bir kayıt, aynı bölgenin v1 uç noktasındaki 365 günlük takviminin tamamı v2 ile birebir eşleşmeden kabul edilmez. Vakit saatleri değiştirilmez; paketli katalogdaki Türkiye/KKTC saat dilimi korunur. Karşılaştırılan ham yanıtların özetleri manifestte `upstreams.2027.timezoneCrossChecks` altında bulunur.

2027 ham veri SHA-256: `92d6f9e28415f28177ca0e73e290c9bcd939c0fc888d362db6d421e1bf3b9798`.
Sunucu/CDN ve gerçek yayın bilgileri kullanıcının kararıyla en sona bırakıldı; bu güncelleme hiçbir haricî yayın yapmaz.

### 2027 hedefli kontrol sonucu

- Yalnız yıllık takvim ve yıl geçişinin 14 Flutter testi ile 12 veri testi başarılı; diğer ekranlar yeniden test edilmedi.
- Değişen üç Dart dosyasının analizi temiz.
- Dağıtım: `build/prayer-data-2026-2027.zip`, 8.066.684 bayt, 1.764 ZIP girdisi; bütünlük ve manifestteki tüm özetler doğrulandı.
- 2026 bölge dosyaları ve katalog değişmedi; kullanıcının ayarlar/saat seçimi, reklam ve bildirim dosyaları korundu.
- Güncel kaynakla imzalı iOS Profile derlemesi başarılı; paketin 880 adet 2027 dosyası kaynakla birebir doğrulandı. Fiziksel iPhone erişilemediği için bu sürüm telefona kurulmadı.
