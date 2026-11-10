import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bildirim_servisi.dart';

class GunlukSuVerisi {
  final DateTime tarih;
  final String kisaGunAdi;
  final double miktar;
  final bool bugunMu;

  const GunlukSuVerisi({
    required this.tarih,
    required this.kisaGunAdi,
    required this.miktar,
    required this.bugunMu,
  });
}

class SuTakipProvider extends ChangeNotifier {
  // Profil & Akıllı Hedef Kriterleri
  String kullaniciAdi = 'Kullanıcı';
  int kilo = 70;
  int yas = 30;
  String cinsiyetDurum = 'erkek'; // erkek, kadin, hamile, emziren
  String aktiviteDuzeyi = 'hafif'; // hareketsiz, hafif, orta, yogun
  String havaDurumu = 'normal'; // normal, sicak, cok_sicak
  int gunlukKafeinAdet = 2; // Günlük çay/kahve bardak/fincan sayısı (her biri +125 ml)
  bool otomatikHedefKullan = true;

  int gunlukHedef = 2500;
  int bardakBoyutu = 250;

  // Su Takip
  Map<String, int> suGecmisi = {};
  DateTime seciliTarih = DateTime.now();
  int? _sonEklenenMiktar;

  // Hatırlatıcı
  bool hatirlaticiAcik = true;
  int hatirlatmaSikligi = 60;
  TimeOfDay sessizBaslangic = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay sessizBitis = const TimeOfDay(hour: 8, minute: 0);

  // İstatistik
  int enIyiSeri = 0;

  // Etiket Haritaları
  static const Map<String, String> cinsiyetSecenekleri = {
    'erkek': 'Erkek',
    'kadin': 'Kadın',
    'hamile': 'Kadın (Hamile - +300 ml)',
    'emziren': 'Kadın (Emziren - +700 ml)',
  };

  static const Map<String, String> aktiviteSecenekleri = {
    'hareketsiz': 'Masa Başı / Az Hareketli (+0 ml)',
    'hafif': 'Hafif Aktif / Günlük Yürüyüş (+300 ml)',
    'orta': 'Orta Aktif / Düzenli Egzersiz (+500 ml)',
    'yogun': 'Çok Aktif / Yoğun Spor (+800 ml)',
  };

  static const Map<String, String> havaSecenekleri = {
    'normal': 'Serin / Normal Hava (+0 ml)',
    'sicak': 'Sıcak / Yaz Mevsimi (+400 ml)',
    'cok_sicak': 'Çok Sıcak / Nemli Hava (+700 ml)',
  };

  // Akıllı Hedef Hesaplama Detayları
  int get bazalSuIhtiyaci {
    double mlPerKg;
    if (yas < 30) {
      mlPerKg = 38.0;
    } else if (yas < 55) {
      mlPerKg = 35.0;
    } else {
      mlPerKg = 30.0;
    }
    double bazal = kilo * mlPerKg;
    if (cinsiyetDurum == 'erkek') {
      bazal *= 1.08; // Erkeklerde kas kütlesi farkı (+%8)
    }
    return (bazal / 50).round() * 50;
  }

  int get ozelDurumEkSu {
    if (cinsiyetDurum == 'hamile') return 300;
    if (cinsiyetDurum == 'emziren') return 700;
    return 0;
  }

  int get aktiviteEkSu {
    switch (aktiviteDuzeyi) {
      case 'hafif':
        return 300;
      case 'orta':
        return 500;
      case 'yogun':
        return 800;
      default:
        return 0;
    }
  }

  int get havaEkSu {
    switch (havaDurumu) {
      case 'sicak':
        return 400;
      case 'cok_sicak':
        return 700;
      default:
        return 0;
    }
  }

  int get kafeinEkSu => gunlukKafeinAdet * 125;

  int get onerilenHedef {
    final toplam = bazalSuIhtiyaci +
        ozelDurumEkSu +
        aktiviteEkSu +
        havaEkSu +
        kafeinEkSu;
    // 50 ml katlarına yuvarla ve 1000-10000 ml aralığında sınırla
    final yuvarlanmis = ((toplam / 50).round() * 50);
    return yuvarlanmis.clamp(1000, 10000);
  }

