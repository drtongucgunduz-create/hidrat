import 'package:flutter/material.dart';

class BardakSecimi extends StatefulWidget {
  final int varsayilanBardakMl;
  final int seciliGunIcilen;
  final int? sonEklenenMiktar;
  final Function(int ml) onEkle;
  final Function(int ml) onAzalt;

  const BardakSecimi({
    super.key,
    required this.varsayilanBardakMl,
    required this.seciliGunIcilen,
    this.sonEklenenMiktar,
    required this.onEkle,
    required this.onAzalt,
  });

  @override
  State<BardakSecimi> createState() => _BardakSecimiState();
}

class _BardakSecimiState extends State<BardakSecimi> {
  final TextEditingController _ozelMiktarController = TextEditingController();

  @override
  void dispose() {
    _ozelMiktarController.dispose();
    super.dispose();
  }

  void _ozelMiktarGonder() {
    final ml = int.tryParse(_ozelMiktarController.text.trim());
    if (ml != null && ml > 0 && ml <= 5000) {
      widget.onEkle(ml);
      _ozelMiktarController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Lütfen 1 ile 5000 ml arasında geçerli bir miktar girin.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hızlı Ekle 💧',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              if (widget.seciliGunIcilen > 0)
                TextButton.icon(
                  onPressed: () {
                    final azaltilacak =
                        widget.sonEklenenMiktar ?? widget.varsayilanBardakMl;
                    widget.onAzalt(azaltilacak);
                  },
                  icon: const Icon(
                    Icons.undo,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  label: Text(
                    '-${widget.sonEklenenMiktar ?? widget.varsayilanBardakMl} ml Geri Al',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bardakButonu(
                '🥛',
                'Bardak\n(Özel)',
                widget.varsayilanBardakMl,
                const Color(0xFF64B5F6),
              ),
              _bardakButonu(
                '🥤',
                'Büyük\nBardak',
                330,
                const Color(0xFF42A5F5),
              ),
              _bardakButonu(
                '🍶',
                'Küçük\nŞişe',
                500,
                const Color(0xFF2196F3),
              ),
              _bardakButonu(
                '🫗',
                'Sürahi',
                1000,
                const Color(0xFF1E88E5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Özel Miktar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ozelMiktarController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _ozelMiktarGonder(),
                  decoration: InputDecoration(
                    hintText: 'Özel miktar (ml)',
                    prefixIcon: const Icon(
                      Icons.edit,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2196F3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _ozelMiktarGonder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ekle',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bardakButonu(String emoji, String label, int ml, Color renk) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => widget.onEkle(ml),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: renk.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: renk, width: 2),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              '$ml ml',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
