import 'dart:math';
import 'package:flutter/material.dart';

class SuSeviyesiGostergesi extends StatefulWidget {
  final int icilen;
  final int hedef;

  const SuSeviyesiGostergesi({
    super.key,
    required this.icilen,
    required this.hedef,
  });

  @override
  State<SuSeviyesiGostergesi> createState() => _SuSeviyesiGostergesiState();
}

class _SuSeviyesiGostergesiState extends State<SuSeviyesiGostergesi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dalgaController;

  @override
  void initState() {
    super.initState();
    _dalgaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _dalgaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guvenliHedef = max(1, widget.hedef);
    final hamYuzde = (widget.icilen / guvenliHedef * 100);
    final dolulukOrani = (widget.icilen / guvenliHedef).clamp(0.0, 1.0);
    final tamamlandiMi = widget.icilen >= guvenliHedef;

    return Column(
      children: [
        // Su Damlası Animasyonu
        SizedBox(
          width: 200,
          height: 210,
          child: AnimatedBuilder(
            animation: _dalgaController,
            builder: (context, _) {
              return CustomPaint(
                painter: _SuDamlasiPainter(
                  dolulukOrani: dolulukOrani,
                  dalgaFazi: _dalgaController.value * 2 * pi,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Yüzdelik Gösterim
        Text(
          '%${hamYuzde.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: tamamlandiMi ? Colors.green : const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.icilen} / ${widget.hedef} ml',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
        if (tamamlandiMi) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Hedef Tamamlandı!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SuDamlasiPainter extends CustomPainter {
  final double dolulukOrani;
  final double dalgaFazi;

  _SuDamlasiPainter({
    required this.dolulukOrani,
    required this.dalgaFazi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(size.width, size.height) / 2 - 10;

    // Arka Plan Daire
    final arkaplanPaint = Paint()
      ..color = const Color(0xFFE3F2FD)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), radius, arkaplanPaint);

    // Su Dolumu ve Dalga Efekti (sadece su içilmişse çiz)
    if (dolulukOrani > 0) {
      final suYuksekligi = max(4.0, radius * 2 * dolulukOrani);
      final suUstY = centerY + radius - suYuksekligi;
      final suRect = Rect.fromLTWH(
        centerX - radius,
        suUstY,
        radius * 2,
        suYuksekligi,
      );

      final suPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
        ).createShader(suRect);

      canvas.save();
      canvas.clipPath(
        Path()
          ..addOval(
            Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
          ),
      );

      // Ana su dalgası
      final suPath = Path();
      suPath.moveTo(centerX - radius, suUstY);
      for (double x = centerX - radius; x <= centerX + radius; x += 2) {
        final y = suUstY + sin((x * 0.04) + dalgaFazi) * 4;
        suPath.lineTo(x, y);
      }
      suPath.lineTo(centerX + radius, centerY + radius);
      suPath.lineTo(centerX - radius, centerY + radius);
      suPath.close();
      canvas.drawPath(suPath, suPaint);

      // İkinci açık renkli dalga katmanı
      final dalgaPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.fill;
      final dalgaPath = Path();
      dalgaPath.moveTo(centerX - radius, suUstY);
      for (double x = centerX - radius; x <= centerX + radius; x += 2) {
        final y = suUstY + cos((x * 0.04) - dalgaFazi) * 5;
        dalgaPath.lineTo(x, y);
      }
      dalgaPath.lineTo(centerX + radius, centerY + radius);
      dalgaPath.lineTo(centerX - radius, centerY + radius);
      dalgaPath.close();
      canvas.drawPath(dalgaPath, dalgaPaint);

      canvas.restore();
    }

    // Kenarlık
    final kenarlikPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(centerX, centerY), radius, kenarlikPaint);

    // Damla İkonu
    final damlaPath = Path();
    damlaPath.moveTo(centerX, centerY - radius + 24);
    damlaPath.quadraticBezierTo(
      centerX - 20,
      centerY - 5,
      centerX,
      centerY + 15,
    );
    damlaPath.quadraticBezierTo(
      centerX + 20,
      centerY - 5,
      centerX,
      centerY - radius + 24,
    );
    canvas.drawPath(
      damlaPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _SuDamlasiPainter oldDelegate) =>
      oldDelegate.dolulukOrani != dolulukOrani ||
      oldDelegate.dalgaFazi != dalgaFazi;
}
