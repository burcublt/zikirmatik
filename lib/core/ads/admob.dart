import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsState {
  const AdsState({
    this.canRequest = false,
    this.privacyOptionsRequired = false,
  });
  final bool canRequest;
  final bool privacyOptionsRequired;
}

abstract final class AdUnits {
  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  static bool get _android => defaultTargetPlatform == TargetPlatform.android;
  static String get native => !kReleaseMode
      ? (_android
            ? 'ca-app-pub-3940256099942544/2247696110'
            : 'ca-app-pub-3940256099942544/3986624511')
      : (_android
            ? const String.fromEnvironment('ADMOB_ANDROID_NATIVE')
            : const String.fromEnvironment('ADMOB_IOS_NATIVE'));
  static String get banner => !kReleaseMode
      ? (_android
            ? 'ca-app-pub-3940256099942544/9214589741'
            : 'ca-app-pub-3940256099942544/2435281174')
      : (_android
            ? const String.fromEnvironment('ADMOB_ANDROID_BANNER')
            : const String.fromEnvironment('ADMOB_IOS_BANNER'));
}

final adsControllerProvider = AsyncNotifierProvider<AdsController, AdsState>(
  AdsController.new,
);

class AdsController extends AsyncNotifier<AdsState> {
  @override
  Future<AdsState> build() async {
    if (!AdUnits.supported) return const AdsState();
    try {
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => updated.complete(),
        (_) => updated.complete(),
      );
      await updated.future;
      await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
      return await _readState();
    } catch (_) {
      // An unavailable platform channel or consent service must not block counting.
      return const AdsState();
    }
  }

  Future<AdsState> _readState() async {
    final allowed = await ConsentInformation.instance.canRequestAds();
    if (allowed) await MobileAds.instance.initialize();
    final privacy = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    return AdsState(
      canRequest: allowed,
      privacyOptionsRequired:
          privacy == PrivacyOptionsRequirementStatus.required,
    );
  }

  Future<void> showPrivacyOptions() async {
    FormError? formError;
    await ConsentForm.showPrivacyOptionsForm((error) => formError = error);
    if (formError != null) throw formError!;
    state = AsyncData(await _readState());
  }
}

enum AdPlacement { zikrList, statistics }

/// The SDK owns creative content, disclosure and click handling.
/// Empty/failed/unsupported placements collapse completely.
class AdMobSlot extends ConsumerWidget {
  const AdMobSlot({super.key, required this.placement});
  final AdPlacement placement;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed =
        ref.watch(adsControllerProvider).asData?.value.canRequest ?? false;
    if (!allowed) return const SizedBox.shrink();
    final id = placement == AdPlacement.zikrList
        ? AdUnits.native
        : AdUnits.banner;
    if (id.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, box) => _LoadedAd(
        key: ValueKey('$placement-${box.maxWidth.floor()}-$id'),
        placement: placement,
        width: box.maxWidth.floor(),
        adUnitId: id,
      ),
    );
  }
}

class _LoadedAd extends StatefulWidget {
  const _LoadedAd({
    super.key,
    required this.placement,
    required this.width,
    required this.adUnitId,
  });
  final AdPlacement placement;
  final int width;
  final String adUnitId;
  @override
  State<_LoadedAd> createState() => _LoadedAdState();
}

class _LoadedAdState extends State<_LoadedAd> {
  AdWithView? _ad;
  bool _loaded = false;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  void _onLoaded(Ad ad) {
    if (!mounted || ad != _ad) return;
    setState(() => _loaded = true);
  }

  void _onFailed(Ad ad, LoadAdError error) {
    debugPrint(
      'AdMob ${widget.placement} failed: ${error.code} ${error.message}',
    );
    if (!mounted || ad != _ad) return;
    ad.dispose();
    _ad = null;
    setState(() => _loaded = false);
  }

  Future<void> _load() async {
    try {
      if (widget.placement == AdPlacement.zikrList) {
        _height = 132;
        final ad = NativeAd(
          adUnitId: widget.adUnitId,
          request: const AdRequest(),
          listener: NativeAdListener(
            onAdLoaded: _onLoaded,
            onAdFailedToLoad: _onFailed,
          ),
          factoryId: 'zikrCard',
          customOptions: {'width': widget.width},
        );
        _ad = ad;
        await ad.load();
      } else {
        final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
          widget.width,
        );
        if (!mounted || size == null) return;
        _height = size.height.toDouble();
        final ad = BannerAd(
          adUnitId: widget.adUnitId,
          size: size,
          request: const AdRequest(),
          listener: BannerAdListener(
            onAdLoaded: _onLoaded,
            onAdFailedToLoad: _onFailed,
          ),
        );
        _ad = ad;
        await ad.load();
      }
    } catch (error) {
      debugPrint('AdMob ${widget.placement} exception: $error');
      if (mounted) {
        _ad?.dispose();
        _ad = null;
        setState(() => _loaded = false);
      }
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: SizedBox(
          width: widget.width.toDouble(),
          height: _height,
          child: AdWidget(ad: _ad!),
        ),
      ),
    );
  }
}
