import 'package:zikirmatik/features/settings/application/settings_notifier.dart';
import 'package:zikirmatik/features/settings/data/settings_repository.dart';
export 'package:zikirmatik/features/settings/application/settings_notifier.dart';

class TestSettingsNotifier extends SettingsNotifier {
  @override
  Future<AppSettings> build() async => const AppSettings();
}