  // Getters
  int get seciliGunIcilen => suGecmisi[_tarihKey(seciliTarih)] ?? 0;
  int get bugunIcilen => suGecmisi[_tarihKey(DateTime.now())] ?? 0;
  int? get sonEklenenMiktar => _sonEklenenMiktar;

  bool get seciliTarihBugunMu =>
      _tarihKey(seciliTarih) == _tarihKey(DateTime.now());

  String get seciliTarihFormatli {
    if (seciliTarihBugunMu) return 'Bugün';
    final dun = DateTime.now().subtract(const Duration(days: 1));
    if (_tarihKey(seciliTarih) == _tarihKey(dun)) return 'Dün';
    return '${seciliTarih.day.toString().padLeft(2, '0')}.${seciliTarih.month.toString().padLeft(2, '0')}.${seciliTarih.year}';
  }

  static const List<String> _haftaGunleri = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  List<GunlukSuVerisi> get haftalikDetayliVeri {
    final bugun = DateTime.now();
    return List.generate(7, (i) {
      final gun = DateTime(bugun.year, bugun.month, bugun.day)
          .subtract(Duration(days: 6 - i));
      final gunAdi = _haftaGunleri[gun.weekday - 1];
      final miktar = (suGecmisi[_tarihKey(gun)] ?? 0).toDouble();
      return GunlukSuVerisi(
        tarih: gun,
        kisaGunAdi: gunAdi,
        miktar: miktar,
        bugunMu: i == 6,
      );
    });
  }

  List<double> get haftalikVeri =>
      haftalikDetayliVeri.map((g) => g.miktar).toList();

  int get toplamIcilen => suGecmisi.values.fold(0, (a, b) => a + b);

  double get gunlukOrtalama {
    final aktifGunler = suGecmisi.values.where((v) => v > 0).length;
    if (aktifGunler == 0) return 0;
    return toplamIcilen / aktifGunler;
  }

  int get mevcutSeri {
    final bugun = DateTime.now();
    int seri = 0;
    DateTime kontrolGunu = DateTime(bugun.year, bugun.month, bugun.day);

    if ((suGecmisi[_tarihKey(kontrolGunu)] ?? 0) < gunlukHedef) {
      kontrolGunu = kontrolGunu.subtract(const Duration(days: 1));
    }

    while ((suGecmisi[_tarihKey(kontrolGunu)] ?? 0) >= gunlukHedef) {
      seri++;
      kontrolGunu = kontrolGunu.subtract(const Duration(days: 1));
    }
    return seri;
  }

  String _tarihKey(DateTime tarih) =>
      '${tarih.year}-${tarih.month.toString().padLeft(2, '0')}-${tarih.day.toString().padLeft(2, '0')}';

  void _seriHesapla() {
    if (suGecmisi.isEmpty || gunlukHedef <= 0) return;

    final basariliTarihler = suGecmisi.entries
        .where((e) => e.value >= gunlukHedef)
        .map((e) => DateTime.tryParse(e.key))
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toList()
      ..sort();

    int maksSeri = 0;
    int anlikSeri = 0;
    DateTime? oncekiGun;

    for (final gun in basariliTarihler) {
      if (oncekiGun == null) {
        anlikSeri = 1;
      } else {
        final fark = gun.difference(oncekiGun).inDays;
        if (fark == 1) {
          anlikSeri++;
        } else if (fark > 1) {
          anlikSeri = 1;
        }
      }
      if (anlikSeri > maksSeri) {
        maksSeri = anlikSeri;
      }
      oncekiGun = gun;
    }

    if (maksSeri > enIyiSeri) {
      enIyiSeri = maksSeri;
    }
  }

  void _otomatikHedefUygula() {
    if (otomatikHedefKullan) {
      gunlukHedef = onerilenHedef;
    }
    _seriHesapla();
  }

  // Su Ekle
  void suEkle(int ml) {
    if (ml <= 0) return;
    final key = _tarihKey(seciliTarih);
    suGecmisi[key] = (suGecmisi[key] ?? 0) + ml;
    _sonEklenenMiktar = ml;
    _seriHesapla();
    notifyListeners();
    _kaydet();
  }

