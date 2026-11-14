import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdPlacement { zikrList, statistics }

/// Preparing a view must not start a request; its owner calls load after adoption.
abstract interface class AdSlotHandle {
  double get height;
  Future<void> load();
  Widget buildView();
  void dispose();
}

abstract interface class AdSlotLoader {
  Future<AdSlotHandle?> prepare({
    required AdPlacement placement,
    required int width,
    required String adUnitId,
    required VoidCallback onLoaded,
    required void Function(Object) onFailed,
  });
}

final adSlotLoaderProvider = Provider<AdSlotLoader>(
  (ref) => const GoogleAdSlotLoader(),
);

class GoogleAdSlotLoader implements AdSlotLoader {
  const GoogleAdSlotLoader();
  @override
  Future<AdSlotHandle?> prepare({
    required AdPlacement placement,
    required int width,
    required String adUnitId,
    required VoidCallback onLoaded,
    required void Function(Object) onFailed,
  }) async {
    if (placement == AdPlacement.zikrList) {
      final ad = NativeAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        factoryId: 'zikrCard',
        customOptions: {'width': width},
        listener: NativeAdListener(
          onAdLoaded: (_) => onLoaded(),
          onAdFailedToLoad: (_, error) => onFailed(error),
        ),
      );
      return _GoogleAdHandle(ad, 132);
    }
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null) return null;
    final ad = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (_, error) => onFailed(error),
      ),
    );
    return _GoogleAdHandle(ad, size.height.toDouble());
  }
}

class _GoogleAdHandle implements AdSlotHandle {
  _GoogleAdHandle(this.ad, this.height);
  final AdWithView ad;
  @override
  final double height;
  bool _disposed = false;
  @override
  Future<void> load() => ad.load();
  @override
  Widget buildView() => AdWidget(ad: ad);
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(
      ad.dispose().catchError((Object error) {
        debugPrint('AdMob dispose failed: $error');
      }),
    );
  }
}
