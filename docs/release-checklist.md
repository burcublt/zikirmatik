# Zikirmatik — Yayın hazırlığı iş listesi

Durum incelemesi: 16 Kasım 2026. Proje: `/Users/burcubalta/Desktop/development/zikirmatik`. Listenin sırası önce uygulamayı ve testleri, ardından kullanıcının daha önce sona bıraktığı sunucu ve gerçek yayın bilgilerini ele alır. Hesapların durumu konsollardan doğrulanmadı.

## Şu anda hazır olanlar

- Zikir sayacı, liste/detay, istatistik, kıble, namaz vakitleri, ayarlar ve TR/EN/AR desteği mevcut. Kur’an bu sürümde kapsam dışı.
- AdMob native/banner ve izin altyapısı test kimlikleriyle mevcut; canlı yayın hesabı ve kimlikleri ayrıca gerekli.
- Türkiye ve KKTC için 2026–2027 yıllık takvimler paketli; 2028 henüz yok. Diğer ülkeler için hesaplanan vakitler kullanılır.
- Android/iOS yayın yapılandırması ve yerel paketleme betikleri hazırlanmış; gerçek yayın dosyaları henüz yok.
- Kontrol edilen yerel Flutter varsayılanı Android API 36; makinede Xcode 27.0 var. Gerçek yayın paketleriyle yeniden doğrulanmalı.

## Sırayla yapılacaklar

### 1. Kaynak güvenliği ve durumun sabitlenmesi

- [ ] Mevcut kaydedilmemiş uygulama ve belge değişikliklerini kontrol et; kullanıcının saat seçimi ve son geliştirmelerini koru. Güvenli yedek/versionlama yöntemini kullanıcıyla belirle.
- [ ] İlk sürümün kapsamını kesinleştir: ülkeler, desteklenen diller, duyuruların ve reklamların durumu. Kur’an eklenmeyecek.

### 2. Namaz, bildirim ve kıble güvenilirliği

- [ ] Namaz hatırlatmalarını gerçek Android ve iPhone cihazda test et: izin, beş vaktin anahtarları, önceden seçilen süre, zaman dilimi, uygulama kapalıyken bildirim ve konum/takvim değişimi.
- [ ] Bildirimlerin en fazla 50 yaklaşan vakit için planlanması sorununu ürün kararıyla çöz veya bu sınırı kabul edip kullanıcıya açıkça göster. Uygulama uzun süre açılmazsa plan sonrasındaki vakitler otomatik eklenmez; Android yaklaşık zamanlı bildirimi geciktirebilir.
- [ ] Kıble için fiziksel telefonda gerçek konum, pusula kalibrasyonu, yön ve hatalı sensör/izin durumlarını doğrula.
- [ ] 2028 takvimi için veri kaynağı, güncelleme ve doğrulama sürecini planla. 2027 verisi resmî Diyanet web sitesiyle ayrıca tam kapsamlı doğrulanmış sayılmamalı.
- [ ] İmsakiyem takvim verisinin, proje GPL lisansının ve varsa diğer içerik lisanslarının uygulama ile ticari dağıtım koşullarını doğrula; gerekiyorsa hak sahibinden yetki al.
- [ ] Diğer ülkelerde yerel kaynaklar, hesaplama yöntemi/mezhep seçimi ve dakika düzeltmesi daha önce ayrıca iş listesine alındı; ilk sürüm kapsamı ve ülkeleri seçilirken karar ver.

### 3. Ürün ve mağaza görselleri

- [ ] Uygulama ikonu tasarla ve Android/iOS tüm boyutlarda uygula. İncelenen iki platformun mevcut ikonu Flutter varsayılan logosu.
- [ ] Uygulama görünen adını, açılış görselini, mağaza açıklamalarını, kategori ve yaş derecelendirmesini belirle.
- [ ] Gerçek sürümden iPhone/Android mağaza ekran görüntüleri hazırla; desteklenecek diller için metinleri gözden geçir.
- [ ] Değişen ekranları hedefli ve gerçek cihazlarda test et; küçük ekran, büyük yazı, RTL, offline, izin reddi ve yeniden açılış durumlarını gerekli kapsamda doğrula.

### 4. Gizlilik ve mağaza beyanları

