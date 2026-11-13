import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:true_compass/true_compass.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

class QiblaLocation {
  const QiblaLocation(this.location, {this.saved = false});
  final PrayerLocation location;
  final bool saved;
}

final qiblaLocationProvider =
    AsyncNotifierProvider.autoDispose<QiblaLocationNotifier, QiblaLocation>(
      QiblaLocationNotifier.new,
      retry: (_, _) => null,
    );

class QiblaLocationNotifier extends AsyncNotifier<QiblaLocation> {
  bool _busy = false;
  @override
  Future<QiblaLocation> build() => _load(false);
  Future<QiblaLocation> _load(bool request) async {
    PrayerSchedule? cache;
    try {
      cache = await ref.read(prayerRepositoryProvider).readCache();
    } catch (_) {}
    if (!ref.mounted) throw StateError('disposed');
    if (!request &&
        cache != null &&
        cache.location.manual &&
        cache.location.coordinatesKnown) {
      return QiblaLocation(cache.location);
    }
    try {
      final location = await ref
          .read(prayerLocationServiceProvider)
          .current(requestPermission: request);
      return QiblaLocation(location);
    } catch (_) {
      if (cache != null && cache.location.coordinatesKnown && !request) {
        return QiblaLocation(cache.location, saved: true);
      }
      if (!request &&
          cache != null &&
          cache.location.manual &&
          !cache.location.coordinatesKnown) {
        try {
          final city = cache.location;
          final coordinates = await ref
              .read(prayerLocationServiceProvider)
              .findCity(
                '${city.district}, ${city.region}, ${city.countryCode}',
              );
          return QiblaLocation(coordinates, saved: true);
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<void> useLocation() async {
    if (_busy || state.isLoading) return;
    _busy = true;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => _load(true));
    if (ref.mounted) state = result;
    _busy = false;
  }
}

abstract interface class QiblaCompassService {
  Stream<CompassHeading> headings(PrayerLocation location);
}

class DeviceQiblaCompassService implements QiblaCompassService {
  @override
  Stream<CompassHeading> headings(PrayerLocation location) async* {
    final compass = TrueCompass(
      options: CompassOptions(
        location: CompassLocation(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
        updateInterval: const Duration(milliseconds: 100),
      ),
    );
    try {
      if (await compass.checkAvailability() != CompassAvailability.available) {
        throw StateError('Compass unavailable');
      }
      final field = MagneticDeclination.field(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      if (!field.isWithinValidity) throw StateError('Magnetic model expired');
      yield* compass.headings
          .where((h) => h.trueHeading?.isFinite == true)
          .timeout(const Duration(seconds: 8));
    } finally {
      await compass.dispose();
    }
  }
}

final qiblaCompassServiceProvider = Provider<QiblaCompassService>(
  (ref) => DeviceQiblaCompassService(),
);
final qiblaHeadingProvider = StreamProvider.autoDispose
    .family<CompassHeading, PrayerLocation>(
      (ref, location) =>
          ref.watch(qiblaCompassServiceProvider).headings(location),
    );
