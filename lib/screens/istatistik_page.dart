import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/su_takip_provider.dart';

class IstatistikPage extends StatelessWidget {
  const IstatistikPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuTakipProvider>();
    final haftalikDetay = provider.haftalikDetayliVeri;
    final enYuksekGunluk = haftalikDetay.isEmpty ? 0.0 : haftalikDetay.map((e) => e.miktar).reduce(max);
    final grafikTavan = max(provider.gunlukHedef * 1.3, max(enYuksekGunluk * 1.2, 1000.0));

    return Scaffold(
      appBar: AppBar(title: const Text('📊 İstatistikler')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ozetKarti(provider),
            const SizedBox(height: 24),
            const Text(
              '📈 Son 7 Gün',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: grafikTavan,
                  barGroups: haftalikDetay.asMap().entries.map((entry) {
                    final veri = entry.value;
                    final hedefTamam = veri.miktar >= provider.gunlukHedef;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: veri.miktar,
                          color: hedefTamam
                              ? Colors.green
                              : (veri.bugunMu ? const Color(0xFF1565C0) : const Color(0xFF2196F3)),
                          width: 22,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= haftalikDetay.length) return const SizedBox.shrink();
                          final veri = haftalikDetay[idx];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              veri.kisaGunAdi,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: veri.bugunMu ? FontWeight.bold : FontWeight.normal,
                                color: veri.bugunMu ? const Color(0xFF1565C0) : Colors.black87,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}ml', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _istatistikKarti(
              '🔥 Mevcut Seri / En İyi Seri',
              '${provider.mevcutSeri} gün (Rekor: ${provider.enIyiSeri} gün)',
              Icons.local_fire_department,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _istatistikKarti(
              '💧 Toplam İçilen',
              '${provider.toplamIcilen} ml',
              Icons.water_drop,
              const Color(0xFF2196F3),
            ),
            const SizedBox(height: 12),
            _istatistikKarti(
              '📅 Ortalama/Gün',
              '${provider.gunlukOrtalama.toStringAsFixed(0)} ml',
              Icons.trending_up,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }
  Widget _ozetKarti(SuTakipProvider p) {
    final guvenliHedef = max(1, p.gunlukHedef);
    final yuzde = (p.bugunIcilen / guvenliHedef * 100).toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF64B5F6)]),
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
        children: [
          const Text('Bugün', style: TextStyle(fontSize: 18, color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            '${p.bugunIcilen} / ${p.gunlukHedef} ml',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text('%$yuzde tamamlandı', style: const TextStyle(fontSize: 16, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _istatistikKarti(String baslik, String deger, IconData icon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: renk, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(deger, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: renk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
