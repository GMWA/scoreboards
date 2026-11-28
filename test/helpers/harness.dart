import 'package:flutter/material.dart';
import 'package:scoreboards/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scoreboards/core/providers.dart';

import 'fake_http.dart';

/// Shared preferences holding [values], as the app would load them.
Future<SharedPreferences> testPrefs([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

/// The providers every test replaces: storage and the backend.
Future<List<Override>> testOverrides({
  required FakeHandler api,
  Map<String, Object> prefs = const {},
}) async =>
    [
      sharedPreferencesProvider.overrideWithValue(await testPrefs(prefs)),
      dioProvider.overrideWithValue(fakeDio(api).dio),
    ];

/// A container wired like the app's, for testing providers.
Future<ProviderContainer> testContainer({
  required FakeHandler api,
  Map<String, Object> prefs = const {},
  List<Override> overrides = const [],
}) async {
  final container = ProviderContainer(
    overrides: [...await testOverrides(api: api, prefs: prefs), ...overrides],
    retry: (_, __) => null,
  );
  addTearDown(container.dispose);
  return container;
}

/// Shows [screen] with the backend answered by [api], and waits for it to
/// load.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required FakeHandler api,
  Map<String, Object> prefs = const {},
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [...await testOverrides(api: api, prefs: prefs), ...overrides],
    retry: (_, __) => null,
    child: MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,home: screen),
  ));
  await tester.pumpAndSettle();
}

/// [WidgetTester.pumpWidget] inside the app's providers, with nothing
/// stored and the backend answered by [api] (404s by default), for widgets
/// that read providers (a favorite star, for instance).
Future<void> pumpWithProviders(
  WidgetTester tester,
  Widget widget, {
  FakeHandler? api,
}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: await testOverrides(api: api ?? routes({})),
    retry: (_, __) => null,
    child: widget,
  ));
}
