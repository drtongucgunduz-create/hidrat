# Hidrat - Su İçme Hatırlatıcısı

## 📁 Klasör Yapısı
```
hidrat_app/
├── pubspec.yaml
├── analysis_options.yaml
├── hidrat_uygulama.html          -> Tarayıcıda doğrudan açıp kullanabileceğiniz tam sürüm
├── android/app/src/main/AndroidManifest.xml
├── ios/Runner/Info.plist
├── assets/
│   ├── images/
│   └── sounds/
└── lib/
    ├── main.dart
    ├── services/
    │   └── bildirim_servisi.dart
    ├── providers/
    │   └── su_takip_provider.dart
    ├── screens/
    │   ├── home_page.dart
    │   ├── istatistik_page.dart
    │   ├── ayarlar_page.dart
    │   └── hatirlatici_page.dart
    └── widgets/
        ├── su_seviyesi_gostergesi.dart
        ├── bardak_secimi.dart
        └── reklam_banner.dart
```

## 🌐 Hemen Kullanım (Kurulumsuz - Tarayıcıda)
Bilgisayarınızda Flutter SDK kurulu olmasa bile **`hidrat_uygulama.html`** dosyasına çift tıklayarak uygulamayı tüm özellikleriyle (canlı dalga animasyonu, grafikler, seri takibi, tarayıcı bildirimleri, yerel veri kaydı) hemen kullanabilirsiniz.

## 🔧 Flutter İle Derleme ve Kurulum Adımları
1. Flutter SDK'nın kurulu olduğundan emin olun.
2. Terminalde proje klasörüne gidin:
   ```bash
   cd hidrat_app
   ```
3. Eksik platform dosyalarını tamamlayın ve bağımlılıkları yükleyin:
   ```bash
   flutter create .
   flutter pub get
   ```
4. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

## 📱 Yayınlama Notları
- `android/app/src/main/AndroidManifest.xml` ve `ios/Runner/Info.plist` içindeki AdMob test uygulama ID'lerini ve `lib/widgets/reklam_banner.dart` içindeki test reklam birimi ID'lerini kendi AdMob ID'lerinizle değiştirin.
- Android APK derlemek için: `flutter build apk --release`
- iOS derlemek için: `flutter build ios --release`
