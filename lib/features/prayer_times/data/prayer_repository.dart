import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

abstract interface class PrayerRepository {
  Future<PrayerSchedule?> readCache();
  Future<PrayerSchedule> load(
    PrayerLocation location, {
    PrayerSchedule? cached,
    bool force = false,
  });
}

class AlAdhanPrayerRepository implements PrayerRepository {
  AlAdhanPrayerRepository(this._db, this._http, {DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final AppDatabase _db;
  final http.Client _http;
  final DateTime Function() _now;
  @override
  Future<PrayerSchedule?> readCache() async {
    final row = await (_db.select(
      _db.userPreferences,
    )..where((r) => r.id.equals(5))).getSingleOrNull();
    if (row == null) return null;
    try {
      return PrayerSchedule.fromJson(
        Map<String, dynamic>.from(jsonDecode(row.localeCode) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PrayerSchedule> load(
    PrayerLocation location, {
    PrayerSchedule? cached,
    bool force = false,
  }) async {
    final now = _now();
    if (!force &&
        cached != null &&
        location.sameArea(cached.location) &&
        location.countryCode == cached.location.countryCode &&
        cached.covers(now)) {
      final reused = PrayerSchedule(
        location: location,
        timeZone: cached.timeZone,
        days: cached.days,
      );
      await _save(reused, now);
      return reused;
    }
    var month = DateTime(now.year, now.month);
    var raw = await _calendar(location, month);
    ensurePrayerTimeZones();
    final zone = tz.getLocation(
      ((raw.first['meta'] as Map)['timezone']) as String,
    );
    final local = tz.TZDateTime.from(now, zone);
    if (month.year != local.year || month.month != local.month) {
      month = DateTime(local.year, local.month);
      raw = await _calendar(location, month);
    }
    final days = raw.map((row) => parsePrayerDay(row, zone)).toList();
    if (local.day == DateTime(local.year, local.month + 1, 0).day) {
      final next = await _calendar(
        location,
        DateTime(local.year, local.month + 1),
      );
      days.addAll(next.map((row) => parsePrayerDay(row, zone)));
    }
    final schedule = PrayerSchedule(
      location: location,
      timeZone: zone.name,
      days: days,
    );
    if (!schedule.covers(now)) {
      throw const FormatException(
        'Prayer calendar does not cover current date',
      );
    }
    await _save(schedule, now);
    return schedule;
  }

  Future<void> _save(PrayerSchedule schedule, DateTime now) async {
    await _db
        .into(_db.userPreferences)
        .insertOnConflictUpdate(
          UserPreferencesCompanion.insert(
            id: const Value(5),
            localeCode: jsonEncode(schedule.toJson()),
            updatedAt: now,
          ),
        );
  }

  Future<List<Map<String, dynamic>>> _calendar(
    PrayerLocation location,
    DateTime month,
  ) async {
    final uri = Uri.https(
      'api.aladhan.com',
      '/v1/calendar/${month.year}/${month.month}',
      {
        'latitude': location.latitude.toStringAsFixed(2),
        'longitude': location.longitude.toStringAsFixed(2),
        'method': switch (location.countryCode) {
          'SA' => '4',
          'SG' => '11',
          'MY' => '17',
          'EG' => '5',
          'ID' => '20',
          'PK' => '1',
          'US' || 'CA' => '2',
          null => '13',
          _ => '3',
        },
      },
    );
    final response = await _http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw const FormatException('Prayer service unavailable');
    }
    final payload = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    if (payload['code'] != 200 ||
        payload['data'] is! List ||
        (payload['data'] as List).isEmpty) {
      throw const FormatException('Invalid prayer calendar');
    }
    return (payload['data'] as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }
}
