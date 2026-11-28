import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/core/device/device_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/harness.dart';

void main() {
  late SharedPreferences prefs;
  late FakeAdapter api;

  Future<DeviceRepository> repo(
    FakeHandler handler, [
    Map<String, Object> stored = const {},
  ]) async {
    prefs = await testPrefs(stored);
    final fake = fakeDio(handler);
    api = fake.api;
    return DeviceRepository(fake.dio, prefs);
  }

  ResponseBody registered(String id) => jsonBody(201, {'device_id': id});

  group('id', () {
    test('is the saved id, without asking the backend', () async {
      final device =
          await repo((_) async => registered('new'), {'device_id': 'saved'});

      expect(await device.id(), 'saved');
      expect(api.requests, isEmpty);
    });

    test('registers the device the first time, with its platform', () async {
      final device = await repo((_) async => registered('new-device'));

      expect(await device.id(), 'new-device');
      expect(prefs.getString('device_id'), 'new-device');
      // flutter_test runs as Android unless told otherwise.
      expect(api.requests.single.path, '/devices/');
      expect(sentJson(api.requests.single), {'platform': 'android'});
      // A new device never needs the platform backfilled.
      expect(prefs.getBool('device_platform_reported'), isTrue);
    });

    test('fails when registration fails, and can be retried', () async {
      var attempts = 0;
      final device = await repo((_) async =>
          ++attempts == 1 ? jsonBody(500, {}) : registered('second-try'));

      await expectLater(device.id(), throwsA(isA<ApiException>()));
      expect(prefs.getString('device_id'), isNull);

      expect(await device.id(), 'second-try');
    });

    test('concurrent first-launch calls register only one device', () async {
      final answer = Completer<ResponseBody>();
      final device = await repo((_) => answer.future);

      final first = device.id();
      final second = device.id();
      answer.complete(registered('only-one'));

      expect(await Future.wait([first, second]), ['only-one', 'only-one']);
      expect(api.requests, hasLength(1));
    });
  });

  group('reportPlatformOnce', () {
    test('backfills the platform once', () async {
      final device = await repo(
          (_) async => jsonBody(200, {}), {'device_id': 'old-device'});

      await device.reportPlatformOnce();
      await device.reportPlatformOnce();

      expect(api.requests, hasLength(1));
      expect(api.requests.single.method, 'PATCH');
      expect(api.requests.single.path, '/devices/old-device/');
      expect(sentJson(api.requests.single), {'platform': 'android'});
    });

    test('tries again after a failure', () async {
      var attempts = 0;
      final device = await repo(
        (_) async => jsonBody(++attempts == 1 ? 500 : 200, {}),
        {'device_id': 'old-device'},
      );

      await device.reportPlatformOnce();
      expect(prefs.getBool('device_platform_reported'), isNull);

      await device.reportPlatformOnce();
      expect(prefs.getBool('device_platform_reported'), isTrue);
    });

    test('does nothing without a registered device', () async {
      final device = await repo((_) async => jsonBody(200, {}));

      await device.reportPlatformOnce();

      expect(api.requests, isEmpty);
    });
  });

  group('reportLanguage', () {
    // The backend sends the device back, with its language.
    ResponseBody saved(RequestOptions o) =>
        jsonBody(200, {'language': sentJson(o)['language']});

    test('sends each new language once', () async {
      final device = await repo((o) async => saved(o), {'device_id': 'd1'});

      await device.reportLanguage('fr');
      await device.reportLanguage('fr');
      await device.reportLanguage('en');

      expect(api.requests.map((r) => [r.method, r.path, sentJson(r)]), [
        ['PATCH', '/devices/d1/', {'language': 'fr'}],
        ['PATCH', '/devices/d1/', {'language': 'en'}],
      ]);
    });

    test('concurrent calls send it once', () async {
      final device = await repo((o) async => saved(o), {'device_id': 'd1'});

      await Future.wait([
        device.reportLanguage('en'),
        device.reportLanguage('en'),
      ]);

      expect(api.requests, hasLength(1));
    });

    test('tries again after a failure', () async {
      var attempts = 0;
      final device = await repo(
        (o) async => ++attempts == 1 ? jsonBody(500, {}) : saved(o),
        {'device_id': 'd1'},
      );

      await device.reportLanguage('en');
      await device.reportLanguage('en');

      expect(api.requests, hasLength(2));
      expect(prefs.getString('device_language_reported'), 'en');
    });

    test('a backend from before languages gets it again later', () async {
      final device =
          await repo((_) async => jsonBody(200, {}), {'device_id': 'd1'});

      await device.reportLanguage('en');
      await device.reportLanguage('en');

      expect(api.requests, hasLength(2));
      expect(prefs.getString('device_language_reported'), isNull);
    });

    test('a device registered later sends it with its registration',
        () async {
      final device = await repo((o) async =>
          jsonBody(201, {'device_id': 'new-device', ...sentJson(o)}));

      await device.reportLanguage('en');
      expect(api.requests, isEmpty);

      await device.id();
      expect(sentJson(api.requests.single),
          {'platform': 'android', 'language': 'en'});

      await device.reportLanguage('en');
      expect(api.requests, hasLength(1));
    });
  });

  test('update sends the fields and never throws', () async {
    final device = await repo(offline, {'device_id': 'd1'});

    expect(await device.update({'push_token': 't'}), isFalse);
    expect(api.requests.single.path, '/devices/d1/');
  });
}
