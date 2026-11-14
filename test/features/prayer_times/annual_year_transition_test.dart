import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:http/testing.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/features/prayer_times/data/annual_prayer_repository.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

const location = PrayerLocation(
  latitude: 0,
  longitude: 0,
  label: 'İstanbul',
  countryCode: 'TR',
  annualRegionId: '9541',
  manual: true,
  coordinatesKnown: false,
);
Future<String> fixtureAsset(String path) async {
  return File(path).readAsString();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('2026 ve 2027 uygulama varlıklarına dahil edilir', () async {
    expect(
      await rootBundle.loadString('assets/prayer_times/v1/2026/9541.json'),
      await File('assets/prayer_times/v1/2026/9541.json').readAsString(),
    );
    expect(
      await rootBundle.loadString('assets/prayer_times/v1/2027/9541.json'),
      await File('test/fixtures/prayer_2027_istanbul.json').readAsString(),
    );
  });
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());
  test('31 Aralık yatsısından sonra 1 Ocak 2027 imsak vakti seçilir', () async {
    final client = MockClient(
      (r) async => throw StateError('Network forbidden'),
    );
    addTearDown(client.close);
    final now = DateTime.utc(2026, 12, 31, 20);
    final schedule = await AnnualPrayerRepository(
      db,
      client,
      fixtureAsset,
      now: () => now,
    ).load(location);
    final next = schedule.nextPrayer(now)!;
    expect(next.name, PrayerName.fajr);
    expect(next.at.year, 2027);
    expect(next.at.month, 1);
    expect(next.at.day, 1);
    expect(next.at.hour, 6);
    expect(next.at.minute, 50);
    expect(schedule.dayAt(now)!.date.year, 2026);
    expect(schedule.days.length, 730);
  });
  test(
    'taze 30 Aralık önbelleği 31 Aralıkta gelecek yıl eklenmeden yeniden kullanılmaz',
    () async {
      final client = MockClient(
        (r) async => throw StateError('Network forbidden'),
      );
      addTearDown(client.close);
      var now = DateTime.utc(2026, 12, 30, 20);
      final repo = AnnualPrayerRepository(
        db,
        client,
        fixtureAsset,
        now: () => now,
      );
      final previous = await repo.load(location);
      expect(previous.days.length, 365);
      now = DateTime.utc(2026, 12, 31, 9);
      final refreshed = await repo.load(location, cached: previous);
      expect(refreshed.days.length, 730);
      expect(refreshed.dayAt(DateTime.utc(2027, 1, 1, 10)), isNotNull);
    },
  );
  test(
    'cihaz UTC tarihinde hâlâ 2026 olsa da konumun yerel 2027 yılı okunur',
    () async {
      final client = MockClient(
        (r) async => throw StateError('Network forbidden'),
      );
      addTearDown(client.close);
      final now = DateTime.utc(2026, 12, 31, 21, 30);
      final schedule = await AnnualPrayerRepository(
        db,
        client,
        fixtureAsset,
        now: () => now,
      ).load(location);
      expect(schedule.dayAt(now)!.date.year, 2027);
      expect(schedule.days.length, 365);
      expect(schedule.nextPrayer(now)!.at.year, 2027);
      final cache = await AnnualPrayerRepository(
        db,
        client,
        fixtureAsset,
        now: () => now,
      ).readCache();
      expect(cache!.source, 'diyanet-annual');
      expect(cache.dayAt(now)!.date.year, 2027);
    },
  );
  test(
    '2027 saatleri 2026 takviminin tarihi değiştirilerek oluşturulmaz',
    () async {
      final client = MockClient(
        (r) async => throw StateError('Network forbidden'),
      );
      addTearDown(client.close);
      final old = await AnnualPrayerRepository(
        db,
        client,
        fixtureAsset,
        now: () => DateTime.utc(2026, 1, 3, 10),
      ).load(location);
      final next = await AnnualPrayerRepository(
        db,
        client,
        fixtureAsset,
        now: () => DateTime.utc(2027, 1, 3, 10),
      ).load(location);
      expect(old.dayAt(DateTime.utc(2026, 1, 3, 10))!.entries[3].at.minute, 34);
      expect(
        next.dayAt(DateTime.utc(2027, 1, 3, 10))!.entries[3].at.minute,
        33,
      );
      expect(
        next.dayAt(DateTime.utc(2027, 1, 3, 10))!.entries[4].at.minute,
        54,
      );
    },
  );
}
