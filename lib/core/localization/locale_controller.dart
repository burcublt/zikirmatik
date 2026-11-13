import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/core/localization/app_locales.dart';
import 'package:zikirmatik/core/localization/locale_preference_repository.dart';

final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, Locale>(LocaleController.new);

class LocaleController extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    final localeCode = await ref
        .read(localePreferenceRepositoryProvider)
        .readLocaleCode();
    return AppLocales.fromLanguageCode(localeCode);
  }

  Future<void> select(Locale locale) async {
    final previousLocale = state.asData?.value ?? AppLocales.defaultLocale;
    state = AsyncData(locale);

    try {
      await ref
          .read(localePreferenceRepositoryProvider)
          .writeLocaleCode(locale.languageCode);
    } on Object {
      state = AsyncData(previousLocale);
      rethrow;
    }
  }
}
