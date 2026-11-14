import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_repository.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_region.dart';

typedef PrayerAssetReader = Future<String> Function(String path);

class AnnualPrayerRepository implements PrayerRepository {
  AnnualPrayerRepository(
    this.db,
    this.client,
    this.readAsset, {
    this.baseUrl = '',
    DateTime Function()? now,
    PrayerRepository? international,
  }) : now = now ?? DateTime.now,
       international =
           international ?? AlAdhanPrayerRepository(db, client, now: now);
  final AppDatabase db;
  final http.Client client;
  final PrayerAssetReader readAsset;
  final String baseUrl;
  final DateTime Function() now;
  final PrayerRepository international;
  Future<PrayerRegionCatalog>? _catalog;
  Future<PrayerRegionCatalog> catalog() =>
      _catalog ??= readAsset('assets/prayer_times/regions.json')
          .then(PrayerRegionCatalog.decode)
          .catchError((Object e) {
            _catalog = null;
            throw e;
          });
  @override
  Future<PrayerSchedule?> readCache() async {
    final row = await (db.select(
      db.userPreferences,
    )..where((r) => r.id.equals(6))).getSingleOrNull();
    if (row != null) {
      try {
        final schedule = PrayerSchedule.fromJson(
          Map<String, dynamic>.from(jsonDecode(row.localeCode) as Map),
        );
        if ((schedule.source == 'diyanet-annual' &&
                schedule.location.annualRegionId != null) ||
            (schedule.source == 'aladhan' &&
                schedule.location.countryCode != null &&
                !{'TR', 'CY'}.contains(schedule.location.countryCode))) {
          return schedule;
        }
      } catch (_) {}
    }
    final calculated = await international.readCache();
    // Legacy method-13 calendars must never be presented as official TR calendars.
    if (calculated != null &&
        calculated.location.countryCode != null &&
        !{'TR', 'CY'}.contains(calculated.location.countryCode)) {
      return calculated;
    }
    return null;
  }

  @override
  Future<PrayerSchedule> load(
    PrayerLocation location, {
    PrayerSchedule? cached,
    bool force = false,
  }) async {
    if (location.annualRegionId == null &&
        location.countryCode != null &&
        !{'TR', 'CY'}.contains(location.countryCode)) {
      final result = await international.load(
        location,
        cached: cached?.source == 'aladhan' ? cached : null,
        force: force,
      );
      // Keep the most recently chosen location as the active cache across providers.
      await _save(result);
      return result;
    }
    final region = (await catalog()).match(location);
    if (region == null) throw const PrayerRegionSelectionRequired();
    ensurePrayerTimeZones();
    final zone = tz.getLocation(region.timeZone);
    final local = tz.TZDateTime.from(now(), zone);
    final selected = PrayerLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      label: region.label,
      manual: location.manual,
      coordinatesKnown: location.coordinatesKnown,
      countryCode: region.countryCode,
      region: region.province,
      district: region.name,
      annualRegionId: region.id,
    );
    if (!force &&
        cached?.source == 'diyanet-annual' &&
        cached!.location.annualRegionId == region.id &&
        cached.covers(now()) &&
        (!(local.month == 12 && local.day == 31) ||
            cached.dayAt(tz.TZDateTime(zone, local.year + 1, 1, 1)) != null) &&
        cached.fetchedAt != null &&
        now().difference(cached.fetchedAt!) < const Duration(hours: 24)) {
      final result = PrayerSchedule(
        location: selected,
        timeZone: cached.timeZone,
        days: cached.days,
        source: cached.source,
        fetchedAt: cached.fetchedAt,
      );
      await _save(result);
      return result;
    }
    try {
      final days = await _year(region, local.year);
      if (local.month == 12 && local.day == 31) {
        try {
          days.addAll(await _year(region, local.year + 1));
        } catch (_) {}
      }
      final result = PrayerSchedule(
        location: selected,
        timeZone: zone.name,
        days: days,
        source: 'diyanet-annual',
        fetchedAt: now(),
      );
      if (result.dayAt(now()) == null) throw const PrayerCalendarUnavailable();
      await _save(result);
      return result;
    } catch (_) {
      if (cached?.source == 'diyanet-annual' &&
          cached!.location.annualRegionId == region.id &&
          cached.dayAt(now()) != null) {
        return cached;
      }
      throw const PrayerCalendarUnavailable();
    }
  }

  Future<List<PrayerDay>> _year(PrayerRegion region, int year) async {
    final path = 'v1/$year/${region.id}.json';
    if (baseUrl.isNotEmpty) {
      final base = Uri.parse(baseUrl);
      if (base.scheme != 'https' ||
          base.host.isEmpty ||
          base.hasQuery ||
          base.hasFragment) {
        throw const FormatException('Prayer data URL must be HTTPS');
      }
      try {
        final response = await client
            .get(Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/$path'))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          return decodeAnnualPrayerCalendar(
            utf8.decode(response.bodyBytes),
            region,
            year,
          );
        }
      } catch (_) {}
    }
    return decodeAnnualPrayerCalendar(
      await readAsset('assets/prayer_times/v1/$year/${region.id}.json'),
      region,
      year,
    );
  }

  Future<void> _save(PrayerSchedule schedule) async => db
      .into(db.userPreferences)
      .insertOnConflictUpdate(
        UserPreferencesCompanion.insert(
          id: const Value(6),
          localeCode: jsonEncode(schedule.toJson()),
          updatedAt: now(),
        ),
      );
}

List<PrayerDay> decodeAnnualPrayerCalendar(
  String raw,
  PrayerRegion region,
  int year,
) {
  final m = jsonDecode(raw) as Map;
  if (m['version'] != 1 ||
      m['year'] != year ||
      m['region'] != region.id ||
      m['zone'] != region.timeZone ||
      m['source'] != 'diyanet-annual') {
    throw const FormatException('Wrong annual calendar');
  }
  ensurePrayerTimeZones();
  final zone = tz.getLocation(region.timeZone);
  final rows = m['days'] as List;
  final expected = DateTime(year + 1).difference(DateTime(year)).inDays;
  if (rows.length != expected) {
    throw const FormatException('Incomplete annual calendar');
  }
  final result = <PrayerDay>[];
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i] as List;
    final date = DateTime.utc(year, 1, 1).add(Duration(days: i));
    final iso =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    if (row.length != 7 || row[0] != iso) {
      throw const FormatException('Missing or unordered calendar date');
    }
    final entries = <PrayerEntry>[];
    for (var j = 0; j < 6; j++) {
      final text = row[j + 1];
      if (text is! String ||
          !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(text)) {
        throw const FormatException('Invalid clock time');
      }
      final parts = text.split(':').map(int.parse).toList();
      final at = tz.TZDateTime(
        zone,
        date.year,
        date.month,
        date.day,
        parts[0],
        parts[1],
      );
      if (entries.isNotEmpty && !at.isAfter(entries.last.at)) {
        throw const FormatException('Unordered prayer times');
      }
      entries.add(PrayerEntry(PrayerName.values[j], at));
    }
    result.add(
      PrayerDay(
        date: tz.TZDateTime(zone, date.year, date.month, date.day),
        entries: entries,
      ),
    );
  }
  return result;
}
