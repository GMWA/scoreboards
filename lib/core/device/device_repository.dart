import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/core/api/paging.dart';
import 'package:scoreboards/core/providers.dart';

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

/// This install's anonymous device on the backend: it identifies votes,
/// favorites and the push token, without any account.
class DeviceRepository {
  DeviceRepository(this._dio, this._prefs);

  final Dio _dio;
  final SharedPreferences _prefs;

  static const _idKey = 'device_id';
  // Set once the backend has this device's platform.
  static const _platformReportedKey = 'device_platform_reported';
  // The language the app shows, and the one the backend has: notifications
  // are written in it.
  static const _languageKey = 'device_language';
  static const _languageReportedKey = 'device_language_reported';

  Future<String>? _pending;
  String? _reportingLanguage;

  /// The device's id, registering the device the first time. Concurrent
  /// callers share one registration, so a first launch can't register two
  /// devices and orphan whatever was tied to the first.
  Future<String> id() {
    final saved = _prefs.getString(_idKey);
    if (saved != null) return Future.value(saved);
    return _pending ??= _register().whenComplete(() => _pending = null);
  }

  Future<String> _register() async {
    final platform = devicePlatform;
    final language = _prefs.getString(_languageKey);
    final body = await apiCall(() => _dio.post<Json>(
          '/devices/',
          data: {
            if (platform != null) 'platform': platform,
            if (language != null) 'language': language,
          },
        ));
    final id = body.data!['device_id'] as String;
    await _prefs.setString(_idKey, id);
    // Registration already sent the platform, and the language when the
    // backend knows about languages (it says so by sending it back).
    if (platform != null) await _prefs.setBool(_platformReportedKey, true);
    if (language != null && body.data!['language'] == language) {
      await _prefs.setString(_languageReportedKey, language);
    }
    return id;
  }

  /// Changes this device on the backend (registering it first if needed),
  /// e.g. its push token. Returns whether the backend accepted it; never
  /// throws.
  Future<bool> update(Map<String, dynamic> fields) async {
    try {
      final deviceId = await id();
      await apiCall(() => _dio.patch<void>('/devices/$deviceId/', data: fields));
      return true;
    } catch (e) {
      debugPrint('Could not update the device: $e');
      return false;
    }
  }

  /// Devices registered before the app sent its platform have none on the
  /// backend; this fills it in once. Failures are ignored and retried on
  /// the next launch. It never registers a device by itself.
  Future<void> reportPlatformOnce() async {
    final platform = devicePlatform;
    final deviceId = _prefs.getString(_idKey);
    if (platform == null ||
        deviceId == null ||
        (_prefs.getBool(_platformReportedKey) ?? false)) {
      return;
    }
    try {
      await apiCall(() => _dio
          .patch<void>('/devices/$deviceId/', data: {'platform': platform}));
      await _prefs.setBool(_platformReportedKey, true);
    } catch (e) {
      debugPrint('Could not report the device platform: $e');
    }
  }

  /// Tells the backend the app now shows [languageCode] ("fr" or "en"), so
  /// notifications come in it. Sent once per change; a device registered
  /// later sends it with its registration. Like [reportPlatformOnce], it
  /// never registers a device by itself, and a failure is retried on the
  /// next call.
  Future<void> reportLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
    final deviceId = _prefs.getString(_idKey);
    if (deviceId == null ||
        _prefs.getString(_languageReportedKey) == languageCode ||
        _reportingLanguage == languageCode) {
      return;
    }
    _reportingLanguage = languageCode;
    try {
      final response = await apiCall(() => _dio.patch<Json>(
          '/devices/$deviceId/',
          data: {'language': languageCode}));
      // A backend from before languages ignores the field: only an answer
      // that has it counts, so the app sends it again once it's updated.
      if (response.data?['language'] == languageCode) {
        await _prefs.setString(_languageReportedKey, languageCode);
      }
    } catch (e) {
      debugPrint('Could not report the device language: $e');
    } finally {
      if (_reportingLanguage == languageCode) _reportingLanguage = null;
    }
  }
}

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => DeviceRepository(
    ref.watch(dioProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);
