import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Injected at build time (`--dart-define=SENTRY_DSN=...`, see
/// scripts/build_*.sh) and never committed, since the project is open
/// source. Empty in debug runs and contributors' builds, which then run
/// without Sentry.
const String _sentryDsn = String.fromEnvironment('SENTRY_DSN');

/// Set by the build scripts to `cm.scoreboards.app@<pubspec version>`, the
/// same name the debug symbols are uploaded under. Without it Sentry derives
/// the release from the build, which differs between per-ABI APKs.
const String _sentryRelease = String.fromEnvironment('SENTRY_RELEASE');

/// Runs [appRunner] with Sentry capturing uncaught Dart and Flutter errors
/// and native crashes, or just runs it when no DSN was provided.
Future<void> runWithCrashReporting(Future<void> Function() appRunner) async {
  if (_sentryDsn.isEmpty) {
    await appRunner();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.environment = kReleaseMode ? 'production' : 'development';
      if (_sentryRelease.isNotEmpty) options.release = _sentryRelease;
      // No user data (IP address, device name) and no screenshots: users
      // are anonymous, and the store privacy forms say so.
      options.sendDefaultPii = false;
      // Errors only; no performance tracing.
      options.tracesSampleRate = 0;
    },
    appRunner: appRunner,
  );
}
