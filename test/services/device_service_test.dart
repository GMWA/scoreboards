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
