import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Hesap listesini, kayıt/silme/güncelleme işlemlerini yöneten Provider.
        ChangeNotifierProvider(
          create: (context) => AccountProvider()..hesaplariYukle(),
        ),

        // Açık/koyu tema seçimini yöneten Provider.
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..temaYukle(),
        ),
      ],
      child: const SifreKasasiApp(),
    ),
  );
}

// =======================================================
// UYGULAMA KÖKÜ
// Tema ayarları ve ilk açılış ekranı burada belirlenir.
// =======================================================
class SifreKasasiApp extends StatelessWidget {
  const SifreKasasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Kişisel Şifre Kasası',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.koyuTemaMi ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F4FC),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.82),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.indigo.withOpacity(0.18),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF11131A),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.14),
            ),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// =======================================================
// TEMA PROVIDER
// Kullanıcının açık/koyu tema tercihini yerel hafızada saklar.
// =======================================================
class ThemeProvider extends ChangeNotifier {
  bool koyuTemaMi = false;

  Future<void> temaYukle() async {
    final prefs = await SharedPreferences.getInstance();
    koyuTemaMi = prefs.getBool('koyuTemaMi') ?? false;
    notifyListeners();
  }

  Future<void> temaDegistir() async {
    koyuTemaMi = !koyuTemaMi;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('koyuTemaMi', koyuTemaMi);

    notifyListeners();
  }
}

// =======================================================
// AUTH GATE
// Kasa şifresi kurulu mu, giriş yapılmış mı kontrol eder.
// =======================================================
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool yukleniyor = true;
  bool kasaSifresiVarMi = false;
  bool girisYapildiMi = false;

  @override
  void initState() {
    super.initState();
    kasaDurumunuKontrolEt();
  }

  Future<void> kasaDurumunuKontrolEt() async {
    final prefs = await SharedPreferences.getInstance();
    final kasaSifresi = prefs.getString('kasaSifresi');

    setState(() {
      kasaSifresiVarMi = kasaSifresi != null && kasaSifresi.isNotEmpty;
      yukleniyor = false;
    });
  }

  void girisBasarili() {
    setState(() {
      girisYapildiMi = true;
    });
  }

  void kasaKuruldu() {
    setState(() {
      kasaSifresiVarMi = true;
      girisYapildiMi = true;
    });
  }

  void kasayiKilitle() {
    setState(() {
      girisYapildiMi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (yukleniyor) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!kasaSifresiVarMi) {
      return KasaKurulumPage(onKasaKuruldu: kasaKuruldu);
    }

    if (!girisYapildiMi) {
      return KasaGirisPage(onGirisBasarili: girisBasarili);
    }

    return HomePage(onKilitle: kasayiKilitle);
  }
}

// =======================================================
// ORTAK UI YARDIMCILARI
// Sayfaların fresh görünmesi için kullanılan küçük widgetlar.
// =======================================================
class FreshHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FreshHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.22),
            colorScheme.secondaryContainer.withOpacity(0.32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.14),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: colorScheme.primary.withOpacity(0.15),
            child: Icon(
              icon,
              size: 38,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.76),
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final koyuTemaMi = context.watch<ThemeProvider>().koyuTemaMi;

    return IconButton(
      tooltip: 'Tema değiştir',
      onPressed: () {
        context.read<ThemeProvider>().temaDegistir();
      },
      icon: Icon(koyuTemaMi ? Icons.light_mode : Icons.dark_mode),
    );
  }
}

// =======================================================
// KASA KURULUM SAYFASI
// İlk kullanımda kasa şifresi ve kurtarma kelimesi oluşturulur.
// =======================================================
class KasaKurulumPage extends StatefulWidget {
  final VoidCallback onKasaKuruldu;

  const KasaKurulumPage({
    super.key,
    required this.onKasaKuruldu,
  });

  @override
  State<KasaKurulumPage> createState() => _KasaKurulumPageState();
}

class _KasaKurulumPageState extends State<KasaKurulumPage> {
  final formKey = GlobalKey<FormState>();