  // Su Azalt / Geri Al
  void suAzalt(int ml) {
    if (ml <= 0) return;
    final key = _tarihKey(seciliTarih);
    final mevcut = suGecmisi[key] ?? 0;
    final yeniDeger = max(0, mevcut - ml);
    if (yeniDeger == 0) {
      suGecmisi.remove(key);
    } else {
      suGecmisi[key] = yeniDeger;
    }
    _sonEklenenMiktar = null;
    _seriHesapla();
    notifyListeners();
    _kaydet();
  }

  void tarihDegistir(DateTime tarih) {
    seciliTarih = DateTime(tarih.year, tarih.month, tarih.day);
    _sonEklenenMiktar = null;
    notifyListeners();
  }

  void buguneDon() {
    tarihDegistir(DateTime.now());
  }

  // Profil & Akıllı Hedef Güncellemeleri
  void kullaniciAdiGuncelle(String ad) {
    final temizAd = ad.trim();
    if (temizAd.isEmpty) return;
    kullaniciAdi = temizAd;
    notifyListeners();
    _kaydet();
  }

  void kiloGuncelle(int yeniKilo) {
    kilo = yeniKilo.clamp(20, 300);
    otomatikHedefKullan = true;
    _otomatikHedefUygula();
    notifyListeners();
    _kaydet();
  }

  void yasGuncelle(int yeniYas) {
    yas = yeniYas.clamp(10, 100);
    otomatikHedefKullan = true;
    _otomatikHedefUygula();
    notifyListeners();
    _kaydet();
  }

  void cinsiyetDurumGuncelle(String yeniDurum) {
    if (!cinsiyetSecenekleri.containsKey(yeniDurum)) return;
    cinsiyetDurum = yeniDurum;
    otomatikHedefKullan = true;
    _otomatikHedefUygula();
    notifyListeners();
    _kaydet();
  }

  void aktiviteDuzeyiGuncelle(String yeniAktivite) {
    if (!aktiviteSecenekleri.containsKey(yeniAktivite)) return;
    aktiviteDuzeyi = yeniAktivite;
    otomatikHedefKullan = true;
    _otomatikHedefUygula();
    notifyListeners();
    _kaydet();
  }

  void havaDurumuGuncelle(String yeniHava) {
    if (!havaSecenekleri.containsKey(yeniHava)) return;
    havaDurumu = yeniHava;
    otomatikHedefKullan = true;
    _otomatikHedefUygula();
    notifyListeners();
    _kaydet();
  }

  void gunlukKafeinGuncelle(int adet) {
    gunlukKafeinAdet = adet.clamp(0, 15);
    otomatikHedefKullan = true;
    _otomatikHedefUygula();
    notifyListeners();
    _kaydet();
  }

  void onerilenHedefiAktifEt() {
    otomatikHedefKullan = true;
    _otomatikHedefUygula();
    notifyListeners();
    _kaydet();
  }

  void hedefGuncelle(int hedef) {
    otomatikHedefKullan = false;
    gunlukHedef = hedef.clamp(500, 10000);
    _seriHesapla();
    notifyListeners();
    _kaydet();
  }

  void bardakBoyutuGuncelle(int boyut) {
    bardakBoyutu = boyut.clamp(50, 2000);
    notifyListeners();
    _kaydet();
  }

  // Hatırlatıcı Güncellemeleri
  void hatirlaticiDegistir(bool deger) {
    hatirlaticiAcik = deger;
    _bildirimleriSenkronizeEt();
    notifyListeners();
    _kaydet();
  }

  void hatirlatmaSikligiGuncelle(int dakika) {
    hatirlatmaSikligi = dakika.clamp(15, 240);
    _bildirimleriSenkronizeEt();
    notifyListeners();
    _kaydet();
  }

  void sessizBaslangicGuncelle(TimeOfDay saat) {
    sessizBaslangic = saat;
    _bildirimleriSenkronizeEt();
    notifyListeners();
    _kaydet();
  }

  void sessizBitisGuncelle(TimeOfDay saat) {
    sessizBitis = saat;
    _bildirimleriSenkronizeEt();
    notifyListeners();
    _kaydet();
  }

  void _bildirimleriSenkronizeEt() {
    BildirimServisi().hatirlaticilariAyarla(
      acik: hatirlaticiAcik,
      siklikDakika: hatirlatmaSikligi,
      sessizBaslangic: sessizBaslangic,
      sessizBitis: sessizBitis,
    );
  }

