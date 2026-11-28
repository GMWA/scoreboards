import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/core/providers.dart';

/// The app's languages; the first is the fallback.
const supportedLocales = [Locale('fr'), Locale('en')];

/// Picks the first phone language the app supports, French otherwise.
Locale resolveDeviceLocale(List<Locale>? deviceLocales) {
  for (final locale in deviceLocales ?? const <Locale>[]) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) return supported;
    }
  }
  return supportedLocales.first;
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

/// The language chosen in Settings; `null` follows the phone.
class LocaleController extends Notifier<Locale?> {
  static const _key = 'locale';

  @override
  Locale? build() {
    final code = ref.watch(sharedPreferencesProvider).getString(_key);
    return code == null ? null : Locale(code);
  }

  Future<void> set(Locale? locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
    state = locale;
  }
}
