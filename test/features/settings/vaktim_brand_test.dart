import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// The launcher platform interface is already provided by url_launcher.
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/link.dart';
import 'package:zikirmatik/core/ads/admob.dart';
import 'package:zikirmatik/features/settings/application/settings_notifier.dart';
import 'package:zikirmatik/features/settings/data/settings_repository.dart';
import 'package:zikirmatik/features/settings/presentation/settings_page.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';

class TestSettings extends SettingsNotifier {
  @override
  Future<AppSettings> build() async => const AppSettings();
}

class NoAds extends AdsController {
  @override
  Future<AdsState> build() async => const AdsState();
}

class TestLauncher extends UrlLauncherPlatform {
  String? opened;
  @override
  LinkDelegate? get linkDelegate => null;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    opened = url;
    return true;
  }
}

void main() {
  test('telefon simgesi adları ve üç dilde uygulama adı Vaktim', () async {
    final android = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final ios = File('ios/Runner/Info.plist').readAsStringSync();
    expect(android, contains('android:label="Vaktim"'));
    expect(
      ios,
      contains('<key>CFBundleDisplayName</key>\n\t<string>Vaktim</string>'),
    );
    for (final locale in ['tr', 'en', 'ar']) {
      expect(
        (await AppLocalizations.delegate.load(Locale(locale))).appTitle,
        'Vaktim',
      );
    }
  });
  testWidgets('gizlilik politikası satırı verilen adresi açar', (tester) async {
    final previous = UrlLauncherPlatform.instance;
    final launcher = TestLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previous);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsNotifierProvider.overrideWith(TestSettings.new),
          adsControllerProvider.overrideWith(NoAds.new),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsPage(selectedNavIndex: 4, onNavTap: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final link = find.text('Gizlilik Politikası');
    await tester.scrollUntilVisible(
      link,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(launcher.opened, 'https://burcublt.github.io/zikirmatik/');
  });
}
