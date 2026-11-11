import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoreboards/services/device_service.dart';
import 'package:scoreboards/constants/urls.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });

  group("DeviceService Tests", () {
    late DeviceService service;

    setUp(() {
      service = DeviceService();
      service.resetCache(); // clear internal cached ID

      // clear SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // ensure DEVICES map exists
      urls['DEVICES'] ??= {};
      urls['DEVICES']!['DETAIL'] = "https://fake.dev/devices/#deviceId/";
    });

    test("registration sends the platform", () async {
      SharedPreferences.setMockInitialValues({});
      Map<String, dynamic>? sent;

      DeviceService.internalHttpClient = MockClient((request) async {
        sent = jsonDecode(request.body);
        return Response(jsonEncode({"device_id": "new-device"}), 201);
      });
      urls['DEVICES']!['REGISTER'] = "https://fake.dev/register";

      await service.getOrRegisterDevice();

      // flutter_test runs as Android unless told otherwise.
      expect(sent, {"platform": "android"});
      // A new device never needs the platform backfilled.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool("device_platform_reported"), isTrue);
    });

    test("reportPlatformOnce backfills the platform once", () async {
      SharedPreferences.setMockInitialValues({"device_id": "old-device"});
      final requests = <Request>[];

      DeviceService.internalHttpClient = MockClient((request) async {
        requests.add(request);
        return Response(jsonEncode({"device_id": "old-device"}), 200);
      });

      await service.reportPlatformOnce();
      await service.reportPlatformOnce();

      expect(requests, hasLength(1));
      expect(requests.single.method, "PATCH");
      expect(requests.single.url.toString(),
          "https://fake.dev/devices/old-device/");
      expect(jsonDecode(requests.single.body), {"platform": "android"});
    });

    test("reportPlatformOnce retries after a failure", () async {
      SharedPreferences.setMockInitialValues({"device_id": "old-device"});
      var attempts = 0;

      DeviceService.internalHttpClient = MockClient((request) async {
        attempts++;
        return attempts == 1 ? Response("down", 503) : Response("{}", 200);
      });

      await service.reportPlatformOnce(); // fails, must not throw
      await service.reportPlatformOnce();
      await service.reportPlatformOnce();

      expect(attempts, 2);
    });

    test("reportPlatformOnce does nothing without a registered device",
        () async {
      SharedPreferences.setMockInitialValues({});

      DeviceService.internalHttpClient = MockClient((request) async {
        throw Exception("no request expected");
      });

      await service.reportPlatformOnce();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString("device_id"), isNull);
    });

    test("returns saved device ID if stored in SharedPreferences", () async {
      SharedPreferences.setMockInitialValues({
        "device_id": "saved-device-123",
      });

      // Should not call POST, but we supply a mock anyway
      DeviceService.internalHttpClient = MockClient((request) async {
        throw Exception("POST should NOT be called");
      });

      urls['DEVICES']!['REGISTER'] = "https://fake-register.dev";

      final id = await service.getOrRegisterDevice();

      expect(id, equals("saved-device-123"));
    });

    test("registers a new device when none is saved", () async {
      SharedPreferences.setMockInitialValues({});

      final mockClient = MockClient((request) async {
        return Response(jsonEncode({"device_id": "new-device-456"}), 201);
      });

      DeviceService.internalHttpClient = mockClient;
      urls['DEVICES']!['REGISTER'] = "https://fake.dev/register";

      final id = await service.getOrRegisterDevice();

      expect(id, equals("new-device-456"));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString("device_id"), equals("new-device-456"));
    });

    test("throws exception when registration fails", () async {
      SharedPreferences.setMockInitialValues({});

      final mockClient = MockClient((request) async {
        return Response("Server error", 500);
      });

      DeviceService.internalHttpClient = mockClient;
      urls['DEVICES']!['REGISTER'] = "https://fake.dev/register";

      expect(
        () async => await service.getOrRegisterDevice(),
        throwsA(isA<Exception>()),
      );
    });

    test("concurrent first-launch calls register only one device", () async {
      SharedPreferences.setMockInitialValues({});
      var registrations = 0;

      DeviceService.internalHttpClient = MockClient((request) async {
        registrations++;
        await Future.delayed(const Duration(milliseconds: 20));
        return Response(jsonEncode({"device_id": "device-$registrations"}), 201);
      });
      urls['DEVICES']!['REGISTER'] = "https://fake.dev/register";

      final ids = await Future.wait([
        service.getOrRegisterDevice(),
        service.getOrRegisterDevice(),
        service.getOrRegisterDevice(),
      ]);

      expect(registrations, 1);
      expect(ids.toSet(), {"device-1"});
    });

    test("a failed registration can be retried", () async {
      SharedPreferences.setMockInitialValues({});
      var attempts = 0;

      DeviceService.internalHttpClient = MockClient((request) async {
        attempts++;
        return attempts == 1
            ? Response("Server error", 500)
            : Response(jsonEncode({"device_id": "device-ok"}), 201);
      });
      urls['DEVICES']!['REGISTER'] = "https://fake.dev/register";

      await expectLater(service.getOrRegisterDevice(), throwsA(isA<Exception>()));
      expect(await service.getOrRegisterDevice(), "device-ok");
    });
  });
}
