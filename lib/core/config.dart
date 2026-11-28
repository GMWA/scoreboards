import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Release builds talk to production; debug and profile builds use the
/// developer's local .env (typically staging).
const String envFile = kReleaseMode ? '.env.production' : '.env';

/// Runtime configuration, read from the .env file loaded in `main()`.
class AppConfig {
  const AppConfig._();

  /// Base URL of the backend API, without a trailing slash; every
  /// repository's paths are relative to it.
  static String get apiBaseUrl => dotenv.get('API_BASE_URL', fallback: '');

  /// The public website, for shared links and pages the app doesn't have.
  static String get websiteUrl =>
      dotenv.get('WEBSITE_URL', fallback: 'https://scoreboards.cm');

  static Uri get website => Uri.parse(websiteUrl);
}
