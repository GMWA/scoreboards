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

  test('update sends the fields and never throws', () async {
    final device = await repo(offline, {'device_id': 'd1'});

    expect(await device.update({'push_token': 't'}), isFalse);
    expect(api.requests.single.path, '/devices/d1/');
  });
}
