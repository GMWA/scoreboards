import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static const _storageKey = "device_id";
  static http.Client _internalHttpClient = http.Client();
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  String? _deviceId;

  static set internalHttpClient(http.Client client) {
    _internalHttpClient = client;
  }

  @visibleForTesting
  void resetCache() {
    _deviceId = null;
  }

  Future<String> getOrRegisterDevice() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_storageKey);

    if (savedId != null) {
      _deviceId = savedId;
      return savedId;
    }

    final newId = await _registerDevice();

    await prefs.setString(_storageKey, newId);
    _deviceId = newId;

    return newId;
  }

  Future<String> _registerDevice() async {
    final response = await DeviceService._internalHttpClient.post(
      Uri.parse(urls['DEVICES']['REGISTER']),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({}),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to register device: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return json["device_id"];
  }
}
