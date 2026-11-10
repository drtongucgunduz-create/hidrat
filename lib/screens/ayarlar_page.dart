import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/su_takip_provider.dart';

class AyarlarPage extends StatelessWidget {
  const AyarlarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuTakipProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ayarlarBolumu('👤 Profil', [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('İsim'),
              subtitle: Text(provider.kullaniciAdi),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _isimDegistir(context),
            ),
            ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: const Text('Kilo'),
              subtitle: Text('${provider.kilo} kg (Önerilen: ${provider.kilo * 35} ml)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _kiloDegistir(context),
            ),
          ]),
          const SizedBox(height: 16),
          _ayarlarBolumu('🎯 Su Hedefi', [
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Günlük Hedef'),
              subtitle: Text('${provider.gunlukHedef} ml'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _hedefDegistir(context),
            ),
            ListTile(
              leading: const Icon(Icons.local_drink),
              title: const Text('Varsayılan Bardak Boyutu'),
              subtitle: Text('${provider.bardakBoyutu} ml'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _bardakBoyutuDegistir(context),
            ),
          ]),
          const SizedBox(height: 16),
          _ayarlarBolumu('💾 Veri', [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Verileri Sıfırla', style: TextStyle(color: Colors.red)),
              onTap: () => _verileriSifirla(context),
            ),
          ]),
          const SizedBox(height: 32),
          const Center(
            child: Column(
              children: [
                Icon(Icons.water_drop, size: 48, color: Color(0xFF2196F3)),
                SizedBox(height: 8),
                Text('Hidrat v1.0.0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Su içmeyi unutma! 💧', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Column(children: cocuklar),
        ),
      ],
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
          const SnackBar(content: Text('Lütfen 20 ile 300 kg arasında geçerli bir değer girin.')),
        );
      }
    }
  }

  Future<void> _hedefDegistir(BuildContext context) async {
    final mevcutHedef = context.read<SuTakipProvider>().gunlukHedef.toString();
    final girilen = await _metinGirisDialogu(
      context: context,
      baslik: 'Günlük Su Hedefi (500 - 10000 ml)',
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
          const SnackBar(content: Text('Lütfen 500 ile 10000 ml arasında bir hedef girin.')),
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
          const SnackBar(content: Text('Lütfen 50 ile 2000 ml arasında bir boyut girin.')),
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
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('İptal')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: const Text('Kaydet')),
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
        content: const Text('Tüm su takip verileriniz silinecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('İptal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<SuTakipProvider>().verileriSifirla();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm su takip verileri sıfırlandı.')),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
