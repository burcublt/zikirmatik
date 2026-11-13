import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

bool _zonesReady = false;
void ensurePrayerTimeZones() {
  if (!_zonesReady) {
    data.initializeTimeZones();
    _zonesReady = true;
  }
}

enum PrayerName { fajr, sunrise, dhuhr, asr, maghrib, isha }

class PrayerLocation {
  const PrayerLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
    this.manual = false,
    this.countryCode,
    this.region,
    this.district,
    this.annualRegionId,
    this.coordinatesKnown = true,
  });
  final double latitude, longitude;
  final String label;
  final bool manual;
  final String? countryCode, region, district, annualRegionId;
  final bool coordinatesKnown;
  Map<String, dynamic> toJson() => {
    'lat': latitude,
    'lon': longitude,
    'label': label,
    'manual': manual,
    'country': countryCode,
    'region': region,
    'district': district,
    'annualRegionId': annualRegionId,
    'coordinatesKnown': coordinatesKnown,
  };
  factory PrayerLocation.fromJson(Map<String, dynamic> map) => PrayerLocation(
    latitude: (map['lat'] as num).toDouble(),
    longitude: (map['lon'] as num).toDouble(),
    label: map['label'] as String,
    manual: map['manual'] == true,
    countryCode: map['country'] as String?,
    region: map['region'] as String?,
    district: map['district'] as String?,
    annualRegionId: map['annualRegionId'] as String?,
    coordinatesKnown: map['coordinatesKnown'] != false,
  );
  bool sameArea(PrayerLocation other) =>
      (latitude - other.latitude).abs() < 0.01 &&
      (longitude - other.longitude).abs() < 0.01;
}

class PrayerEntry {
  const PrayerEntry(this.name, this.at);
  final PrayerName name;
  final DateTime at;
  bool get isPrayer => name != PrayerName.sunrise;
}

class PrayerDay {
  const PrayerDay({required this.date, required this.entries});
  final DateTime date;
  final List<PrayerEntry> entries;
}

class PrayerSchedule {
  const PrayerSchedule({
    required this.location,
    required this.timeZone,
    required this.days,
    this.source = 'aladhan',
    this.fetchedAt,
  });
  final PrayerLocation location;
  final String timeZone;
  final List<PrayerDay> days;
  final String source;
  final DateTime? fetchedAt;
  tz.Location get zone {
    ensurePrayerTimeZones();
    return tz.getLocation(timeZone);
  }

  tz.TZDateTime localNow(DateTime now) => tz.TZDateTime.from(now, zone);
  PrayerDay? dayAt(DateTime now) {
    final local = localNow(now);
    return days
        .where(
          (d) =>
              d.date.year == local.year &&
              d.date.month == local.month &&
              d.date.day == local.day,
        )
        .firstOrNull;
  }

  PrayerEntry? nextPrayer(DateTime now) {
    final upcoming =
        days
            .expand((d) => d.entries)
            .where((e) => e.isPrayer && e.at.isAfter(now))
            .toList()
          ..sort((a, b) => a.at.compareTo(b.at));
    return upcoming.firstOrNull;
  }

  bool covers(DateTime now) => dayAt(now) != null && nextPrayer(now) != null;
  Map<String, dynamic> toJson() => {
    'version': 1,
    'source': source,
    'fetchedAt': fetchedAt?.toUtc().toIso8601String(),
    'location': location.toJson(),
    'zone': timeZone,
    'days': [
      for (final d in days)
        {
          'date': '${d.date.year}-${d.date.month}-${d.date.day}',
          'times': {
            for (final e in d.entries)
              e.name.name: e.at.toUtc().toIso8601String(),
          },
        },
    ],
  };
  factory PrayerSchedule.fromJson(Map<String, dynamic> map) {
    ensurePrayerTimeZones();
    if (map['version'] != 1) {
      throw const FormatException('Unsupported prayer cache');
    }
    final zone = tz.getLocation(map['zone'] as String);
    return PrayerSchedule(
      location: PrayerLocation.fromJson(
        Map<String, dynamic>.from(map['location'] as Map),
      ),
      timeZone: zone.name,
      source: map['source'] as String? ?? 'aladhan',
      fetchedAt: DateTime.tryParse(map['fetchedAt'] as String? ?? ''),
      days: [
        for (final raw in map['days'] as List)
          _cachedDay(Map<String, dynamic>.from(raw as Map), zone),
      ],
    );
  }
  static PrayerDay _cachedDay(Map<String, dynamic> map, tz.Location zone) {
    final parts = (map['date'] as String).split('-').map(int.parse).toList();
    final times = map['times'] as Map;
    return PrayerDay(
      date: tz.TZDateTime(zone, parts[0], parts[1], parts[2]),
      entries: [
        for (final name in PrayerName.values)
          PrayerEntry(
            name,
            tz.TZDateTime.from(
              DateTime.parse(times[name.name] as String),
              zone,
            ),
          ),
      ],
    );
  }
}

PrayerDay parsePrayerDay(Map<String, dynamic> raw, tz.Location zone) {
  final date = (raw['date'] as Map)['gregorian'] as Map;
  final year = int.parse(date['year'].toString()),
      month = int.parse((date['month'] as Map)['number'].toString()),
      day = int.parse(date['day'].toString());
  final timings = raw['timings'] as Map;
  const keys = {
    PrayerName.fajr: 'Fajr',
    PrayerName.sunrise: 'Sunrise',
    PrayerName.dhuhr: 'Dhuhr',
    PrayerName.asr: 'Asr',
    PrayerName.maghrib: 'Maghrib',
    PrayerName.isha: 'Isha',
  };
  return PrayerDay(
    date: tz.TZDateTime(zone, year, month, day),
    entries: [
      for (final name in PrayerName.values)
        PrayerEntry(
          name,
          _time(timings[keys[name]].toString(), zone, year, month, day),
        ),
    ],
  );
}

DateTime _time(String value, tz.Location zone, int year, int month, int day) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})(?:\s|$)').firstMatch(value);
  if (match == null) throw const FormatException('Invalid prayer time');
  final hour = int.parse(match.group(1)!), minute = int.parse(match.group(2)!);
  if (hour > 23 || minute > 59) {
    throw const FormatException('Invalid prayer time');
  }
  return tz.TZDateTime(zone, year, month, day, hour, minute);
}

String prayerCountdown(Duration remaining) {
  final seconds = remaining.inSeconds.clamp(0, 864000);
  return '${(seconds ~/ 3600).toString().padLeft(2, '0')}:${(seconds ~/ 60 % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}
