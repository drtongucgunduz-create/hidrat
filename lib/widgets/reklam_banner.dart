import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ReklamBanner extends StatefulWidget {
  const ReklamBanner({super.key});

  @override
  State<ReklamBanner> createState() => _ReklamBannerState();
}

class _ReklamBannerState extends State<ReklamBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  bool get _reklamDestekleniyor =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  String get _adUnitId {
    if (!kIsWeb && Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  @override
  void initState() {
    super.initState();
    if (_reklamDestekleniyor) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() => _isLoaded = false);
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_reklamDestekleniyor) {
      return const SizedBox.shrink();
    }
    return _isLoaded && _bannerAd != null
        ? Container(
            alignment: Alignment.center,
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox(height: 50);
  }
}
