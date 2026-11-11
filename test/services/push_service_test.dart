import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/services/device_service.dart';
import 'package:scoreboards/services/push_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMessaging implements PushMessaging {
  bool grant = true;
  bool permission = false;
  String? token = 'token-1';
  int permissionRequests = 0;
  final refreshes = StreamController<String>.broadcast();

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    permission = grant;
    return grant;
  }

  @override
  Future<bool> hasPermission() async => permission;

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => refreshes.stream;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final push = PushService.instance;
  late FakeMessaging messaging;
  // The push_token of every PATCH the backend received.
  late List<String?> sentTokens;
  late bool backendUp;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    urls['DEVICES']!['DETAIL'] = 'https://fake.dev/devices/#deviceId/';
  });

  setUp(() async {
    await push.resetForTesting();
    DeviceService().resetCache();
    messaging = FakeMessaging();
    sentTokens = [];
    backendUp = true;
    DeviceService.internalHttpClient = MockClient((request) async {
      if (!backendUp) return Response('down', 503);
      expect(request.method, 'PATCH');
      expect(request.url.toString(), 'https://fake.dev/devices/device-1/');
      sentTokens.add(jsonDecode(request.body)['push_token']);
      return Response('{}', 200);
    });
  });

  /// Starts the service the way a launch does, and lets its startup sync
  /// finish.
  Future<void> launch(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues({'device_id': 'device-1', ...prefs});
    await push.attach(messaging);
    await push.syncToken();
  }

  group('PushService', () {
    test('is unavailable until Firebase is set up', () async {
      expect(push.isAvailable, isFalse);
      expect(await push.setEnabled(true), isFalse);
      expect(await push.isEnabled(), isFalse);
    });

    test('turning notifications on sends the token', () async {
      await launch({});

      expect(await push.setEnabled(true), isTrue);
      await push.syncToken();

      expect(sentTokens, ['token-1']);
      expect(await push.isEnabled(), isTrue);
    });

    test('refused permission keeps notifications off', () async {
      messaging.grant = false;
      await launch({});

      expect(await push.setEnabled(true), isFalse);
      await push.syncToken();

      expect(sentTokens, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PushService.enabledKey), isFalse);
    });

    test('turning notifications off clears the token on the backend',
        () async {
      messaging.permission = true;
      await launch({PushService.enabledKey: true});
      expect(sentTokens, ['token-1']);

      await push.setEnabled(false);
      await push.syncToken();

      expect(sentTokens, ['token-1', null]);
      expect(await push.isEnabled(), isFalse);
    });

    test('a new token is sent while notifications are on', () async {
      messaging.permission = true;
      await launch({PushService.enabledKey: true});

      messaging.token = 'token-2';
      messaging.refreshes.add('token-2');
      await Future<void>.delayed(Duration.zero);
      await push.syncToken();

      expect(sentTokens, ['token-1', 'token-2']);
    });

    test('a new token is not sent while notifications are off', () async {
      await launch({PushService.enabledKey: false});

      messaging.refreshes.add('token-2');
      await Future<void>.delayed(Duration.zero);
      await push.syncToken();

      expect(sentTokens, isEmpty);
    });

    test('nothing is sent when the backend already has the token', () async {
      messaging.permission = true;
      await launch({
        PushService.enabledKey: true,
        'push_token_sent': 'token-1',
      });

      expect(sentTokens, isEmpty);
    });

    test('a change made offline is sent at the next launch', () async {
      messaging.permission = true;
      backendUp = false;
      await launch({});
      await push.setEnabled(true);
      await push.syncToken();
      expect(sentTokens, isEmpty);

      // Next launch, back online; prefs survive.
      backendUp = true;
      await push.resetForTesting();
      await push.attach(messaging);
      await push.syncToken();

      expect(sentTokens, ['token-1']);
    });

    test('turning off offline is retried at the next launch', () async {
      messaging.permission = true;
      await launch({PushService.enabledKey: true});
      backendUp = false;
      await push.setEnabled(false);
      await push.syncToken();
      expect(sentTokens, ['token-1']);

      backendUp = true;
      await push.resetForTesting();
      await push.attach(messaging);
      await push.syncToken();

      expect(sentTokens, ['token-1', null]);
    });

    test('blocking notifications in the phone settings shows them off',
        () async {
      messaging.permission = true;
      await launch({PushService.enabledKey: true});

      messaging.permission = false;

      expect(await push.isEnabled(), isFalse);
    });
  });

  group('offerAfterFollow', () {
    test('asks once, when the user was never asked', () async {
      await launch({});

      expect(await push.offerAfterFollow(), isTrue);
      expect(await push.offerAfterFollow(), isFalse);
      expect(messaging.permissionRequests, 1);
    });

    test('does not ask after the user turned notifications off', () async {
      await launch({PushService.enabledKey: false});

      expect(await push.offerAfterFollow(), isFalse);
      expect(messaging.permissionRequests, 0);
    });

    test('a refusal is remembered', () async {
      messaging.grant = false;
      await launch({});

      expect(await push.offerAfterFollow(), isFalse);
      expect(await push.offerAfterFollow(), isFalse);
      expect(messaging.permissionRequests, 1);
    });
  });

  group('routeForPushData', () {
    test('opens the match', () {
      expect(
        routeForPushData({'type': 'goal', 'match_id': '7', 'match_slug': 'a-vs-b'}),
        '/matchs/details/a-vs-b',
      );
    });

    test('stays put without a match slug', () {
      expect(routeForPushData({'type': 'test'}), isNull);
      expect(routeForPushData({'type': 'goal', 'match_slug': ''}), isNull);
    });
  });
}
