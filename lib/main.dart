import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scoreboards/app.dart';
import 'package:scoreboards/core/config.dart';
import 'package:scoreboards/core/crash_reporting.dart';
import 'package:scoreboards/core/device/device_repository.dart';
import 'package:scoreboards/core/notifications/local_notifications.dart';
import 'package:scoreboards/core/notifications/push_service.dart';
import 'package:scoreboards/core/providers.dart';
import 'package:scoreboards/core/router.dart';
import 'package:scoreboards/features/favorites/favorites_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fonts ship in google_fonts/: fetching them from fonts.gstatic.com
  // fails on a poor connection and is reported as a fatal error.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    for (final family in ['Archivo', 'HankenGrotesk', 'SpaceGrotesk']) {
      final license = await rootBundle.loadString('google_fonts/$family-OFL.txt');
      yield LicenseEntryWithLineBreaks([family], license);
    }
  });

  // Startup runs inside crash reporting so failures here are captured too.
  await runWithCrashReporting(() async {
    await dotenv.load(fileName: envFile);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider
            .overrideWithValue(await SharedPreferences.getInstance()),
      ],
      // Failures show a Retry button instead of being retried silently.
      retry: (_, __) => null,
    );
    final router = container.read(routerProvider);
    final push = container.read(pushServiceProvider);

    await LocalNotificationService.initialize(onTap: router.push);
    // Loads the favorites, and sends them if the backend may not have them.
    container.read(favoritesProvider);
    await push.init(openRoute: router.push);

    // A tapped notification that launched the app: a push, or one the app
    // showed itself while it was open.
    final launchRoute = push.takePendingRoute() ??
        await LocalNotificationService.launchPayload();

    runApp(UncontrolledProviderScope(
      container: container,
      child: const ScoreboardsApp(),
    ));

    if (launchRoute != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => router.push(launchRoute));
    }

    // Fills in the platform for devices registered before the app sent
    // it; does nothing once the backend has it.
    unawaited(container.read(deviceRepositoryProvider).reportPlatformOnce());
  });
}
