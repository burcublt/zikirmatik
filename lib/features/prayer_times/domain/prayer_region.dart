import 'dart:convert';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

String normalizeRegionName(String value) => value
    .toUpperCase()
    .replaceAll('İ', 'I')
    .replaceAll('Ş', 'S')
    .replaceAll('Ğ', 'G')
    .replaceAll('Ü', 'U')
    .replaceAll('Ö', 'O')
    .replaceAll('Ç', 'C')
    .replaceAll(RegExp(r'[^A-Z0-9]'), '');

class PrayerRegion {
  const PrayerRegion({
    required this.id,
    required this.name,
    required this.province,
    required this.countryCode,
    required this.timeZone,
  });
  final String id, name, province, countryCode, timeZone;
  String get label => '$province / $name';
  factory PrayerRegion.fromJson(Map<String, dynamic> m) => PrayerRegion(
    id: m['id'] as String,
    name: m['name'] as String,
    province: m['province'] as String,
    countryCode: m['country'] as String,
    timeZone: m['zone'] as String,
  );
}

class PrayerRegionCatalog {
  PrayerRegionCatalog(this.regions);
  final List<PrayerRegion> regions;
  factory PrayerRegionCatalog.decode(String raw) {
    final map = jsonDecode(raw) as Map;
    if (map['version'] != 1) {
      throw const FormatException('Unsupported region catalog');
    }
    final regions = [
      for (final r in map['regions'] as List)
        PrayerRegion.fromJson(Map<String, dynamic>.from(r as Map)),
    ];
    if (regions.map((r) => r.id).toSet().length != regions.length) {
      throw const FormatException('Duplicate regions');
    }
    return PrayerRegionCatalog(regions);
  }
  PrayerRegion? byId(String id) => regions.where((r) => r.id == id).firstOrNull;
  PrayerRegion? match(PrayerLocation location) {
    if (location.annualRegionId != null) return byId(location.annualRegionId!);
    final found = regions
        .where(
          (r) =>
              r.countryCode == location.countryCode &&
              normalizeRegionName(r.province) ==
                  normalizeRegionName(location.region ?? '') &&
              normalizeRegionName(r.name) ==
                  normalizeRegionName(location.district ?? location.label),
        )
        .toList();
    return found.length == 1 ? found.single : null;
  }
}

class PrayerRegionSelectionRequired implements Exception {
  const PrayerRegionSelectionRequired();
}

class PrayerCalendarUnavailable implements Exception {
  const PrayerCalendarUnavailable();
}
