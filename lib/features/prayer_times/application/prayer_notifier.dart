import 'package:flutter/services.dart';
import 'package:zikirmatik/features/prayer_times/data/annual_prayer_repository.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_region.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:zikirmatik/core/database/database_providers.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_location_service.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_repository.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

final prayerNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return AnnualPrayerRepository(
    ref.watch(appDatabaseProvider),
    client,
    rootBundle.loadString,
    baseUrl: const String.fromEnvironment('PRAYER_DATA_BASE_URL'),
    now: ref.watch(prayerNowProvider),
  );
});
final prayerRegionCatalogProvider = FutureProvider<PrayerRegionCatalog>(
  (ref) =>
      (ref.watch(prayerRepositoryProvider) as AnnualPrayerRepository).catalog(),
);
final prayerLocationServiceProvider = Provider<PrayerLocationService>(
  (ref) => DevicePrayerLocationService(),
);
final prayerClockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  final now = ref.watch(prayerNowProvider);
  yield now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => now());
});

enum PrayerStatus {
  ready,
  needsLocation,
  denied,
  deniedForever,
  servicesDisabled,
  unavailable,
  needsRegion,
  calendarUnavailable,
}

class PrayerState {
  const PrayerState({
    this.schedule,
    this.status = PrayerStatus.needsLocation,
    this.savedLocation = false,
  });
  final PrayerSchedule? schedule;
  final PrayerStatus status;
  final bool savedLocation;
}

final prayerNotifierProvider =
    AsyncNotifierProvider<PrayerNotifier, PrayerState>(PrayerNotifier.new);

class PrayerNotifier extends AsyncNotifier<PrayerState> {
  bool _busy = false;
  DateTime? _lastCoverageAttempt;
  @override
  Future<PrayerState> build() async {
    _busy = true;
    try {
      return await _automatic(requestPermission: false);
    } finally {
      _busy = false;
    }
  }

  Future<PrayerState> _automatic({
    required bool requestPermission,
    bool force = false,
  }) async {
    final repo = ref.read(prayerRepositoryProvider);
    PrayerSchedule? cache;
    try {
      cache = await repo.readCache();
    } catch (_) {}
    try {
      // A manual city is an explicit preference; GPS does not replace it at startup.
      final location = !requestPermission && cache?.location.manual == true
          ? cache!.location
          : await ref
                .read(prayerLocationServiceProvider)
                .current(requestPermission: requestPermission);
      final schedule = await repo.load(location, cached: cache, force: force);
      return PrayerState(schedule: schedule, status: PrayerStatus.ready);
    } catch (error) {
      if (error is PrayerRegionSelectionRequired) {
        return const PrayerState(status: PrayerStatus.needsRegion);
      }
      if (error is PrayerCalendarUnavailable) {
        return const PrayerState(status: PrayerStatus.calendarUnavailable);
      }
      if (cache != null && cache.covers(ref.read(prayerNowProvider)())) {
        return PrayerState(
          schedule: cache,
          status: PrayerStatus.ready,
          savedLocation: true,
        );
      }
      final status = error is PrayerLocationException
          ? switch (error.issue) {
              PrayerLocationIssue.permissionNeeded =>
                PrayerStatus.needsLocation,
              PrayerLocationIssue.denied => PrayerStatus.denied,
              PrayerLocationIssue.deniedForever => PrayerStatus.deniedForever,
              PrayerLocationIssue.servicesDisabled =>
                PrayerStatus.servicesDisabled,
              PrayerLocationIssue.unavailable => PrayerStatus.unavailable,
            }
          : PrayerStatus.unavailable;
      return PrayerState(status: status);
    }
  }

  Future<void> refresh({
    bool requestPermission = false,
    bool force = false,
  }) async {
    if (_busy) return;
    _busy = true;
    state = const AsyncLoading();
    try {
      final result = await _automatic(
        requestPermission: requestPermission,
        force: force,
      );
      if (ref.mounted) state = AsyncData(result);
    } finally {
      _busy = false;
    }
  }

  Future<bool> setCity(String city) async {
    if (_busy) return false;
    _busy = true;
    final previous = state.asData?.value;
    state = const AsyncLoading();
    try {
      final location = await ref
          .read(prayerLocationServiceProvider)
          .findCity(city);
      final cached = await ref.read(prayerRepositoryProvider).readCache();
      final schedule = await ref
          .read(prayerRepositoryProvider)
          .load(location, cached: cached);
      if (ref.mounted) {
        state = AsyncData(
          PrayerState(schedule: schedule, status: PrayerStatus.ready),
        );
      }
      return true;
    } catch (_) {
      if (ref.mounted) {
        state = AsyncData(
          previous ?? const PrayerState(status: PrayerStatus.unavailable),
        );
      }
      return false;
    } finally {
      _busy = false;
    }
  }

  Future<bool> setRegion(PrayerRegion region) async {
    if (_busy) return false;
    _busy = true;
    final previous = state.asData?.value;
    state = const AsyncLoading();
    try {
      // A timetable selection does not fabricate coordinates or depend on geocoding.
      final location = PrayerLocation(
        latitude: 0,
        longitude: 0,
        coordinatesKnown: false,
        label: region.label,
        manual: true,
        countryCode: region.countryCode,
        region: region.province,
        district: region.name,
        annualRegionId: region.id,
      );
      final repo = ref.read(prayerRepositoryProvider);
      final schedule = await repo.load(
        location,
        cached: await repo.readCache(),
      );
      if (ref.mounted) {
        state = AsyncData(
          PrayerState(schedule: schedule, status: PrayerStatus.ready),
        );
      }
      return true;
    } catch (_) {
      if (ref.mounted) {
        state = AsyncData(
          previous?.schedule != null
              ? previous!
              : const PrayerState(status: PrayerStatus.calendarUnavailable),
        );
      }
      return false;
    } finally {
      _busy = false;
    }
  }

  Future<void> ensureCoverage(DateTime now) async {
    final schedule = state.asData?.value.schedule;
    if (schedule == null || schedule.covers(now) || _busy) return;
    if (_lastCoverageAttempt != null &&
        now.difference(_lastCoverageAttempt!) < const Duration(minutes: 5)) {
      return;
    }
    _lastCoverageAttempt = now;
    await refresh();
  }
}
