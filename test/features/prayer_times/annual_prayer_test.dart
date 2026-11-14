import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/features/prayer_times/data/annual_prayer_repository.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_region.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

Future<String> asset(String path) async => File(path).readAsString();
const selected = PrayerLocation(
  latitude: 0,
  longitude: 0,
  label: 'İstanbul',
  annualRegionId: '9541',
  countryCode: 'TR',
  manual: true,
  coordinatesKnown: false,
);
void main() {
  final now = DateTime.utc(2026, 11, 13, 10);
  final catalog = PrayerRegionCatalog.decode(
    File('assets/prayer_times/regions.json').readAsStringSync(),
  );
  final region = catalog.byId('9541')!;
  test('üç ilin 1095 günü Diyanet referansıyla eşleşir', () {
    final refs =
        jsonDecode(
              File(
                'test/fixtures/prayer_diyanet_reference_2026.json',
              ).readAsStringSync(),
            )
            as Map;
    for (final entry in (refs['regions'] as Map).entries) {
      final place = catalog.byId(entry.key as String)!;
      final days = decodeAnnualPrayerCalendar(
        File('assets/prayer_times/v1/2026/${place.id}.json').readAsStringSync(),
        place,
        2026,
      );
      final expected = (entry.value as Map)['days'] as Map;
      expect(expected.length, 365);
      for (final d in days) {
        final date =
            '${d.date.year}-${d.date.month.toString().padLeft(2, '0')}-${d.date.day.toString().padLeft(2, '0')}';
        expect(
          [
            for (final e in d.entries)
              '${e.at.hour.toString().padLeft(2, '0')}:${e.at.minute.toString().padLeft(2, '0')}',
          ],
          expected[date],
          reason: '${place.id} $date',
        );
      }
    }
  });
  test('eksik gün, yanlış bölge/yıl ve bozuk saat reddedilir', () {
    final original =
        jsonDecode(
              File('assets/prayer_times/v1/2026/9541.json').readAsStringSync(),
            )
            as Map;
    for (final mutation in <void Function(Map)>[
      (m) => m['region'] = '9206',
      (m) => m['year'] = 2025,
      (m) => (m['days'] as List).removeLast(),
      (m) => m['days'][0][1] = '24:00',
      (m) => m['days'][1][0] = '2026-01-01',
    ]) {
      final changed = jsonDecode(jsonEncode(original)) as Map;
      mutation(changed);
      expect(
        () => decodeAnnualPrayerCalendar(jsonEncode(changed), region, 2026),
        throwsFormatException,
      );
    }
  });
  test('tam il/ilçe eşleşmesi gerekir; il adı tek başına yeterli değildir', () {
    expect(
      catalog
          .match(
            const PrayerLocation(
              latitude: 41,
              longitude: 29,
              label: 'İstanbul',
              countryCode: 'TR',
              region: 'istanbul',
              district: 'istanbul',
            ),
          )
          ?.id,
      '9541',
    );
    expect(
      catalog.match(
        const PrayerLocation(
          latitude: 41,
          longitude: 29,
          label: 'Bilinmeyen',
          countryCode: 'TR',
          region: 'istanbul',
          district: 'Bilinmeyen',
        ),
      ),
      isNull,
    );
    expect(normalizeRegionName('Çığlı ŞÜÖİ'), 'CIGLISUOI');
  });
  test(
    'Türkiye yıllık veriyle internet isteği olmadan çalışır ve kalıcıdır',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      var calls = 0;
      final client = MockClient((r) async {
        calls++;
        throw StateError('Network forbidden');
      });
      addTearDown(client.close);
      final repo = AnnualPrayerRepository(db, client, asset, now: () => now);
      final result = await repo.load(selected);
      expect(result.source, 'diyanet-annual');
      expect(result.days.length, 365);
      expect(calls, 0);
      expect(result.dayAt(now)!.entries[3].at.minute, 30);
      final cached = await repo.readCache();
      expect(cached!.location.annualRegionId, '9541');
      expect(cached.location.coordinatesKnown, isFalse);
      expect((await repo.load(selected, cached: cached)).days.length, 365);
      expect(calls, 0);
    },
  );
  test(
    'eski AlAdhan Türkiye önbelleği Diyanet verisi olarak kullanılmaz',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final client = MockClient((r) async => http.Response('{}', 500));
      addTearDown(client.close);
      final legacy = PrayerSchedule(
        location: const PrayerLocation(
          latitude: 41,
          longitude: 29,
          label: 'İstanbul',
        ),
        timeZone: 'Europe/Istanbul',
        days: [],
      );
      await db
          .into(db.userPreferences)
          .insert(
            UserPreferencesCompanion.insert(
              id: const Value(5),
              localeCode: jsonEncode(legacy.toJson()),
              updatedAt: now,
            ),
          );
      final repo = AnnualPrayerRepository(db, client, asset, now: () => now);
      expect(await repo.readCache(), isNull);
      await expectLater(
        repo.load(legacy.location),
        throwsA(isA<PrayerRegionSelectionRequired>()),
      );
    },
  );
  test(
    'HTTPS dağıtım dosyası alınır; farklı bölge yanıtında yerel takvim korunur',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      var calls = 0;
      final client = MockClient((r) async {
        calls++;
        expect(r.url.toString(), 'https://calendar.example/v1/2026/9541.json');
        return http.Response(
          await asset('assets/prayer_times/v1/2026/9206.json'),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      addTearDown(client.close);
      final result = await AnnualPrayerRepository(
        db,
        client,
        asset,
        baseUrl: 'https://calendar.example',
        now: () => now,
      ).load(selected);
      expect(calls, 1);
      expect(result.location.annualRegionId, '9541');
      expect(result.dayAt(now)!.entries[3].at.minute, 30);
    },
  );
  test(
    'yıl sonunda ertesi yıl takvimi yoksa geçmiş imsak gösterilmez',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final client = MockClient((r) async => http.Response('{}', 404));
      addTearDown(client.close);
      final end = DateTime.utc(2027, 12, 31, 20);
      final repo = AnnualPrayerRepository(db, client, asset, now: () => end);
      final result = await repo.load(selected);
      expect(result.dayAt(end), isNotNull);
      expect(result.nextPrayer(end), isNull);
      await expectLater(
        AnnualPrayerRepository(
          db,
          client,
          asset,
          now: () => DateTime.utc(2028, 1, 1, 10),
        ).load(selected, cached: result),
        throwsA(isA<PrayerCalendarUnavailable>()),
      );
    },
  );
  test('Kıbrıs yıllık takvimi yerel saat dilimiyle okunur', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final client = MockClient(
      (r) async => throw StateError('Network forbidden'),
    );
    addTearDown(client.close);
    final cy = catalog.regions.firstWhere((r) => r.countryCode == 'CY');
    final result =
        await AnnualPrayerRepository(db, client, asset, now: () => now).load(
          PrayerLocation(
            latitude: 0,
            longitude: 0,
            label: cy.label,
            annualRegionId: cy.id,
            countryCode: 'CY',
            coordinatesKnown: false,
          ),
        );
    expect(result.source, 'diyanet-annual');
    expect(result.timeZone, 'Asia/Nicosia');
    expect(result.dayAt(now), isNotNull);
  });
  test('Yeni Kaledonya NC kodu Kıbrıs takvimiyle karışmaz', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fixture = File(
      'test/fixtures/prayer_calendar_istanbul.json',
    ).readAsStringSync();
    final client = MockClient((request) async {
      expect(request.url.host, 'api.aladhan.com');
      expect(request.url.queryParameters['method'], '3');
      return http.Response(
        fixture,
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    addTearDown(client.close);
    final result =
        await AnnualPrayerRepository(db, client, asset, now: () => now).load(
          const PrayerLocation(
            latitude: -22.27,
            longitude: 166.45,
            label: 'Nouméa',
            countryCode: 'NC',
          ),
        );
    expect(result.source, 'aladhan');
  });
}
