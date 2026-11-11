import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The platform name the backend stores for this device, or null on a
/// platform it doesn't track.
String? get devicePlatform {
  if (kIsWeb) return 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => null,
  };
}

class DeviceService {
  static const _storageKey = "device_id";
  // Set once the backend has this device's platform.
  static const _platformReportedKey = "device_platform_reported";
  static http.Client _internalHttpClient = http.Client();
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  String? _deviceId;
  Future<String>? _pending;

  static set internalHttpClient(http.Client client) {
    _internalHttpClient = client;
  }

  static http.Client get httpClient => _internalHttpClient;

  @visibleForTesting
  void resetCache() {
    _deviceId = null;
    _pending = null;
  }

  /// Concurrent callers share one lookup/registration, so a first launch
  /// can't register two devices and orphan whatever was tied to the first.
  Future<String> getOrRegisterDevice() {
    final id = _deviceId;
    if (id != null) return Future.value(id);
    return _pending ??= _loadOrRegister().whenComplete(() => _pending = null);
  }

  /// Devices registered before the app sent its platform have none on the
  /// backend; this fills it in once. Failures are ignored and retried on
  /// the next launch. It never registers a device by itself.
  Future<void> reportPlatformOnce() async {
    final platform = devicePlatform;
    if (platform == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString(_storageKey);
      if (deviceId == null || (prefs.getBool(_platformReportedKey) ?? false)) {
        return;
      }

      final response = await _internalHttpClient.patch(
        Uri.parse((urls['DEVICES']['DETAIL'] as String)
            .replaceAll('#deviceId', deviceId)),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"platform": platform}),
      );
      if (response.statusCode == 200) {
        await prefs.setBool(_platformReportedKey, true);
      }
    } catch (e) {
      debugPrint('Could not report the device platform: $e');
    }
  }

  Future<String> _loadOrRegister() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_storageKey);

    if (savedId != null) {
      _deviceId = savedId;
      return savedId;
    }

    final newId = await _registerDevice();

    await prefs.setString(_storageKey, newId);
    // Registration already sent the platform.
    if (devicePlatform != null) await prefs.setBool(_platformReportedKey, true);
    _deviceId = newId;

    return newId;
  }

  Future<String> _registerDevice() async {
    final platform = devicePlatform;
    final response = await DeviceService._internalHttpClient.post(
      Uri.parse(urls['DEVICES']['REGISTER']),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({if (platform != null) "platform": platform}),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to register device: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return json["device_id"];
  }
}
