import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/su_takip_provider.dart';

class AyarlarPage extends StatelessWidget {
  const AyarlarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuTakipProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Ayarlar & Akıllı Hedef')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Akıllı Su Hesaplama Özeti Kartı
          _akilliHesapOzetiKarti(context, provider),
          const SizedBox(height: 20),

          // Kişisel & Fiziksel Kriterler
          _ayarlarBolumu('👤 Kişisel ve Fiziksel Kriterler', [
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2196F3)),
              title: const Text('İsim'),
              subtitle: Text(provider.kullaniciAdi),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _isimDegistir(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading:
                  const Icon(Icons.monitor_weight, color: Color(0xFF2196F3)),
              title: const Text('Kilo'),
              subtitle: Text('${provider.kilo} kg'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _kiloDegistir(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.cake, color: Color(0xFF2196F3)),
              title: const Text('Yaş'),
              subtitle: Text(
                '${provider.yas} yaş (${provider.yas < 30 ? "Yüksek metabolizma" : provider.yas < 55 ? "Standart metabolizma" : "Koruyucu hidrasyon"})',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _yasDegistir(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.wc, color: Color(0xFF2196F3)),
              title: const Text('Cinsiyet ve Özel Durum'),
              subtitle: Text(
                SuTakipProvider.cinsiyetSecenekleri[provider.cinsiyetDurum] ??
                    'Erkek',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _secenekSecDialog(
                context: context,
                baslik: 'Cinsiyet ve Özel Durum',
                secenekler: SuTakipProvider.cinsiyetSecenekleri,
                mevcutDeger: provider.cinsiyetDurum,
                onSecildi: (val) =>
                    context.read<SuTakipProvider>().cinsiyetDurumGuncelle(val),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // Yaşam Tarzı ve Çevre Kriterleri
          _ayarlarBolumu('🏃 Yaşam Tarzı ve Çevre Kriterleri', [
            ListTile(
              leading:
                  const Icon(Icons.directions_run, color: Color(0xFF2196F3)),
              title: const Text('Fiziksel Aktivite / Spor Düzeyi'),
              subtitle: Text(
                SuTakipProvider.aktiviteSecenekleri[provider.aktiviteDuzeyi] ??
                    '',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _secenekSecDialog(
                context: context,
                baslik: 'Fiziksel Aktivite Düzeyi',
                secenekler: SuTakipProvider.aktiviteSecenekleri,
                mevcutDeger: provider.aktiviteDuzeyi,
                onSecildi: (val) =>
                    context.read<SuTakipProvider>().aktiviteDuzeyiGuncelle(val),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.wb_sunny, color: Color(0xFF2196F3)),
              title: const Text('Hava Sıcaklığı / İklim'),
              subtitle: Text(
                SuTakipProvider.havaSecenekleri[provider.havaDurumu] ?? '',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _secenekSecDialog(
                context: context,
                baslik: 'Hava Sıcaklığı / İklim',
                secenekler: SuTakipProvider.havaSecenekleri,
                mevcutDeger: provider.havaDurumu,
                onSecildi: (val) =>
                    context.read<SuTakipProvider>().havaDurumuGuncelle(val),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.coffee, color: Colors.brown),
              title: const Text('Günlük Çay / Kahve Tüketimi'),
              subtitle: Text(
                'Günde ${provider.gunlukKafeinAdet} fincan/bardak (+${provider.kafeinEkSu} ml dengeleme)',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: provider.gunlukKafeinAdet > 0
                        ? () => context
                            .read<SuTakipProvider>()
                            .gunlukKafeinGuncelle(provider.gunlukKafeinAdet - 1)
                        : null,
                  ),
                  Text(
                    '${provider.gunlukKafeinAdet}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: provider.gunlukKafeinAdet < 15
                        ? () => context
                            .read<SuTakipProvider>()
                            .gunlukKafeinGuncelle(provider.gunlukKafeinAdet + 1)
                        : null,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // Hedef ve Bardak Ayarları
          _ayarlarBolumu('🎯 Hedef ve Bardak Ayarları', [
            ListTile(
              leading: const Icon(Icons.flag, color: Color(0xFF2196F3)),
              title: const Text('Aktif Günlük Su Hedefi'),
              subtitle: Text(
                '${provider.gunlukHedef} ml (${provider.otomatikHedefKullan ? "Akıllı Hesaplama Aktif" : "Manuel Belirlendi - Önerilen: ${provider.onerilenHedef} ml"})',
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => _hedefDegistir(context),
            ),
            if (!provider.otomatikHedefKullan)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.read<SuTakipProvider>().onerilenHedefiAktifEt(),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(
                    'Akıllı Önerilen Hedefe Dön (${provider.onerilenHedef} ml)',
                  ),
                ),
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.local_drink, color: Color(0xFF2196F3)),
              title: const Text('Varsayılan Bardak Boyutu'),
              subtitle: Text('${provider.bardakBoyutu} ml'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _bardakBoyutuDegistir(context),
            ),
          ]),
          const SizedBox(height: 16),

          // Veri Yönetimi
          _ayarlarBolumu('💾 Veri', [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Verileri Sıfırla',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _verileriSifirla(context),
            ),
          ]),
          const SizedBox(height: 28),
          // Hakkında
          const Center(
            child: Column(
              children: [
                Icon(Icons.water_drop, size: 48, color: Color(0xFF2196F3)),
                SizedBox(height: 8),
                Text(
                  'Hidrat v1.1.0',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Akıllı Su Takip & Hatırlatıcı 💧',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _akilliHesapOzetiKarti(BuildContext context, SuTakipProvider p) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.psychology, color: Colors.white, size: 26),
                  SizedBox(width: 8),
                  Text(
                    'Akıllı Su İhtiyacı Analizi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${p.onerilenHedef} ml / gün',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 10),
          _hesapSatiri(
            'Bazal İhtiyaç (${p.kilo} kg, ${p.yas} yaş)',
            '${p.bazalSuIhtiyaci} ml',
          ),
          if (p.ozelDurumEkSu > 0)
            _hesapSatiri('Özel Durum (Hamile/Emziren)', '+${p.ozelDurumEkSu} ml'),
          _hesapSatiri('Fiziksel Aktivite Ek İhtiyacı', '+${p.aktiviteEkSu} ml'),
          _hesapSatiri('Hava / İklim Ek İhtiyacı', '+${p.havaEkSu} ml'),
          _hesapSatiri(
            'Çay/Kahve Dengeleme (${p.gunlukKafeinAdet} adet)',
            '+${p.kafeinEkSu} ml',
          ),
        ],
      ),
    );
  }

  Widget _hesapSatiri(String etiket, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiket,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Text(
            deger,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ayarlarBolumu(String baslik, List<Widget> cocuklar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            baslik,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(children: cocuklar),
        ),
      ],
    );
  }

  Future<void> _secenekSecDialog({
    required BuildContext context,
    required String baslik,
    required Map<String, String> secenekler,
    required String mevcutDeger,
    required Function(String) onSecildi,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(baslik),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: secenekler.entries.map((e) {
            final secili = e.key == mevcutDeger;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                secili ? Icons.radio_button_checked : Icons.radio_button_off,
                color: secili ? const Color(0xFF2196F3) : Colors.grey,
              ),
              title: Text(
                e.value,
                style: TextStyle(
                  fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                onSecildi(e.key);
                Navigator.pop(dialogContext);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _isimDegistir(BuildContext context) async {
    final mevcutIsim = context.read<SuTakipProvider>().kullaniciAdi;
    final yeniIsim = await _metinGirisDialogu(
      context: context,
      baslik: 'İsminizi Girin',
      ipucu: 'Adınız',
      baslangicDegeri: mevcutIsim,
      sayisalMi: false,
    );
    if (yeniIsim != null && yeniIsim.trim().isNotEmpty && context.mounted) {
      context.read<SuTakipProvider>().kullaniciAdiGuncelle(yeniIsim);
    }
  }

  Future<void> _kiloDegistir(BuildContext context) async {
    final mevcutKilo = context.read<SuTakipProvider>().kilo.toString();
    final girilen = await _metinGirisDialogu(
      context: context,
      baslik: 'Kilonuzu Girin (20 - 300 kg)',
      ipucu: '70',
      baslangicDegeri: mevcutKilo,
      sayisalMi: true,
    );
    if (girilen != null && context.mounted) {
      final kilo = int.tryParse(girilen);
      if (kilo != null && kilo >= 20 && kilo <= 300) {
        context.read<SuTakipProvider>().kiloGuncelle(kilo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Lütfen 20 ile 300 kg arasında geçerli bir değer girin.'),
          ),
        );
      }
    }
  }

  Future<void> _yasDegistir(BuildContext context) async {
    final mevcutYas = context.read<SuTakipProvider>().yas.toString();
    final girilen = await _metinGirisDialogu(
      context: context,
      baslik: 'Yaşınızı Girin (10 - 100)',
      ipucu: '30',
      baslangicDegeri: mevcutYas,
      sayisalMi: true,
    );
    if (girilen != null && context.mounted) {
      final yas = int.tryParse(girilen);
      if (yas != null && yas >= 10 && yas <= 100) {
        context.read<SuTakipProvider>().yasGuncelle(yas);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Lütfen 10 ile 100 arasında geçerli bir yaş girin.'),
          ),
        );
      }
    }
  }

  Future<void> _hedefDegistir(BuildContext context) async {
    final mevcutHedef = context.read<SuTakipProvider>().gunlukHedef.toString();
    final girilen = await _metinGirisDialogu(
      context: context,
      baslik: 'Manuel Su Hedefi (500 - 10000 ml)',
      ipucu: '2500',
      baslangicDegeri: mevcutHedef,
      sayisalMi: true,
    );
    if (girilen != null && context.mounted) {
      final hedef = int.tryParse(girilen);
      if (hedef != null && hedef >= 500 && hedef <= 10000) {
        context.read<SuTakipProvider>().hedefGuncelle(hedef);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen 500 ile 10000 ml arasında bir hedef girin.'),
          ),
        );
      }
    }
  }

  Future<void> _bardakBoyutuDegistir(BuildContext context) async {
    final mevcutBoyut = context.read<SuTakipProvider>().bardakBoyutu.toString();
    final girilen = await _metinGirisDialogu(
      context: context,
      baslik: 'Bardak Boyutu (50 - 2000 ml)',
      ipucu: '250',
      baslangicDegeri: mevcutBoyut,
      sayisalMi: true,
    );
    if (girilen != null && context.mounted) {
      final boyut = int.tryParse(girilen);
      if (boyut != null && boyut >= 50 && boyut <= 2000) {
        context.read<SuTakipProvider>().bardakBoyutuGuncelle(boyut);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen 50 ile 2000 ml arasında bir boyut girin.'),
          ),
        );
      }
    }
  }

  Future<String?> _metinGirisDialogu({
    required BuildContext context,
    required String baslik,
    required String ipucu,
    required String baslangicDegeri,
    required bool sayisalMi,
  }) async {
    final controller = TextEditingController(text: baslangicDegeri);
    final sonuc = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(baslik),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: sayisalMi ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(hintText: ipucu),
          onSubmitted: (val) => Navigator.pop(dialogContext, val),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    controller.dispose();
    return sonuc;
  }

  void _verileriSifirla(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Emin misiniz?'),
        content: const Text(
          'Tüm su takip verileriniz silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<SuTakipProvider>().verileriSifirla();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tüm su takip verileri sıfırlandı.'),
                ),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
