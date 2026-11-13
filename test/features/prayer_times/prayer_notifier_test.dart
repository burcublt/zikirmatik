import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_location_service.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_repository.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

class _Location implements PrayerLocationService {
  int requests = 0;
  @override
  Future<PrayerLocation> current({required bool requestPermission}) async {
    if (requestPermission) requests++;
    throw const PrayerLocationException(PrayerLocationIssue.denied);
  }

  @override
  Future<PrayerLocation> findCity(String city) async => PrayerLocation(
    latitude: 41.01,
    longitude: 28.98,
    label: city,
    manual: true,
  );
}

class _Repository implements PrayerRepository {
  PrayerSchedule? cached;
  @override
  Future<PrayerSchedule?> readCache() async => cached;
  @override
  Future<PrayerSchedule> load(
    PrayerLocation location, {
    PrayerSchedule? cached,
    bool force = false,
  }) async => cached!;
}

void main() {
  test(
    'ilk açılış izin istemez; kullanıcı isterse bir kez izin akışına girer',
    () async {
      final location = _Location();
      final repo = _Repository();
      final c = ProviderContainer(
        overrides: [
          prayerLocationServiceProvider.overrideWithValue(location),
          prayerRepositoryProvider.overrideWithValue(repo),
        ],
      );
      expect(
        (await c.read(prayerNotifierProvider.future)).status,
        PrayerStatus.denied,
      );
      expect(location.requests, 0);
      await c
          .read(prayerNotifierProvider.notifier)
          .refresh(requestPermission: true);
      expect(location.requests, 1);
      expect(c.read(prayerNotifierProvider).requireValue.schedule, isNull);
      c.dispose();
    },
  );
  test(
    'izin reddinde geçerli son konum saklandığı belirtilerek gösterilir',
    () async {
      ensurePrayerTimeZones();
      final zone = tz.getLocation('Europe/Istanbul');
      final repo = _Repository()
        ..cached = PrayerSchedule(
          location: const PrayerLocation(
            latitude: 41.01,
            longitude: 28.98,
            label: 'İstanbul',
          ),
          timeZone: zone.name,
          days: [
            PrayerDay(
              date: tz.TZDateTime(zone, 2026, 11, 13),
              entries: [
                PrayerEntry(
                  PrayerName.isha,
                  tz.TZDateTime(zone, 2026, 11, 13, 19, 17),
                ),
              ],
            ),
          ],
        );
      final c = ProviderContainer(
        overrides: [
          prayerLocationServiceProvider.overrideWithValue(_Location()),
          prayerRepositoryProvider.overrideWithValue(repo),
          prayerNowProvider.overrideWithValue(
            () => DateTime.utc(2026, 11, 13, 10),
          ),
        ],
      );
      final result = await c.read(prayerNotifierProvider.future);
      expect(result.status, PrayerStatus.ready);
      expect(result.savedLocation, true);
      expect(result.schedule!.location.label, 'İstanbul');
      c.dispose();
    },
  );
}
