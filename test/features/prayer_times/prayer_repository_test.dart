import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_repository.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

void main() {
  late AppDatabase db;
  final fixture = File(
    'test/fixtures/prayer_calendar_istanbul.json',
  ).readAsStringSync();
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());
  test(
    'yaklaşık koordinat ve Türkiye yöntemiyle yükler, geçerli cache ağsız açılır',
    () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        expect(request.url.queryParameters['latitude'], '41.01');
        expect(request.url.queryParameters['method'], '13');
        return http.Response(
          fixture,
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final repo = AlAdhanPrayerRepository(
        db,
        client,
        now: () => DateTime.utc(2026, 11, 13, 10),
      );
      const location = PrayerLocation(
        latitude: 41.01,
        longitude: 28.98,
        label: 'İstanbul',
      );
      final loaded = await repo.load(location);
      expect(loaded.timeZone, 'Europe/Istanbul');
      final cached = await repo.readCache();
      expect(cached, isNotNull);
      final offline = AlAdhanPrayerRepository(
        db,
        MockClient((_) async => throw const SocketException('offline')),
        now: () => DateTime.utc(2026, 11, 13, 10),
      );
      final result = await offline.load(location, cached: cached);
      expect(result.nextPrayer(DateTime.utc(2026, 11, 13, 10)), isNotNull);
      expect(calls, 1);
    },
  );
  test('aynı yerde elle şehir seçilmesi kalıcı manuel tercih olur', () async {
    final repo = AlAdhanPrayerRepository(
      db,
      MockClient((_) async => http.Response(fixture, 200)),
      now: () => DateTime.utc(2026, 11, 13, 10),
    );
    final cache = await repo.load(
      const PrayerLocation(latitude: 41.01, longitude: 28.98, label: 'Konumum'),
    );
    await repo.load(
      const PrayerLocation(
        latitude: 41.01,
        longitude: 28.98,
        label: 'İstanbul, Türkiye',
        manual: true,
      ),
      cached: cache,
    );
    expect((await repo.readCache())!.location.manual, true);
  });
  test(
    'ay sonu için ertesi ayı da alır; yatsıdan sonra gelecek gün bulunur',
    () async {
      var calls = 0;
      final repo = AlAdhanPrayerRepository(
        db,
        MockClient((request) async {
          calls++;
          if (request.url.path.endsWith('/12')) {
            final map = jsonDecode(fixture) as Map;
            final row = (map['data'] as List).first as Map;
            (row['date']['gregorian'] as Map)['date'] = '01-12-2026';
            (row['date']['gregorian'] as Map)['month'] = {'number': 12};
            return http.Response(
              jsonEncode({
                'code': 200,
                'data': [row],
              }),
              200,
            );
          }
          return http.Response(fixture, 200);
        }),
        now: () => DateTime.utc(2026, 11, 30, 18),
      );
      final schedule = await repo.load(
        const PrayerLocation(
          latitude: 41.01,
          longitude: 28.98,
          label: 'İstanbul',
        ),
      );
      expect(schedule.nextPrayer(DateTime.utc(2026, 11, 30, 18))!.at.month, 12);
      expect(calls, 2);
    },
  );
}
