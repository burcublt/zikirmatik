import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

enum PrayerLocationIssue {
  permissionNeeded,
  denied,
  deniedForever,
  servicesDisabled,
  unavailable,
}

class PrayerLocationException implements Exception {
  const PrayerLocationException(this.issue);
  final PrayerLocationIssue issue;
}

abstract interface class PrayerLocationService {
  Future<PrayerLocation> current({required bool requestPermission});
  Future<PrayerLocation> findCity(String city);
}

class DevicePrayerLocationService implements PrayerLocationService {
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  double _rounded(double value) => double.parse(value.toStringAsFixed(2));
  @override
  Future<PrayerLocation> current({required bool requestPermission}) async {
    if (!supported) {
      throw const PrayerLocationException(PrayerLocationIssue.unavailable);
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const PrayerLocationException(PrayerLocationIssue.servicesDisabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermission) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const PrayerLocationException(PrayerLocationIssue.deniedForever);
    }
    if (permission == LocationPermission.denied) {
      throw PrayerLocationException(
        requestPermission
            ? PrayerLocationIssue.denied
            : PrayerLocationIssue.permissionNeeded,
      );
    }
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw const PrayerLocationException(PrayerLocationIssue.unavailable);
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 20),
      ),
    );
    final lat = _rounded(position.latitude), lon = _rounded(position.longitude);
    var label = '';
    String? countryCode, region, district;
    try {
      final places = await Geocoding()
          .placemarkFromCoordinates(lat, lon)
          .timeout(const Duration(seconds: 5));
      final place = places.firstOrNull;
      if (place != null) {
        countryCode = place.isoCountryCode;
        region = place.administrativeArea;
        district = place.subAdministrativeArea?.isNotEmpty == true
            ? place.subAdministrativeArea
            : place.locality;
        label =
            [
              place.locality,
              place.administrativeArea,
              place.country,
            ].whereType<String>().where((s) => s.isNotEmpty).firstOrNull ??
            '';
      }
    } catch (_) {}
    return PrayerLocation(
      latitude: lat,
      longitude: lon,
      label: label,
      countryCode: countryCode,
      region: region,
      district: district,
    );
  }

  @override
  Future<PrayerLocation> findCity(String city) async {
    if (!supported || city.trim().isEmpty) {
      throw const PrayerLocationException(PrayerLocationIssue.unavailable);
    }
    final result = await Geocoding()
        .locationFromAddress(city.trim())
        .timeout(const Duration(seconds: 12));
    if (result.isEmpty) {
      throw const PrayerLocationException(PrayerLocationIssue.unavailable);
    }
    final marks = await Geocoding()
        .placemarkFromCoordinates(result.first.latitude, result.first.longitude)
        .timeout(const Duration(seconds: 5));
    final place = marks.firstOrNull;
    return PrayerLocation(
      countryCode: place?.isoCountryCode,
      region: place?.administrativeArea,
      district: place?.subAdministrativeArea,
      latitude: _rounded(result.first.latitude),
      longitude: _rounded(result.first.longitude),
      label: city.trim(),
      manual: true,
    );
  }
}
