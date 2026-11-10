import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/su_takip_provider.dart';
import '../widgets/su_seviyesi_gostergesi.dart';
import '../widgets/bardak_secimi.dart';
import '../widgets/reklam_banner.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuTakipProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('💧 Merhaba, ${provider.kullaniciAdi}'),
        actions: [
          IconButton(
            tooltip: 'Tarih Seç',
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _tarihSec(context, provider.seciliTarih),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!provider.seciliTarihBugunMu)
            Container(
              width: double.infinity,
              color: const Color(0xFFE3F2FD),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history, size: 18, color: Color(0xFF1976D2)),
                      const SizedBox(width: 8),
                      Text(
                        'Seçili Tarih: ${provider.seciliTarihFormatli}',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1976D2)),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.read<SuTakipProvider>().buguneDon(),
                    child: const Text('Bugüne Dön'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  SuSeviyesiGostergesi(
                    icilen: provider.seciliGunIcilen,
                    hedef: provider.gunlukHedef,
                  ),
                  const SizedBox(height: 24),
                  BardakSecimi(
                    varsayilanBardakMl: provider.bardakBoyutu,
                    seciliGunIcilen: provider.seciliGunIcilen,
                    sonEklenenMiktar: provider.sonEklenenMiktar,
                    onEkle: (ml) => context.read<SuTakipProvider>().suEkle(ml),
                    onAzalt: (ml) => context.read<SuTakipProvider>().suAzalt(ml),
                  ),
                ],
              ),
            ),
          ),
          const ReklamBanner(),
        ],
      ),
    );
  }

  Future<void> _tarihSec(BuildContext context, DateTime mevcutTarih) async {
    final simdi = DateTime.now();
    final ilkTarih = DateTime(2024);
    final secili = mevcutTarih.isAfter(simdi) ? simdi : mevcutTarih;

    final tarih = await showDatePicker(
      context: context,
      initialDate: secili.isBefore(ilkTarih) ? ilkTarih : secili,
      firstDate: ilkTarih,
      lastDate: simdi,
    );
    if (tarih != null && context.mounted) {
      context.read<SuTakipProvider>().tarihDegistir(tarih);
    }
  }
}
