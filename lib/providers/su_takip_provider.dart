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
  String kullaniciAdi = 'Kullanıcı';
  int kilo = 70;
  int gunlukHedef = 2500;
  int bardakBoyutu = 250;

  Map<String, int> suGecmisi = {};
  DateTime seciliTarih = DateTime.now();
  int? _sonEklenenMiktar;

  bool hatirlaticiAcik = true;
  int hatirlatmaSikligi = 60;
  TimeOfDay sessizBaslangic = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay sessizBitis = const TimeOfDay(hour: 8, minute: 0);

  int enIyiSeri = 0;

  int get seciliGunIcilen => suGecmisi[_tarihKey(seciliTarih)] ?? 0;
  int get bugunIcilen => suGecmisi[_tarihKey(DateTime.now())] ?? 0;
  int? get sonEklenenMiktar => _sonEklenenMiktar;

  bool get seciliTarihBugunMu => _tarihKey(seciliTarih) == _tarihKey(DateTime.now());

  String get seciliTarihFormatli {
    if (seciliTarihBugunMu) return 'Bugün';
    final dun = DateTime.now().subtract(const Duration(days: 1));
    if (_tarihKey(seciliTarih) == _tarihKey(dun)) return 'Dün';
    return '${seciliTarih.day.toString().padLeft(2, '0')}.${seciliTarih.month.toString().padLeft(2, '0')}.${seciliTarih.year}';
  }

  static const List<String> _haftaGunleri = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  List<GunlukSuVerisi> get haftalikDetayliVeri {
    final bugun = DateTime.now();
    return List.generate(7, (i) {
      final gun = DateTime(bugun.year, bugun.month, bugun.day).subtract(Duration(days: 6 - i));
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

  List<double> get haftalikVeri => haftalikDetayliVeri.map((g) => g.miktar).toList();

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
      if (anlikSeri > maksSeri) maksSeri = anlikSeri;
      oncekiGun = gun;
    }
    if (maksSeri > enIyiSeri) enIyiSeri = maksSeri;
  }

  void suEkle(int ml) {
    if (ml <= 0) return;
    final key = _tarihKey(seciliTarih);
    suGecmisi[key] = (suGecmisi[key] ?? 0) + ml;
    _sonEklenenMiktar = ml;
    _seriHesapla();
    notifyListeners();
    _kaydet();
  }

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

  void kullaniciAdiGuncelle(String ad) {
    final temizAd = ad.trim();
    if (temizAd.isEmpty) return;
    kullaniciAdi = temizAd;
    notifyListeners();
    _kaydet();
  }

  void kiloGuncelle(int yeniKilo) {
    kilo = yeniKilo.clamp(20, 300);
    gunlukHedef = (kilo * 35).clamp(500, 10000);
    _seriHesapla();
    notifyListeners();
    _kaydet();
  }

  void hedefGuncelle(int hedef) {
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

  Future<void> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    kullaniciAdi = prefs.getString('kullaniciAdi') ?? 'Kullanıcı';
    kilo = (prefs.getInt('kilo') ?? 70).clamp(20, 300);
    gunlukHedef = (prefs.getInt('gunlukHedef') ?? 2500).clamp(500, 10000);
    bardakBoyutu = (prefs.getInt('bardakBoyutu') ?? 250).clamp(50, 2000);
    hatirlaticiAcik = prefs.getBool('hatirlaticiAcik') ?? true;
    hatirlatmaSikligi = (prefs.getInt('hatirlatmaSikligi') ?? 60).clamp(15, 240);
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
        suGecmisi = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {}
    }

    _seriHesapla();
    _bildirimleriSenkronizeEt();
    notifyListeners();
  }
  Future<void> _kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kullaniciAdi', kullaniciAdi);
    await prefs.setInt('kilo', kilo);
    await prefs.setInt('gunlukHedef', gunlukHedef);
    await prefs.setInt('bardakBoyutu', bardakBoyutu);
    await prefs.setBool('hatirlaticiAcik', hatirlaticiAcik);
    await prefs.setInt('hatirlatmaSikligi', hatirlatmaSikligi);
    await prefs.setInt('enIyiSeri', enIyiSeri);
    await prefs.setString('sessizBaslangic', '${sessizBaslangic.hour}:${sessizBaslangic.minute}');
    await prefs.setString('sessizBitis', '${sessizBitis.hour}:${sessizBitis.minute}');
    await prefs.setString('suGecmisi', json.encode(suGecmisi));
  }
}
