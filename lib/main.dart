import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'providers/su_takip_provider.dart';
import 'services/bildirim_servisi.dart';
import 'screens/home_page.dart';
import 'screens/ayarlar_page.dart';
import 'screens/istatistik_page.dart';
import 'screens/hatirlatici_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sadece desteklenen mobil platformlarda AdMob'u başlat
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdMob başlatılamadı: $e');
    }
  }

  // Bildirim servisini başlat
  await BildirimServisi().baslat();

  runApp(const HidratApp());
}

class HidratApp extends StatelessWidget {
  const HidratApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SuTakipProvider()..yukle(),
      child: MaterialApp(
        title: 'Hidrat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const AnaEkran(),
      ),
    );
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  int _aktifSekme = 0;

  final List<Widget> _sayfalar = const [
    HomePage(),
    IstatistikPage(),
    HatirlaticiPage(),
    AyarlarPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _aktifSekme,
        children: _sayfalar,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aktifSekme,
        onDestinationSelected: (index) {
          setState(() => _aktifSekme = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'İstatistik',
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: 'Hatırlatıcı',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
