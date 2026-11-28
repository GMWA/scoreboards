import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/core/providers.dart';
import 'package:scoreboards/core/settings/locale_controller.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/harness.dart';

void main() {
  group('resolveDeviceLocale', () {
    test('uses the first supported phone language', () {
      expect(
        resolveDeviceLocale(const [Locale('de'), Locale('en', 'GB')]),
        const Locale('en'),
      );
      expect(
          resolveDeviceLocale(const [Locale('fr', 'CM')]), const Locale('fr'));
    });

    test('falls back to French', () {
      expect(resolveDeviceLocale(const [Locale('de')]), const Locale('fr'));
      expect(resolveDeviceLocale(null), const Locale('fr'));
    });
  });

  group('LocaleController', () {
    test('follows the phone until a language is chosen', () async {
      final container = await testContainer(api: routes({}));
      expect(container.read(localeControllerProvider), isNull);
    });

    test('restores the saved language', () async {
      final container =
          await testContainer(api: routes({}), prefs: {'locale': 'en'});
      expect(container.read(localeControllerProvider), const Locale('en'));
    });

    test('saves the choice and can go back to the phone language', () async {
      final container = await testContainer(api: routes({}));
      final controller = container.read(localeControllerProvider.notifier);

      await controller.set(const Locale('fr'));
      expect(container.read(localeControllerProvider), const Locale('fr'));
      expect(
          container.read(sharedPreferencesProvider).getString('locale'), 'fr');

      await controller.set(null);
      expect(container.read(localeControllerProvider), isNull);
      expect(
          container.read(sharedPreferencesProvider).getString('locale'), isNull);
    });
  });
}