  final kasaSifresiController = TextEditingController();
  final kasaSifresiTekrarController = TextEditingController();
  final kurtarmaKelimesiController = TextEditingController();

  bool sifreGizliMi = true;

  Future<void> kasaSifresiOlustur() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Demo/ödev kapsamında kasa şifresi ve kurtarma kelimesi yerel hafızada tutulur.
    // Gerçek bir ticari uygulamada bu bilgiler hash/şifreleme ile saklanmalıdır.
    await prefs.setString('kasaSifresi', kasaSifresiController.text.trim());
    await prefs.setString(
      'kurtarmaKelimesi',
      kurtarmaKelimesiController.text.trim().toLowerCase(),
    );

    widget.onKasaKuruldu();
  }

  @override
  void dispose() {
    kasaSifresiController.dispose();
    kasaSifresiTekrarController.dispose();
    kurtarmaKelimesiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasa Kurulumu'),
        actions: const [ThemeToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const FreshHeader(
                icon: Icons.enhanced_encryption,
                title: 'Kişisel Kasanı Oluştur',
                subtitle:
                    'Kasa şifresi ile uygulamaya giriş yapılır. Kurtarma kelimesi ise şifre unutulursa sıfırlama için kullanılır.',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: kasaSifresiController,
                obscureText: sifreGizliMi,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kasa şifresi boş bırakılamaz.';
                  }

                  if (value.trim().length < 4) {
                    return 'Kasa şifresi en az 4 karakter olmalıdır.';
                  }

                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Kasa Şifresi',
                  prefixIcon: const Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(
                      sifreGizliMi ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        sifreGizliMi = !sifreGizliMi;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kasaSifresiTekrarController,
                obscureText: sifreGizliMi,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Şifre tekrarı boş bırakılamaz.';
                  }

                  if (value.trim() != kasaSifresiController.text.trim()) {
                    return 'Kasa şifreleri eşleşmiyor.';
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Kasa Şifresi Tekrar',
                  prefixIcon: Icon(Icons.password),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kurtarmaKelimesiController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kurtarma kelimesi boş bırakılamaz.';
                  }

                  if (value.trim().length < 3) {
                    return 'Kurtarma kelimesi en az 3 karakter olmalıdır.';
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Kurtarma Kelimesi',
                  hintText: 'Örn: özel bir kelime',
                  prefixIcon: Icon(Icons.help_outline),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: kasaSifresiOlustur,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Kasayı Oluştur'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// KASA GİRİŞ SAYFASI
// Kasa şifresi doğruysa ana sayfaya erişim verir.
// =======================================================
class KasaGirisPage extends StatefulWidget {
  final VoidCallback onGirisBasarili;

  const KasaGirisPage({
    super.key,
    required this.onGirisBasarili,
  });

  @override
  State<KasaGirisPage> createState() => _KasaGirisPageState();
}

class _KasaGirisPageState extends State<KasaGirisPage> {
  final kasaSifresiController = TextEditingController();
  bool sifreGizliMi = true;

  Future<void> girisYap() async {
    final prefs = await SharedPreferences.getInstance();
    final kayitliSifre = prefs.getString('kasaSifresi') ?? '';

    if (kasaSifresiController.text.trim() == kayitliSifre) {
      widget.onGirisBasarili();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kasa şifresi hatalı.')),
      );
    }
  }

  Future<void> sifremiUnuttumSayfasinaGit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KasaSifreSifirlaPage(),
      ),
    );
  }

  @override
  void dispose() {
    kasaSifresiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş'),
        actions: const [ThemeToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const FreshHeader(
              icon: Icons.shield,
              title: 'Şifre Kasası',
              subtitle:
                  'Hesap bilgilerin cihaz yerelinde saklanır. Kasanı açmak için ana şifreni gir.',
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: kasaSifresiController,
              obscureText: sifreGizliMi,
              decoration: InputDecoration(
                labelText: 'Kasa Şifresi',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    sifreGizliMi ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      sifreGizliMi = !sifreGizliMi;
                    });
                  },
                ),
              ),
              onFieldSubmitted: (_) => girisYap(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: girisYap,
                icon: const Icon(Icons.login),
                label: const Text('Giriş Yap'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: sifremiUnuttumSayfasinaGit,
              icon: const Icon(Icons.lock_reset),
              label: const Text('Şifremi Unuttum'),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// KASA ŞİFRESİ SIFIRLAMA SAYFASI
// Kurtarma kelimesi doğruysa yeni kasa şifresi belirlenir.
// =======================================================
class KasaSifreSifirlaPage extends StatefulWidget {
  const KasaSifreSifirlaPage({super.key});

  @override
  State<KasaSifreSifirlaPage> createState() => _KasaSifreSifirlaPageState();
}

class _KasaSifreSifirlaPageState extends State<KasaSifreSifirlaPage> {
  final formKey = GlobalKey<FormState>();

  final kurtarmaKelimesiController = TextEditingController();
  final yeniSifreController = TextEditingController();
  final yeniSifreTekrarController = TextEditingController();

  bool sifreGizliMi = true;

  Future<void> sifreyiSifirla() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final kayitliKurtarmaKelimesi =
        prefs.getString('kurtarmaKelimesi') ?? '';

    final girilenKurtarma =
        kurtarmaKelimesiController.text.trim().toLowerCase();

    if (girilenKurtarma != kayitliKurtarmaKelimesi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kurtarma kelimesi hatalı.')),
      );
      return;
    }

    await prefs.setString('kasaSifresi', yeniSifreController.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kasa şifresi başarıyla sıfırlandı.')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    kurtarmaKelimesiController.dispose();
    yeniSifreController.dispose();
    yeniSifreTekrarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Sıfırla'),
        actions: const [ThemeToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const FreshHeader(
                icon: Icons.lock_reset,
                title: 'Kasa Şifresini Sıfırla',
                subtitle:
                    'Kurtarma kelimen doğruysa yeni bir kasa şifresi belirleyebilirsin.',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: kurtarmaKelimesiController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kurtarma kelimesi boş bırakılamaz.';
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Kurtarma Kelimesi',
                  prefixIcon: Icon(Icons.help),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: yeniSifreController,
                obscureText: sifreGizliMi,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Yeni şifre boş bırakılamaz.';
                  }

                  if (value.trim().length < 4) {
                    return 'Yeni şifre en az 4 karakter olmalıdır.';
                  }

                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Yeni Kasa Şifresi',
                  prefixIcon: const Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(
                      sifreGizliMi ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        sifreGizliMi = !sifreGizliMi;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: yeniSifreTekrarController,
                obscureText: sifreGizliMi,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Şifre tekrarı boş bırakılamaz.';
                  }

                  if (value.trim() != yeniSifreController.text.trim()) {
                    return 'Yeni şifreler eşleşmiyor.';
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Yeni Kasa Şifresi Tekrar',
                  prefixIcon: Icon(Icons.password),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: sifreyiSifirla,
                  icon: const Icon(Icons.save),
                  label: const Text('Şifreyi Sıfırla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// MODEL KATMANI
// Hesap bilgisinin veri yapısı.
// =======================================================
class Account {
  final String id;
  final String platformAdi;
  final String kullaniciAdi;
  final String sifre;
  final String url;
  final String kategori;
  final String olusturulmaTarihi;
  final String sonGuncellemeTarihi;
  final List<String> sifreGecmisi;

  Account({
    required this.id,
    required this.platformAdi,
    required this.kullaniciAdi,
    required this.sifre,
    required this.url,
    required this.kategori,
    required this.olusturulmaTarihi,
    required this.sonGuncellemeTarihi,
    required this.sifreGecmisi,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platformAdi': platformAdi,
      'kullaniciAdi': kullaniciAdi,
      'sifre': sifre,
      'url': url,
      'kategori': kategori,
      'olusturulmaTarihi': olusturulmaTarihi,
      'sonGuncellemeTarihi': sonGuncellemeTarihi,
      'sifreGecmisi': sifreGecmisi,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    final simdikiTarih = DateTime.now().toIso8601String();

    return Account(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      platformAdi: json['platformAdi'] ?? json['platform'] ?? '',
      kullaniciAdi: json['kullaniciAdi'] ?? '',
      sifre: json['sifre'] ?? '',
      url: json['url'] ?? '',
      kategori: json['kategori'] ?? 'Diğer',
      olusturulmaTarihi: json['olusturulmaTarihi'] ?? simdikiTarih,
      sonGuncellemeTarihi: json['sonGuncellemeTarihi'] ?? simdikiTarih,
      sifreGecmisi: List<String>.from(json['sifreGecmisi'] ?? []),
    );
  }
}

// =======================================================
// ŞİFRE SAĞLIK ANALİZ MODELLERİ
// =======================================================
class SifreSaglikSonucu {
  final String seviye;
  final int puan;
  final List<String> oneriler;

  SifreSaglikSonucu({
    required this.seviye,
    required this.puan,
    required this.oneriler,
  });
}

class GuvenlikPanosuSonucu {
  final int toplamHesap;
  final int gucluSifreSayisi;
  final int ortaSifreSayisi;
  final int zayifSifreSayisi;
  final bool tekrarKullanilanSifreVarMi;
  final String genelDurum;

  GuvenlikPanosuSonucu({
    required this.toplamHesap,
    required this.gucluSifreSayisi,
    required this.ortaSifreSayisi,
    required this.zayifSifreSayisi,
    required this.tekrarKullanilanSifreVarMi,
    required this.genelDurum,
  });
}

// Şifreyi uzunluk, büyük harf, küçük harf, rakam ve sembol üzerinden değerlendirir.
SifreSaglikSonucu sifreSagliginiHesapla(String sifre) {
  int puan = 0;
  final List<String> oneriler = [];

  final hasUppercase = RegExp(r'[A-Z]').hasMatch(sifre);
  final hasLowercase = RegExp(r'[a-z]').hasMatch(sifre);
  final hasDigit = RegExp(r'[0-9]').hasMatch(sifre);
  final hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(sifre);

  if (sifre.length >= 8) {
    puan++;
  } else {
    oneriler.add('Şifre en az 8 karakter olmalı.');
  }

  if (sifre.length >= 12) {
    puan++;
  } else {
    oneriler.add('Daha güçlü olması için 12 karakter önerilir.');
  }

  if (hasUppercase) {
    puan++;
  } else {
    oneriler.add('Büyük harf eklenmeli.');
  }

  if (hasLowercase) {
    puan++;
  } else {
    oneriler.add('Küçük harf eklenmeli.');
  }

  if (hasDigit) {
    puan++;
  } else {
    oneriler.add('Rakam eklenmeli.');
  }

  if (hasSymbol) {
    puan++;
  } else {
    oneriler.add('Sembol eklenmeli.');
  }

  String seviye;

  if (puan >= 5) {
    seviye = 'Güçlü';
  } else if (puan >= 3) {
    seviye = 'Orta';
  } else {
    seviye = 'Zayıf';
  }

  if (oneriler.isEmpty) {
    oneriler.add('Şifre güvenlik açısından iyi görünüyor.');
  }

  return SifreSaglikSonucu(
    seviye: seviye,
    puan: puan,
    oneriler: oneriler,
  );
}

// ISO tarih formatını ekranda okunabilir hale getirir.
String tarihiGoster(String isoTarih) {
  final tarih = DateTime.tryParse(isoTarih);

  if (tarih == null) {
    return 'Bilinmiyor';
  }

  final gun = tarih.day.toString().padLeft(2, '0');
  final ay = tarih.month.toString().padLeft(2, '0');
  final yil = tarih.year.toString();

  return '$gun.$ay.$yil';
}

// =======================================================
// LOGIC & STATE KATMANI
// Provider ile hesapların yönetildiği katman.
// =======================================================
class AccountProvider extends ChangeNotifier {
  final List<Account> _hesaplar = [];

  List<Account> get hesaplar => _hesaplar;

  Future<void> hesaplariYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final kayitliVeri = prefs.getString('hesaplar');

    if (kayitliVeri != null) {
      final List decodedList = jsonDecode(kayitliVeri);

      _hesaplar.clear();
      _hesaplar.addAll(
        decodedList.map((item) => Account.fromJson(item)).toList(),
      );

      notifyListeners();
    }
  }

  Future<void> hesaplariKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonVeri = jsonEncode(
      _hesaplar.map((account) => account.toJson()).toList(),
    );

    await prefs.setString('hesaplar', jsonVeri);
  }

  Future<void> hesapEkle(Account account) async {
    _hesaplar.add(account);
    await hesaplariKaydet();
    notifyListeners();
  }

  Future<void> hesapGuncelle(Account guncellenenAccount) async {
    final index = _hesaplar.indexWhere(
      (account) => account.id == guncellenenAccount.id,
    );

    if (index != -1) {
      final eskiAccount = _hesaplar[index];
      final yeniSifreGecmisi = List<String>.from(eskiAccount.sifreGecmisi);

      // Şifre değişirse eski şifre geçmişe eklenir.
      if (eskiAccount.sifre != guncellenenAccount.sifre) {
        yeniSifreGecmisi.add(eskiAccount.sifre);
      }

      final finalAccount = Account(
        id: guncellenenAccount.id,
        platformAdi: guncellenenAccount.platformAdi,
        kullaniciAdi: guncellenenAccount.kullaniciAdi,
        sifre: guncellenenAccount.sifre,
        url: guncellenenAccount.url,
        kategori: guncellenenAccount.kategori,
        olusturulmaTarihi: eskiAccount.olusturulmaTarihi,
        sonGuncellemeTarihi: DateTime.now().toIso8601String(),
        sifreGecmisi: yeniSifreGecmisi,
      );

      _hesaplar[index] = finalAccount;
      await hesaplariKaydet();
      notifyListeners();
    }
  }

  Future<void> hesapSil(String id) async {
    _hesaplar.removeWhere((account) => account.id == id);
    await hesaplariKaydet();
    notifyListeners();
  }

  List<Account> hesapAra(String aramaMetni) {
    final arama = aramaMetni.toLowerCase();

    return _hesaplar.where((account) {
      final platform = account.platformAdi.toLowerCase();
      final kullaniciAdi = account.kullaniciAdi.toLowerCase();
      final kategori = account.kategori.toLowerCase();

      return platform.contains(arama) ||
          kullaniciAdi.contains(arama) ||
          kategori.contains(arama);
    }).toList();
  }

  bool sifreTekrarKullanilmisMi(Account seciliAccount) {
    return _hesaplar.any(
      (account) =>
          account.id != seciliAccount.id &&
          account.sifre.trim() == seciliAccount.sifre.trim(),
    );
  }

  bool tekrarKullanilanSifreVarMi() {
    final Set<String> gorulenSifreler = {};

    for (final account in _hesaplar) {
      final temizSifre = account.sifre.trim();

      if (temizSifre.isEmpty) {
        continue;
      }

      if (gorulenSifreler.contains(temizSifre)) {
        return true;
      }

      gorulenSifreler.add(temizSifre);
    }

    return false;
  }

  GuvenlikPanosuSonucu guvenlikPanosuOlustur() {
    int guclu = 0;
    int orta = 0;
    int zayif = 0;

    for (final account in _hesaplar) {
      final sonuc = sifreSagliginiHesapla(account.sifre);

      if (sonuc.seviye == 'Güçlü') {
        guclu++;
      } else if (sonuc.seviye == 'Orta') {
        orta++;
      } else {
        zayif++;
      }
    }

    final tekrarVarMi = tekrarKullanilanSifreVarMi();

    String genelDurum;

    if (_hesaplar.isEmpty) {
      genelDurum = 'Kayıt yok';
    } else if (zayif > 0 || tekrarVarMi) {
      genelDurum = 'Riskli';
    } else if (orta > 0) {
      genelDurum = 'Orta';
    } else {
      genelDurum = 'Güvenli';
    }

    return GuvenlikPanosuSonucu(
      toplamHesap: _hesaplar.length,
      gucluSifreSayisi: guclu,
      ortaSifreSayisi: orta,
      zayifSifreSayisi: zayif,
      tekrarKullanilanSifreVarMi: tekrarVarMi,
      genelDurum: genelDurum,
    );
  }
}

// =======================================================
// ANA SAYFA
// Hesap listesi, güvenlik panosu, arama ve hızlı erişim burada bulunur.
// =======================================================
class HomePage extends StatefulWidget {
  final VoidCallback onKilitle;

  const HomePage({
    super.key,
    required this.onKilitle,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String aramaMetni = '';

  String sifreyiGizle(String sifre) {
    return '*' * sifre.length;
  }

  IconData kategoriIkonu(String kategori) {
    if (kategori == 'Sosyal Medya') {
      return Icons.people;
    } else if (kategori == 'E-posta') {
      return Icons.email;
    } else if (kategori == 'Okul') {
      return Icons.school;
    } else if (kategori == 'Banka') {
      return Icons.account_balance;
    } else {
      return Icons.lock;
    }
  }

  Color sifreSeviyeRengi(String seviye) {
    if (seviye == 'Güçlü') {
      return Colors.green;
    } else if (seviye == 'Orta') {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color genelDurumRengi(String durum) {
    if (durum == 'Güvenli') {
      return Colors.green;
    } else if (durum == 'Orta') {
      return Colors.orange;
    } else if (durum == 'Riskli') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  Future<void> hesapEklemeSayfasinaGit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HesapEklePage(),
      ),
    );
  }

  Future<void> hesapDuzenlemeSayfasinaGit(Account account) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HesapEklePage(mevcutAccount: account),
      ),
    );
  }

  void silmeOnayiGoster(Account account) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hesabı Sil'),
          content: const Text(
            'Bu hesabı silmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () {
                context.read<AccountProvider>().hesapSil(account.id);
                Navigator.pop(context);
              },
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  void hesapDetayGoster(Account account) {
    bool sifreGorunuyorMu = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final sifreSagligi = sifreSagliginiHesapla(account.sifre);
            final tekrarVarMi =
                context.read<AccountProvider>().sifreTekrarKullanilmisMi(account);

            return AlertDialog(
              title: Text(account.platformAdi),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kategori: ${account.kategori}'),
                    const SizedBox(height: 8),
                    Text('Kullanıcı adı: ${account.kullaniciAdi}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sifreGorunuyorMu
                                ? 'Şifre: ${account.sifre}'
                                : 'Şifre: ${sifreyiGizle(account.sifre)}',
                          ),
                        ),
                        IconButton(
                          tooltip: 'Şifreyi göster/gizle',
                          icon: Icon(
                            sifreGorunuyorMu
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              sifreGorunuyorMu = !sifreGorunuyorMu;
                            });
                          },
                        ),
                        IconButton(
                          tooltip: 'Şifreyi kopyala',
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: account.sifre),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Şifre panoya kopyalandı.'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('URL: ${account.url}'),
                    const SizedBox(height: 8),
                    Text('Oluşturulma: ${tarihiGoster(account.olusturulmaTarihi)}'),
                    const SizedBox(height: 8),
                    Text(
                      'Son güncelleme: ${tarihiGoster(account.sonGuncellemeTarihi)}',
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.health_and_safety, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Şifre Sağlığı: ${sifreSagligi.seviye}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: sifreSeviyeRengi(sifreSagligi.seviye),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Güvenlik puanı: ${sifreSagligi.puan}/6'),
                    const SizedBox(height: 8),
                    ...sifreSagligi.oneriler.map(
                      (oneri) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $oneri'),
                      ),
                    ),
                    if (tekrarVarMi) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Uyarı: Bu şifre başka bir hesapta da kullanılıyor.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Şifre Geçmişi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    if (account.sifreGecmisi.isEmpty)
                      const Text('Bu hesap için eski şifre kaydı yok.')
                    else
                      ...account.sifreGecmisi.reversed.map(
                        (eskiSifre) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• ${sifreyiGizle(eskiSifre)}'),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    hesapDuzenlemeSayfasinaGit(account);
                  },
                  child: const Text('Düzenle'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    silmeOnayiGoster(account);
                  },
                  child: const Text('Sil'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Kapat'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget guvenlikOzetKutusu({
    required String baslik,
    required String deger,
    required IconData ikon,
    required Color renk,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: renk.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: renk.withOpacity(0.25),
          ),
        ),
        child: Column(
          children: [
            Icon(ikon, color: renk, size: 22),
            const SizedBox(height: 6),
            Text(
              deger,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: renk,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              baslik,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget guvenlikPanosuWidget(GuvenlikPanosuSonucu pano) {
    final durumRengi = genelDurumRengi(pano.genelDurum);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            durumRengi.withOpacity(0.18),
            Colors.indigo.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: durumRengi.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: durumRengi.withOpacity(0.15),
                child: Icon(
                  Icons.security,
                  color: durumRengi,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Güvenlik Panosu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: durumRengi.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  pano.genelDurum,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: durumRengi,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              guvenlikOzetKutusu(
                baslik: 'Toplam',
                deger: pano.toplamHesap.toString(),
                ikon: Icons.folder,
                renk: Colors.indigo,
              ),
              const SizedBox(width: 8),
              guvenlikOzetKutusu(
                baslik: 'Güçlü',
                deger: pano.gucluSifreSayisi.toString(),
                ikon: Icons.verified,
                renk: Colors.green,
              ),
              const SizedBox(width: 8),
              guvenlikOzetKutusu(
                baslik: 'Zayıf',
                deger: pano.zayifSifreSayisi.toString(),
                ikon: Icons.warning,
                renk: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                pano.tekrarKullanilanSifreVarMi
                    ? Icons.error_outline
                    : Icons.check_circle_outline,
                size: 18,
                color: pano.tekrarKullanilanSifreVarMi
                    ? Colors.red
                    : Colors.green,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  pano.tekrarKullanilanSifreVarMi
                      ? 'Tekrar kullanılan şifre bulundu.'
                      : 'Tekrar kullanılan şifre bulunmadı.',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget cevrimdisiBilgiKutusu() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.indigo.withOpacity(0.22),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Çevrimdışı mod: Veriler cihaz yerelinde saklanır.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget hesapKarti(Account account) {
    final sifreSagligi = sifreSagliginiHesapla(account.sifre);
    final seviyeRengi = sifreSeviyeRengi(sifreSagligi.seviye);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          hesapDetayGoster(account);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.indigo.withOpacity(0.13),
                child: Icon(
                  kategoriIkonu(account.kategori),
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.platformAdi,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      account.kullaniciAdi,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            account.kategori,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: seviyeRengi.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            sifreSagligi.seviye,
                            style: TextStyle(
                              fontSize: 11,
                              color: seviyeRengi,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();

    final filtrelenmisHesaplar = accountProvider.hesapAra(aramaMetni);
    final guvenlikPanosu = accountProvider.guvenlikPanosuOlustur();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Kasası'),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            tooltip: 'Kasayı kilitle',
            onPressed: widget.onKilitle,
            icon: const Icon(Icons.lock),
          ),
        ],
      ),
      body: Column(
        children: [
          cevrimdisiBilgiKutusu(),
          guvenlikPanosuWidget(guvenlikPanosu),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Hesap ara',
                hintText: 'Platform, kullanıcı adı veya kategori',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  aramaMetni = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Toplam kayıt: ${accountProvider.hesaplar.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: accountProvider.hesaplar.isEmpty
                ? const Center(
                    child: Text(
                      'Henüz kayıtlı hesap yok.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : filtrelenmisHesaplar.isEmpty
                    ? const Center(
                        child: Text(
                          'Aramaya uygun hesap bulunamadı.',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtrelenmisHesaplar.length,
                        itemBuilder: (context, index) {
                          final account = filtrelenmisHesaplar[index];
                          return hesapKarti(account);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: hesapEklemeSayfasinaGit,
        icon: const Icon(Icons.add),
        label: const Text('Ekle'),
      ),
    );
  }
}

// =======================================================
// HESAP EKLEME / DÜZENLEME FORMU
// Yeni hesap ekleme ve mevcut hesabı düzenleme için kullanılır.
// =======================================================
class HesapEklePage extends StatefulWidget {
  final Account? mevcutAccount;

  const HesapEklePage({
    super.key,
    this.mevcutAccount,
  });

  @override
  State<HesapEklePage> createState() => _HesapEklePageState();
}

class _HesapEklePageState extends State<HesapEklePage> {
  final formKey = GlobalKey<FormState>();

  final platformController = TextEditingController();
  final kullaniciAdiController = TextEditingController();
  final sifreController = TextEditingController();
  final urlController = TextEditingController();

  final List<String> kategoriler = [
    'Sosyal Medya',
    'E-posta',
    'Okul',
    'Banka',
    'Diğer',
  ];

  String secilenKategori = 'Sosyal Medya';
  bool sifreGizliMi = true;

  bool get duzenlemeModu => widget.mevcutAccount != null;

  @override
  void initState() {
    super.initState();

    if (duzenlemeModu) {
      final account = widget.mevcutAccount!;

      platformController.text = account.platformAdi;
      kullaniciAdiController.text = account.kullaniciAdi;
      sifreController.text = account.sifre;
      urlController.text = account.url;
      secilenKategori = account.kategori;
    }
  }

  void gucluSifreUret() {
    const karakterler =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';

    final random = Random();
    String yeniSifre = '';

    for (int i = 0; i < 12; i++) {
      yeniSifre += karakterler[random.nextInt(karakterler.length)];
    }

    setState(() {
      sifreController.text = yeniSifre;
    });
  }

  String? bosAlanKontrolu(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan boş bırakılamaz.';
    }

    return null;
  }

  String? sifreKontrolu(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Şifre boş bırakılamaz.';
    }

    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }

    return null;
  }

  Future<void> kaydet() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final simdikiTarih = DateTime.now().toIso8601String();

    final account = Account(
      id: duzenlemeModu
          ? widget.mevcutAccount!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      platformAdi: platformController.text.trim(),
      kullaniciAdi: kullaniciAdiController.text.trim(),
      sifre: sifreController.text.trim(),
      url: urlController.text.trim(),
      kategori: secilenKategori,
      olusturulmaTarihi: duzenlemeModu
          ? widget.mevcutAccount!.olusturulmaTarihi
          : simdikiTarih,
      sonGuncellemeTarihi: simdikiTarih,
      sifreGecmisi:
          duzenlemeModu ? widget.mevcutAccount!.sifreGecmisi : [],
    );

    if (duzenlemeModu) {
      await context.read<AccountProvider>().hesapGuncelle(account);
    } else {
      await context.read<AccountProvider>().hesapEkle(account);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    platformController.dispose();
    kullaniciAdiController.dispose();
    sifreController.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sayfaBasligi = duzenlemeModu ? 'Hesabı Düzenle' : 'Yeni Hesap Ekle';
    final butonMetni = duzenlemeModu ? 'Güncelle' : 'Kaydet';

    return Scaffold(
      appBar: AppBar(
        title: Text(sayfaBasligi),
        actions: const [ThemeToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              FreshHeader(
                icon: duzenlemeModu ? Icons.edit_note : Icons.add_card,
                title: sayfaBasligi,
                subtitle: duzenlemeModu
                    ? 'Kayıtlı hesabın bilgilerini güncelleyebilirsin.'
                    : 'Yeni hesap bilgilerini kategoriyle birlikte kasaya ekleyebilirsin.',
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: secilenKategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                ),
                items: kategoriler.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    secilenKategori = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: platformController,
                validator: bosAlanKontrolu,
                decoration: const InputDecoration(
                  labelText: 'Platform Adı',
                  prefixIcon: Icon(Icons.language),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kullaniciAdiController,
                validator: bosAlanKontrolu,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Adı / E-posta',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: sifreController,
                validator: sifreKontrolu,
                obscureText: sifreGizliMi,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      sifreGizliMi ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        sifreGizliMi = !sifreGizliMi;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: gucluSifreUret,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Güçlü Şifre Üret'),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: urlController,
                validator: bosAlanKontrolu,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: kaydet,
                  child: Text(butonMetni),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