- [x] Gizlilik politikası yayımlandı: https://burcublt.github.io/zikirmatik/ ; uygulamada ve yerel yayın yapılandırmasında bağlantı tanımlandı. Politikada destek e-postası yer alıyor.
- [ ] Politikayı gerçek veri işleme akışlarıyla düzelt: Türkiye dışı hesaplanan vakitlerde yaklaşık koordinatlar AlAdhan servisine gönderilir; şehir/adres çözümleme platformun konum servislerini kullanabilir. İsteğe bağlı Firebase duyuruları ve AdMob verilerinin ne şekilde işlendiğini gerçek yapılandırmaya göre açıkla. Mevcut metindeki “konum üçüncü taraflarla paylaşılmaz” ifadesi tüm kullanım senaryolarında doğru değildir.
- [ ] Güncellenen politikayı mağaza kayıtlarına ekle, destek e-postasının uygulamada gösterilip gösterilmeyeceğini belirle.
- [ ] Konum, bildirimler, AdMob, varsa Firebase ve üçüncü tarafların veri kullanımını incele; Google Play Data safety ve App Store privacy bilgilerini gerçek uygulamayla tutarlı doldur.
- [ ] AdMob/UMP mesajlarını, hedef ülkelerin izin gereksinimlerini ve varsa iOS takip izni gereksinimini seçilen reklam yapılandırmasına göre gözden geçir.
- [ ] Apple üçüncü taraf SDK privacy manifest ve imza gerekliliklerini son yayın paketinde doğrula.

### 5. Hesaplar, kimlikler ve test yayını

- [ ] Apple Developer ve Google Play Console hesaplarının üyelik/doğrulama durumunu kontrol et; hesap türü ve ilk hedef mağazaları belirle.
- [ ] Kalıcı Android application ID ve Apple takımına kayıtlı iOS Bundle ID belirle. Testte kullanılan geliştirme kimliği üretim kararı değildir.
- [ ] Android upload anahtarı ve Play App Signing akışını güvenli şekilde kur; anahtar yedeğini güvenle sakla. iOS dağıtım imzalama/profilini hazırla.
- [ ] Google Play hesabı 13 Kasım 2023 sonrası açılmış kişisel hesap ise 12 testçinin en az 14 gün sürekli katıldığı kapalı test ve üretim erişimi başvurusu gereklidir; hesabın durumunu doğrula.
- [ ] Android dahili/kapalı test ve iOS TestFlight için gerçek sürüm paketlerini hazırla. Fiziksel cihazlarda kıble, bildirim ve test reklamlarını doğrula.

### 6. Kullanıcının sona bıraktığı dış servisler ve gerçek yayın ayarları

- [ ] Alan adı/HTTPS sunucu veya CDN seç; gizlilik sayfasını, destek iletişimini ve yıllık takvim dağıtımını yayımlama hazırlıklarını yap. Takvim sunucusu olmadan 2026–2027 paketli veri çalışır, ancak sonraki yıllar için sürdürülebilir güncelleme yolu gereklidir.
- [ ] AdMob uygulamalarını ve Android/iOS native/banner reklam birimlerini oluştur; gerçek App ID ve birim kimliklerini yerel yayın yapılandırmasına ekle. Geliştirme testlerinde Google test kimlikleri kullanmaya devam et.
- [ ] Geliştirici web sitesi ve AdMob `app-ads.txt` dosyasını hesap bilgilerinden hazırlayıp mağaza kaydıyla ilişkilendir; AdMob doğrulama durumunu kontrol et.
- [ ] Duyurular ilk sürümde kullanılacaksa Firebase projesi, Android/iOS yapılandırmaları ve iOS APNs kurulumu tamamla. Kullanılmayacaksa özelliğin kullanıcıya sunuluşunu yeniden değerlendir.
- [ ] Android AAB ve iOS dağıtım paketini güncel kaynaktan oluştur; gerçek release yapılandırma, SDK/target ve imza kontrollerini yap. Android için en az API 36 ve iOS için Xcode 26/iOS 26 SDK gerekliliğini gönderim tarihinde tekrar kontrol et.
- [ ] Mağaza metinleri, ekran görüntüleri, gizlilik/yaş beyanları ve test sonuçlarını son kez kontrol et; gönderim ve yayın için kullanıcı onayından sonra konsol adımlarına geç.

## Gereken kullanıcı bilgileri — hemen gerekmiyor

- Apple/Google geliştirici hesaplarının varlığı ve Google hesabının kişisel/kurumsal türü.
- Kalıcı uygulama kimlikleri, geliştirici/şirket adı, destek e-postası ve gizlilik politikası için alan adı.
- AdMob ve Firebase hesapları/kimlikleri; Firebase duyurularının ilk sürüme dahil edilip edilmeyeceği.
- İlk sürümün ülkeleri, dilleri ve mağazaları; ikon ve mağaza görselleri tercihleri.

## Güncel mağaza kaynakları

- Android target API: https://developer.android.com/google/play/requirements/target-sdk
- Apple SDK gereklilikleri: https://developer.apple.com/news/upcoming-requirements/?id=04282026a
- Google Play kişisel hesap kapalı testi: https://support.google.com/googleplay/android-developer/answer/14151465
- Google Play veri ve gizlilik politikası: https://support.google.com/googleplay/android-developer/answer/10144311
- App Store gizlilik bilgileri: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- AdMob app-ads.txt: https://support.google.com/admob/answer/9363762
- Apple üçüncü taraf SDK gereklilikleri: https://developer.apple.com/support/third-party-SDK-requirements/
