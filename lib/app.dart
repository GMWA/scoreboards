import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:scoreboards/core/l10n.dart';
import 'package:scoreboards/core/router.dart';
import 'package:scoreboards/core/settings/locale_controller.dart';
import 'package:scoreboards/core/theme.dart';

class ScoreboardsApp extends ConsumerWidget {
  const ScoreboardsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Scoreboards',
      theme: buildTheme(),
      routerConfig: ref.watch(routerProvider),
      locale: ref.watch(localeControllerProvider),
      supportedLocales: supportedLocales,
      localeListResolutionCallback: (locales, _) =>
          resolveDeviceLocale(locales),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Dates (match days, article dates) follow the app's language.
      builder: (context, child) {
        Intl.defaultLocale = Localizations.localeOf(context).languageCode;
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
