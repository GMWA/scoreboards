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

  Future<String>? _pending;

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
    final body = await apiCall(() => _dio.post<Json>(
          '/devices/',
          data: {if (platform != null) 'platform': platform},
        ));
    final id = body.data!['device_id'] as String;
    await _prefs.setString(_idKey, id);
    // Registration already sent the platform.
    if (platform != null) await _prefs.setBool(_platformReportedKey, true);
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
}

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => DeviceRepository(
    ref.watch(dioProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);
