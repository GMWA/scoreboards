import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runs before every test file: a fixed configuration, so no test depends
/// on the developer's .env file.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  dotenv.testLoad(fileInput: '''
API_BASE_URL=https://fake.dev/api/v1
WEBSITE_URL=https://scoreboards.cm
''');
  await testMain();
}
