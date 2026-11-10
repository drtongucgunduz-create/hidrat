import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BildirimServisi {
  static final BildirimServisi _instance = BildirimServisi._internal();
  factory BildirimServisi() => _instance;
  BildirimServisi._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _baslatildi = false;
  Timer? _periyodikTimer;

  Future<void> baslat() async {
    if (_baslatildi || kIsWeb) return;

    try {
      const androidAyar = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosAyar = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const linuxAyar = LinuxInitializationSettings(
        defaultActionName: 'Uygulamayı Aç',
      );

      const initAyar = InitializationSettings(
        android: androidAyar,
        iOS: iosAyar,
        macOS: iosAyar,
        linux: linuxAyar,
      );

      await _plugin.initialize(initAyar);

      if (!kIsWeb && Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
      }

      _baslatildi = true;
    } catch (e) {
      debugPrint('Bildirim servisi başlatılamadı: $e');
    }
  }

  bool sessizSaatteMi(TimeOfDay baslangic, TimeOfDay bitis) {
    final simdi = TimeOfDay.now();
    final simdiDakika = simdi.hour * 60 + simdi.minute;
    final basDakika = baslangic.hour * 60 + baslangic.minute;
    final bitDakika = bitis.hour * 60 + bitis.minute;

    if (basDakika <= bitDakika) {
      return simdiDakika >= basDakika && simdiDakika < bitDakika;
    } else {
      return simdiDakika >= basDakika || simdiDakika < bitDakika;
    }
  }

  Future<void> hatirlaticilariAyarla({
    required bool acik,
    required int siklikDakika,
    required TimeOfDay sessizBaslangic,
    required TimeOfDay sessizBitis,
  }) async {
    _periyodikTimer?.cancel();
    if (!kIsWeb && _baslatildi) {
      try {
        await _plugin.cancelAll();
      } catch (_) {}
    }

    if (!acik) return;

    _periyodikTimer = Timer.periodic(
      Duration(minutes: siklikDakika.clamp(15, 240)),
      (_) async {
        if (!sessizSaatteMi(sessizBaslangic, sessizBitis)) {
          await anlikBildirimGoster(
            baslik: '💧 Su İçme Zamanı!',
            icerik: 'Vücudunu susuz bırakma, bir bardak su içmeyi unutma!',
          );
        }
      },
    );

    if (!kIsWeb && _baslatildi && (Platform.isAndroid || Platform.isIOS)) {
      try {
        const detaylar = NotificationDetails(
          android: AndroidNotificationDetails(
            'hidrat_hatirlatici_kanal',
            'Su Hatırlatıcıları',
            channelDescription: 'Düzenli su içme hatırlatma bildirimleri',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        );

        if (siklikDakika == 60) {
          await _plugin.periodicallyShow(
            100,
            '💧 Su İçme Zamanı!',
            'Günlük su hedefine ulaşmak için bir bardak su iç!',
            RepeatInterval.hourly,
            detaylar,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        }
      } catch (e) {
        debugPrint('Periyodik bildirim kurulamadı: $e');
      }
    }
  }

  Future<bool> anlikBildirimGoster({
    required String baslik,
    required String icerik,
  }) async {
    if (kIsWeb) return false;
    if (!_baslatildi) {
      await baslat();
    }
    if (!_baslatildi) return false;

    try {
      const detaylar = NotificationDetails(
        android: AndroidNotificationDetails(
          'hidrat_hatirlatici_kanal',
          'Su Hatırlatıcıları',
          channelDescription: 'Düzenli su içme hatırlatma bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        baslik,
        icerik,
        detaylar,
      );
      return true;
    } catch (e) {
      debugPrint('Bildirim gönderilemedi: $e');
      return false;
    }
  }
}
