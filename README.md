# Kişisel Şifre ve Hesap Kasası

Bu proje, Flutter ve Dart kullanılarak geliştirilmiş kişisel bir şifre ve hesap kasası uygulamasıdır. Uygulamanın temel amacı, kullanıcıların farklı dijital platformlara ait hesap bilgilerini cihaz yerelinde, düzenli ve çevrimdışı olarak saklayabilmesini sağlamaktır.

## Projenin Amacı

Günümüzde kullanıcılar birçok farklı platform için kullanıcı adı, e-posta, şifre ve bağlantı bilgisi kullanmaktadır. Bu bilgilerin dağınık şekilde tutulması hem güvenlik hem de kullanım kolaylığı açısından sorun oluşturabilir.

Bu uygulama, kullanıcının hesap bilgilerini tek bir merkezde saklamasını ve gerektiğinde hızlıca erişmesini sağlar. Ayrıca şifre sağlığı analizi, güçlü şifre üretici, güvenlik panosu ve kasa şifresiyle giriş gibi özelliklerle klasik bir kayıt uygulamasından daha kapsamlı bir güvenlik aracı hâline getirilmiştir.

## Özellikler

- Kasa şifresi ile giriş sistemi
- Kurtarma kelimesi ile kasa şifresi sıfırlama
- Hesap ekleme, düzenleme ve silme
- Platform adı, kullanıcı adı/e-posta, şifre, URL ve kategori kaydetme
- Kategori destekli hesap yönetimi
- Hesap arama ve filtreleme
- Güçlü şifre üretici
- Şifre gösterme/gizleme
- Şifreyi panoya kopyalama
- Şifre sağlık analizi
- Zayıf, orta ve güçlü şifre değerlendirmesi
- Aynı şifrenin tekrar kullanılıp kullanılmadığını kontrol etme
- Güvenlik panosu
- Şifre geçmişi
- Oluşturulma ve son güncelleme tarihi takibi
- Açık/koyu tema desteği
- Çevrimdışı kullanım
- Cihaz yerelinde veri saklama

## Kullanılan Teknolojiler

- Flutter
- Dart
- Provider
- ChangeNotifier
- shared_preferences
- Material Design
- Clipboard API
- TextFormField ve Form Validation
- AlertDialog
- ListView

## Mimari Yapı

Uygulama temel olarak üç katmandan oluşmaktadır.

### Model Katmanı

Hesap bilgileri `Account` modeli ile temsil edilir. Bu modelde platform adı, kullanıcı adı, şifre, URL, kategori, oluşturulma tarihi, son güncelleme tarihi ve şifre geçmişi gibi bilgiler tutulur.

### View Katmanı

Kullanıcının gördüğü ekranlardan oluşur. Kasa giriş ekranı, kasa kurulum ekranı, şifre sıfırlama ekranı, ana sayfa ve hesap ekleme/düzenleme ekranı bu katmanda yer alır.

### Logic & State Katmanı

Uygulama durum yönetimi `Provider` ve `ChangeNotifier` ile sağlanır. Hesap ekleme, silme, güncelleme, arama, güvenlik panosu oluşturma ve yerel veri kaydetme işlemleri `AccountProvider` sınıfı üzerinden yönetilir.

## Çevrimdışı Kullanım

Uygulama internet bağlantısına ihtiyaç duymadan çalışacak şekilde tasarlanmıştır. Hesap bilgileri `shared_preferences` ile cihaz yerelinde saklanır. Bu sayede kullanıcı internet bağlantısı olmasa bile uygulamaya erişebilir ve kayıtlı hesaplarını görüntüleyebilir.

## Özgün Özellikler

### Güvenlik Panosu

Ana ekranda bulunan güvenlik panosu, kayıtlı hesapların genel güvenlik durumunu analiz eder. Toplam hesap sayısı, güçlü şifre sayısı, zayıf şifre sayısı ve tekrar kullanılan şifre olup olmadığı bu bölümde gösterilir.

### Şifre Sağlık Analizi

Uygulama, girilen şifreleri uzunluk, büyük harf, küçük harf, rakam ve sembol içerme durumuna göre analiz eder. Sonuç olarak şifreyi zayıf, orta veya güçlü olarak sınıflandırır.

### Şifre Geçmişi

Kullanıcı bir hesabın şifresini değiştirdiğinde eski şifre geçmiş listesine eklenir. Böylece ilgili hesabın önceki şifreleri takip edilebilir.

## Kurulum ve Çalıştırma

Projeyi çalıştırmak için Flutter SDK kurulu olmalıdır.

Terminal veya PowerShell üzerinden proje klasörüne girilir:

```bash
cd sifre_kasasi