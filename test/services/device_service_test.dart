import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoreboards/services/device_service.dart';
import 'package:scoreboards/constants/urls.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
  });
}
