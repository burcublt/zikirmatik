import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
export 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';

class TestPrayerNotifier extends PrayerNotifier {
  @override
  Future<PrayerState> build() async => const PrayerState();
  @override
  Future<void> refresh({bool requestPermission = false}) async {}
}
