// lib/core/widgets/app_banner_ad.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_manager.dart';

/// A self-loading, self-disposing AdMob banner ad widget.
///
/// Drop this anywhere in your widget tree — it handles its own lifecycle.
/// Renders nothing (SizedBox.shrink) if the ad is not yet loaded or failed.
///
/// Example usage on the Hirer Dashboard:
/// ```dart
/// Column(
///   children: [
///     // ... dashboard content ...
///     const AppBannerAd(),
///   ],
/// )
/// ```
class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key});

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (AdManager.instance.isLoaded) {
      _isLoaded = true;
    } else {
      AdManager.instance.loadBannerAd(
        onLoaded: () {
          if (mounted) setState(() => _isLoaded = true);
        },
      );
    }
  }

  @override
  void dispose() {
    AdManager.instance.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = AdManager.instance.bannerAd;
    if (!_isLoaded || ad == null) return const SizedBox.shrink();

    return Container(
      alignment: Alignment.center,
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
