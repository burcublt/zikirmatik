import 'ad_slot_loader.dart';
export 'ad_slot_loader.dart';
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
      builder: (context, box) {
        if (!box.hasBoundedWidth || box.maxWidth < 1) {
          return const SizedBox.shrink();
        }
        return _LoadedAd(
          key: ValueKey('$placement-${box.maxWidth.floor()}-$id'),
          placement: placement,
          width: box.maxWidth.floor(),
          adUnitId: id,
          loader: ref.watch(adSlotLoaderProvider),
        );
      },
    );
  }
}

class _LoadedAd extends StatefulWidget {
  const _LoadedAd({
    super.key,
    required this.placement,
    required this.width,
    required this.adUnitId,
    required this.loader,
  });
  final AdPlacement placement;
  final int width;
  final String adUnitId;
  final AdSlotLoader loader;
  @override
  State<_LoadedAd> createState() => _LoadedAdState();
}

class _LoadedAdState extends State<_LoadedAd> with WidgetsBindingObserver {
  AdSlotHandle? _handle;
  Timer? _retry, _watchdog, _cooldown;
  bool _loaded = false,
      _loading = false,
      _foreground = true,
      _waitingForResume = false;
  int _generation = 0, _failures = 0;
  static const _retryDelays = [
    Duration(seconds: 30),
    Duration(seconds: 60),
    Duration(seconds: 120),
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    if (_foreground) {
      unawaited(_load());
    } else {
      _waitingForResume = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final active = state == AppLifecycleState.resumed;
    if (active == _foreground) return;
    _foreground = active;
    if (!active) {
      _retry?.cancel();
      _retry = null;
      _waitingForResume = true;
      _release();
      setState(() {});
    } else {
      _failures = 0;
      if (_cooldown == null) {
        _waitingForResume = false;
        unawaited(_load());
      }
    }
  }

  void _release() {
    _generation++;
    _watchdog?.cancel();
    _watchdog = null;
    _handle?.dispose();
    _handle = null;
    _loading = false;
    _loaded = false;
  }

  void _failed(int generation, Object error) {
    if (!mounted || generation != _generation) return;
    debugPrint('AdMob ${widget.placement} failed: $error');
    _release();
    setState(() {});
    _failures++;
    if (!_foreground || _failures > _retryDelays.length) return;
    _retry?.cancel();
    _retry = Timer(_retryDelays[_failures - 1], () {
      _retry = null;
      unawaited(_load());
    });
  }

  Future<void> _load() async {
    if (!mounted || !_foreground || _loading || _loaded || _cooldown != null) {
      return;
    }
    _loading = true;
    final generation = ++_generation;
    // Rate-limit retries and rapid background/resume cycles without refreshing a
    // successfully displayed banner (SDK refresh remains the SDK's responsibility).
    _cooldown = Timer(const Duration(seconds: 30), () {
      _cooldown = null;
      if (mounted && _foreground && _waitingForResume) {
        _waitingForResume = false;
        unawaited(_load());
      }
    });
    _watchdog = Timer(
      const Duration(seconds: 25),
      () => _failed(generation, TimeoutException('Ad load timed out')),
    );
    try {
      final handle = await widget.loader.prepare(
        placement: widget.placement,
        width: widget.width,
        adUnitId: widget.adUnitId,
        onLoaded: () {
          if (!mounted || generation != _generation) return;
          _watchdog?.cancel();
          _watchdog = null;
          _loading = false;
          _failures = 0;
          setState(() => _loaded = true);
        },
        onFailed: (error) => _failed(generation, error),
      );
      if (!mounted || !_foreground || generation != _generation) {
        handle?.dispose();
        return;
      }
      if (handle == null) {
        _failed(generation, StateError('No adaptive ad size'));
        return;
      }
      _handle = handle;
      await handle.load();
    } catch (error) {
      _failed(generation, error);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _retry?.cancel();
    _cooldown?.cancel();
    _release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final handle = _handle;
    if (!_loaded || handle == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: SizedBox(
          width: widget.width.toDouble(),
          height: handle.height,
          child: KeyedSubtree(
            key: ObjectKey(handle),
            child: handle.buildView(),
          ),
        ),
      ),
    );
  }
}
