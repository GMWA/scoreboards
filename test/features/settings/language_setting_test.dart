import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/core/providers.dart';
import 'package:scoreboards/core/settings/locale_controller.dart';
import 'package:scoreboards/features/settings/settings_screen.dart';
import 'package:scoreboards/l10n/app_localizations.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/harness.dart';

/// Settings inside an app that, like the real one, follows the chosen
/// language and otherwise the phone's (English in tests).
Future<ProviderContainer> pumpSettings(WidgetTester tester,
    {Map<String, Object> prefs = const {}}) async {
  final container = ProviderContainer(
    overrides: await testOverrides(api: routes({}), prefs: prefs),
    retry: (_, __) => null,
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: Consumer(
      builder: (context, ref, _) => MaterialApp(
        locale: ref.watch(localeControllerProvider),
        supportedLocales: supportedLocales,
        localeListResolutionCallback: (locales, _) =>
            resolveDeviceLocale(locales),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const SettingsScreen(),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('follows the phone language at first', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Phone language'), findsOneWidget);
  });

  testWidgets('choosing French switches the app and is remembered',
      (tester) async {
    final container = await pumpSettings(tester);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    expect(find.text('Langue'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
    expect(find.text('Équipes favorites'), findsOneWidget);
    expect(
        container.read(sharedPreferencesProvider).getString('locale'), 'fr');
  });

  testWidgets('a saved choice is used, and the phone language can come back',
      (tester) async {
    await pumpSettings(tester, prefs: {'locale': 'fr'});
    expect(find.text('Langue'), findsOneWidget);

    await tester.tap(find.text('Langue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Langue du téléphone'));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Phone language'), findsOneWidget);
  });
}
