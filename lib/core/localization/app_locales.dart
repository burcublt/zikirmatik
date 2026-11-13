import 'package:flutter/widgets.dart';

abstract final class AppLocales {
  static const defaultLocale = Locale('tr');
  static const turkish = Locale('tr');
  static const english = Locale('en');
  static const arabic = Locale('ar');

  static const supported = [turkish, english, arabic];

  static Locale fromLanguageCode(String? value) {
    return switch (value) {
      'en' => english,
      'ar' => arabic,
      _ => defaultLocale,
    };
  }
}
