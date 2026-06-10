import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

/// Manages the lifecycle of AdMob ad units.
///
/// Usage:
///   1. AdMob SDK is initialized in main.dart (non-blocking, after runApp).
///   2. Call [AdManager.instance.loadBannerAd()] once — usually triggered by
///      the [AppBannerAd] widget on first build.
///   3. Drop <AppBannerAd /> anywhere in the widget tree.
///
/// IMPORTANT: Replace test ad unit IDs with real IDs before publishing.
class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  static final _log = Logger();

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  bool get isLoaded => _isLoaded;
  BannerAd? get bannerAd => _bannerAd;

  /// Google test banner ad unit IDs.
  /// Android: ca-app-pub-3940256099942544/6300978111
  /// iOS:     ca-app-pub-3940256099942544/2934735716
  static String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  /// Loads a standard 320×50 banner ad.
  /// [onLoaded] is called once the ad is ready so widgets can call setState.
  Future<void> loadBannerAd({VoidCallback? onLoaded}) async {
    if (_isLoaded || _isLoading) return;
    _isLoading = true;
    _log.d('[AdMob] Loading banner ad…');

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoaded = true;
          _isLoading = false;
          _log.i('[AdMob] Banner ad loaded ✓');
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          _isLoaded = false;
          _isLoading = false;
          ad.dispose();
          _bannerAd = null;
          _log.w('[AdMob] Banner ad failed to load: ${error.message}');
        },
        onAdOpened: (_) => _log.d('[AdMob] Banner ad opened'),
        onAdClosed: (_) => _log.d('[AdMob] Banner ad closed'),
      ),
    );

    await _bannerAd!.load();
  }

  /// Disposes the current banner ad — call when the hosting screen is disposed.
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
    _isLoading = false;
    _log.d('[AdMob] Banner ad disposed');
  }
}
