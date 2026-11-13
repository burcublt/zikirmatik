# Yıllık namaz takvimi verisi

## Mevcut sürüm

- Türkiye ve KKTC: İmsakiyem'in Diyanet kaynaklı olarak yayımladığı 2026 yıllık veri seti, 880 takvim bölgesi ve 321.200 günlük kayıt. Kaynak resmî Diyanet API'si değildir.
- İl/ilçe listesi idari ilçelerin tamamı gibi kabul edilmez. Liste, kaynakta bulunan takvim bölgelerini gösterir. GPS yalnız ülke/il/bölge adları tam ve tekil eşleşirse otomatik seçer; aksi durumda kullanıcı bölge seçer. Yakın bölge tahmini yapılmaz.
- Tüm bölgelerin 2026 verisi uygulamayla paketlenir; yalnız seçili bölge belleğe alınır ve yerel veritabanına kaydedilir. İlk uygulama paketinde yaklaşık 20,5 MB ham veri bulunur; statik dağıtım ZIP'i yaklaşık 3,9 MB'dır.
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

Komut manifest içindeki dosya özetlerini doğrular ve build/prayer-data-2026.zip üretir. ZIP'i açıp içeriğini HTTPS statik sunucu/CDN köküne koymak yeterlidir. Bu betik hiçbir sunucuya yükleme yapmaz. Kişisel konum, kullanıcı verisi veya anahtar içermez.

Beklenen dosya örnekleri:

- https://ornek.sunucu/namaz/regions.json
- https://ornek.sunucu/namaz/v1/2026/9541.json
- https://ornek.sunucu/namaz/manifest.json

Uygulama derlemesinde `--dart-define=PRAYER_DATA_BASE_URL=https://ornek.sunucu/namaz` kullanılır. Değer boşsa yalnız paketli takvim kullanılır. HTTP kabul edilmez. Düzeltmeler aynı yıl/bölge yoluna gelebileceği için bu dosyalara immutable cache başlığı vermeyin; örneğin sunucuda Cache-Control: public,max-age=3600 kullanılabilir.

Uygulama geçerli yerel kaydı 24 saat yeniden kullanır. Kullanıcı sayfayı aşağı çekerek yenilerse sunucu kontrolü zorlanır. Sunucu yoksa/yanıtı bozuksa aynı kaynağın paketli takvimi veya geçerli önbelleği kullanılır. Türkiye için AlAdhan'a sessiz geçiş yapılmaz. Uygulama her gelen yıllık dosyanın bölgesini, yılını, saat dilimini ve tüm günlerini doğrular.

## Sınırlar ve kalan işler

- Kullanıcının kararıyla şu an HTTPS sunucu/CDN yok; yalnız dağıtım paketi hazırlandı.
- Yalnız 2026 yılı mevcut. 2027 verisi edinilip doğrulanmadan gelecek yıl vakitleri üretilmez. 31 Aralık yatsısından sonra gelecek imsak yoksa geri sayım yerine takvim bulunamadı bilgisi gösterilir.
- Yeni bölge eklenirse katalog ve uygulama varlıkları birlikte güncellenmelidir.
- İlçe takvimi seçmek fiziksel koordinat üretmez. Kıble, gerçek GPS koordinatı veya ayrıca çözülmüş şehir koordinatı kullanır; 0/0 temsili değeri pusulaya verilmez.
- Fiziksel cihazda yeni bölge seçimi kullanıcıyla ayrıca doğrulanır.
