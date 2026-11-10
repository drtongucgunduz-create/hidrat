import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/su_takip_provider.dart';
import '../services/bildirim_servisi.dart';

class HatirlaticiPage extends StatefulWidget {
  const HatirlaticiPage({super.key});

  @override
  State<HatirlaticiPage> createState() => _HatirlaticiPageState();
}

class _HatirlaticiPageState extends State<HatirlaticiPage> {
  static const List<Map<String, dynamic>> _siklikSecenekleri = [
    {'etiket': '30 dakikada bir', 'dakika': 30},
    {'etiket': '1 saatte bir', 'dakika': 60},
    {'etiket': '1.5 saatte bir', 'dakika': 90},
    {'etiket': '2 saatte bir', 'dakika': 120},
  ];

  String _saatFormatla(TimeOfDay saat) {
    final s = saat.hour.toString().padLeft(2, '0');
    final d = saat.minute.toString().padLeft(2, '0');
    return '$s:$d';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuTakipProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('⏰ Hatırlatıcılar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF64B5F6)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, size: 40, color: Colors.white),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hatırlatıcılar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Su içmeyi unutma!', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                Switch(
                  value: provider.hatirlaticiAcik,
                  activeColor: Colors.white,
                  onChanged: (val) => provider.hatirlaticiDegistir(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Hatırlatma Sıklığı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
          const SizedBox(height: 12),
          ..._siklikSecenekleri.map((secenek) {
            final dakika = secenek['dakika'] as int;
            final etiket = secenek['etiket'] as String;
            final secili = provider.hatirlatmaSikligi == dakika;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: secili ? const Color(0xFF2196F3).withOpacity(0.1) : null,
              child: ListTile(
                leading: Icon(
                  secili ? Icons.check_circle : Icons.circle_outlined,
                  color: secili ? const Color(0xFF2196F3) : Colors.grey,
                ),
                title: Text(etiket, style: TextStyle(fontWeight: secili ? FontWeight.bold : FontWeight.normal)),
                onTap: () => provider.hatirlatmaSikligiGuncelle(dakika),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text('Sessiz Saatler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
          const SizedBox(height: 8),
          Text('Bu saatler arasında bildirim gelmez', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _saatSec('Başlangıç', provider.sessizBaslangic, (saat) => provider.sessizBaslangicGuncelle(saat)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('—', style: TextStyle(fontSize: 20)),
              ),
              Expanded(
                child: _saatSec('Bitiş', provider.sessizBitis, (saat) => provider.sessizBitisGuncelle(saat)),
              ),
            ],
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () async {
              final gonderildi = await BildirimServisi().anlikBildirimGoster(
                baslik: '💧 Hidrat Test Bildirimi',
                icerik: 'Harika! Su hatırlatıcı bildirimlerin sorunsuz çalışıyor.',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(gonderildi ? 'Test bildirimi gönderildi!' : 'Su içme zamanı! 💧 (Bildirim önizlemesi)'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.notifications_none),
            label: const Text('Test Bildirimi Gönder'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saatSec(String label, TimeOfDay saat, Function(TimeOfDay) onSecildi) {
    return GestureDetector(
      onTap: () async {
        final secilen = await showTimePicker(context: context, initialTime: saat);
        if (secilen != null) onSecildi(secilen);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              _saatFormatla(saat),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
            ),
          ],
        ),
      ),
    );
  }
}
