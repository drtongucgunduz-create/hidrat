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
                      const Icon(
                        Icons.history,
                        size: 18,
                        color: Color(0xFF1976D2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Seçili Tarih: ${provider.seciliTarihFormatli}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<SuTakipProvider>().buguneDon(),
                    child: const Text('Bugüne Dön'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  // Akıllı Hedef Bilgi Çubuğu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '🧠 Akıllı Hedef: ${provider.kilo}kg • ${provider.yas}y • ☕${provider.gunlukKafeinAdet}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '☕',
                                style: TextStyle(fontSize: 14),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 26,
                                  minHeight: 26,
                                ),
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 18,
                                  color: Color(0xFF1565C0),
                                ),
                                onPressed: provider.gunlukKafeinAdet > 0
                                    ? () => context
                                        .read<SuTakipProvider>()
                                        .gunlukKafeinGuncelle(
                                          provider.gunlukKafeinAdet - 1,
                                        )
                                    : null,
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 26,
                                  minHeight: 26,
                                ),
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 18,
                                  color: Color(0xFF1565C0),
                                ),
                                onPressed: provider.gunlukKafeinAdet < 15
                                    ? () => context
                                        .read<SuTakipProvider>()
                                        .gunlukKafeinGuncelle(
                                          provider.gunlukKafeinAdet + 1,
                                        )
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Su Seviyesi Göstergesi
                  SuSeviyesiGostergesi(
                    icilen: provider.seciliGunIcilen,
                    hedef: provider.gunlukHedef,
                  ),
                  const SizedBox(height: 20),
                  // Hızlı Ekle Butonları (Bardak Seçimi)
                  BardakSecimi(
                    varsayilanBardakMl: provider.bardakBoyutu,
                    seciliGunIcilen: provider.seciliGunIcilen,
                    sonEklenenMiktar: provider.sonEklenenMiktar,
                    onEkle: (ml) => context.read<SuTakipProvider>().suEkle(ml),
                    onAzalt: (ml) =>
                        context.read<SuTakipProvider>().suAzalt(ml),
                  ),
                ],
              ),
            ),
          ),
          // Reklam Banner
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
