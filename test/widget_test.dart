import 'support/test_prayer.dart';
import 'support/test_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/core/localization/app_locales.dart';
import 'package:zikirmatik/core/localization/locale_preference_repository.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/domain/home_state.dart';

void main() {
  testWidgets('uygulama başlangıç yolunu koyu temada açar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prayerNotifierProvider.overrideWith(TestPrayerNotifier.new),
          settingsNotifierProvider.overrideWith(TestSettingsNotifier.new),
          localePreferenceRepositoryProvider.overrideWithValue(
            _TurkishLocalePreferenceRepository(),
          ),
          homeNotifierProvider.overrideWith(() => _StubHomeNotifier()),
        ],
        child: const ZikirmatikApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zikirmatik'), findsOneWidget);
  });
}

class _StubHomeNotifier extends HomeNotifier {
  @override
  Future<HomeState> build() async => const HomeState(isLoading: false);
}

class _TurkishLocalePreferenceRepository implements LocalePreferenceRepository {
  @override
  Future<String?> readLocaleCode() async => AppLocales.turkish.languageCode;

  @override
  Future<void> writeLocaleCode(String localeCode) async {}
}