  void verileriSifirla() {
    suGecmisi.clear();
    enIyiSeri = 0;
    _sonEklenenMiktar = null;
    seciliTarih = DateTime.now();
    notifyListeners();
    _kaydet();
  }

  // Kayıt İşlemleri
  Future<void> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    kullaniciAdi = prefs.getString('kullaniciAdi') ?? 'Kullanıcı';
    kilo = (prefs.getInt('kilo') ?? 70).clamp(20, 300);
    yas = (prefs.getInt('yas') ?? 30).clamp(10, 100);
    cinsiyetDurum = prefs.getString('cinsiyetDurum') ?? 'erkek';
    if (!cinsiyetSecenekleri.containsKey(cinsiyetDurum)) {
      cinsiyetDurum = 'erkek';
    }
    aktiviteDuzeyi = prefs.getString('aktiviteDuzeyi') ?? 'hafif';
    if (!aktiviteSecenekleri.containsKey(aktiviteDuzeyi)) {
      aktiviteDuzeyi = 'hafif';
    }
    havaDurumu = prefs.getString('havaDurumu') ?? 'normal';
    if (!havaSecenekleri.containsKey(havaDurumu)) {
      havaDurumu = 'normal';
    }
    gunlukKafeinAdet = (prefs.getInt('gunlukKafeinAdet') ?? 2).clamp(0, 15);
    otomatikHedefKullan = prefs.getBool('otomatikHedefKullan') ?? true;

    if (otomatikHedefKullan) {
      gunlukHedef = onerilenHedef;
    } else {
      gunlukHedef =
          (prefs.getInt('gunlukHedef') ?? onerilenHedef).clamp(500, 10000);
    }

    bardakBoyutu = (prefs.getInt('bardakBoyutu') ?? 250).clamp(50, 2000);
    hatirlaticiAcik = prefs.getBool('hatirlaticiAcik') ?? true;
    hatirlatmaSikligi =
        (prefs.getInt('hatirlatmaSikligi') ?? 60).clamp(15, 240);
    enIyiSeri = max(0, prefs.getInt('enIyiSeri') ?? 0);

    final sessizBasStr = prefs.getString('sessizBaslangic');
    if (sessizBasStr != null) {
      final parts = sessizBasStr.split(':');
      if (parts.length == 2) {
        sessizBaslangic = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 22,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    final sessizBitStr = prefs.getString('sessizBitis');
    if (sessizBitStr != null) {
      final parts = sessizBitStr.split(':');
      if (parts.length == 2) {
        sessizBitis = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final gecmisStr = prefs.getString('suGecmisi');
    if (gecmisStr != null) {
      try {
        final decoded = json.decode(gecmisStr) as Map<String, dynamic>;
        suGecmisi = decoded.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        );
      } catch (e) {
        debugPrint('Geçmiş verisi okunamadı: $e');
      }
    }

    _seriHesapla();
    _bildirimleriSenkronizeEt();
    notifyListeners();
  }

  Future<void> _kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kullaniciAdi', kullaniciAdi);
    await prefs.setInt('kilo', kilo);
    await prefs.setInt('yas', yas);
    await prefs.setString('cinsiyetDurum', cinsiyetDurum);
    await prefs.setString('aktiviteDuzeyi', aktiviteDuzeyi);
    await prefs.setString('havaDurumu', havaDurumu);
    await prefs.setInt('gunlukKafeinAdet', gunlukKafeinAdet);
    await prefs.setBool('otomatikHedefKullan', otomatikHedefKullan);
    await prefs.setInt('gunlukHedef', gunlukHedef);
    await prefs.setInt('bardakBoyutu', bardakBoyutu);
    await prefs.setBool('hatirlaticiAcik', hatirlaticiAcik);
    await prefs.setInt('hatirlatmaSikligi', hatirlatmaSikligi);
    await prefs.setInt('enIyiSeri', enIyiSeri);
    await prefs.setString(
      'sessizBaslangic',
      '${sessizBaslangic.hour}:${sessizBaslangic.minute}',
    );
    await prefs.setString(
      'sessizBitis',
      '${sessizBitis.hour}:${sessizBitis.minute}',
    );
    await prefs.setString('suGecmisi', json.encode(suGecmisi));
  }
}
