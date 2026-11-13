import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_location_service.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_repository.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';
import 'package:zikirmatik/features/qibla/application/qibla_providers.dart';

class _Gps implements PrayerLocationService {
  final requests = <bool>[];
  @override
  Future<PrayerLocation> current({required bool requestPermission}) async {
    requests.add(requestPermission);
    throw const PrayerLocationException(PrayerLocationIssue.denied);
  }

  @override
  Future<PrayerLocation> findCity(String city) async =>
      throw UnimplementedError();
}

class _Repository implements PrayerRepository {
  _Repository(this.cached);
  final PrayerSchedule? cached;
  @override
  Future<PrayerSchedule?> readCache() async => cached;
  @override
  Future<PrayerSchedule> load(
    PrayerLocation location, {
    PrayerSchedule? cached,
    bool force = false,
  }) async => throw StateError('Qibla must not require prayer API');
}

void main() {
  for (final manual in [false, true]) {
    test(
      manual
          ? 'elle seçilen şehir GPS ile değiştirilmez'
          : 'izin reddinde kayıtlı konum kullanılabilir',
      () async {
        final gps = _Gps();
        final c = ProviderContainer(
          overrides: [
            prayerLocationServiceProvider.overrideWithValue(gps),
            prayerRepositoryProvider.overrideWithValue(
              _Repository(
                PrayerSchedule(
                  location: PrayerLocation(
                    latitude: 41.01,
                    longitude: 28.98,
                    label: 'İstanbul',
                    manual: manual,
                  ),
                  timeZone: 'Europe/Istanbul',
                  days: const [],
                ),
              ),
            ),
          ],
        );
        addTearDown(c.dispose);
        final sub = c.listen(qiblaLocationProvider, (_, _) {});
        addTearDown(sub.close);
        final result = await c.read(qiblaLocationProvider.future);
        expect(result.location.label, 'İstanbul');
        expect(result.saved, !manual);
        expect(gps.requests, manual ? isEmpty : [false]);
      },
    );
  }
  test('ilk açılış konum izni istemez; eylemle bir kez istenir', () async {
    final gps = _Gps();
    final c = ProviderContainer(
      overrides: [
        prayerLocationServiceProvider.overrideWithValue(gps),
        prayerRepositoryProvider.overrideWithValue(_Repository(null)),
      ],
    );
    addTearDown(c.dispose);
    final sub = c.listen(qiblaLocationProvider, (_, _) {});
    addTearDown(sub.close);
    await expectLater(
      c.read(qiblaLocationProvider.future),
      throwsA(isA<PrayerLocationException>()),
    );
    expect(gps.requests, [false]);
    await c.read(qiblaLocationProvider.notifier).useLocation();
    expect(gps.requests, [false, true]);
    expect(c.read(qiblaLocationProvider).hasError, isTrue);
  });
}
