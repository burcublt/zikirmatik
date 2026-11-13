import 'package:flutter/material.dart';
import 'package:zikirmatik/features/settings/application/settings_notifier.dart';
import 'package:zikirmatik/core/ads/admob.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/app/router.dart';
import 'package:zikirmatik/app/theme/app_theme.dart';
import 'package:zikirmatik/core/localization/app_locales.dart';
import 'package:zikirmatik/core/localization/locale_controller.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';

class ZikirmatikApp extends ConsumerWidget {
  const ZikirmatikApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(adsControllerProvider);
    final router = ref.watch(appRouterProvider);
    final locale =
        ref.watch(localeControllerProvider).asData?.value ??
        AppLocales.defaultLocale;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode:
          ref.watch(settingsNotifierProvider).asData?.value.themeMode ??
          ThemeMode.dark,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
