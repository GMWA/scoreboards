import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/core/device/device_repository.dart';
import 'package:scoreboards/core/providers.dart';

class FavoritesRepository {
  FavoritesRepository(this._dio, this._device);

  final Dio _dio;
  final DeviceRepository _device;

  /// Sends the device's complete favorites to the backend, which replaces
  /// what it has stored for the device. Competitions are followed as
  /// editions; the backend counts them per championship. Throws on failure.
  Future<void> sync({
    required List<int> teams,
    required List<int> editions,
  }) async {
    final deviceId = await _device.id();
    await apiCall(() => _dio.put<void>(
          '/notifications/favorites/$deviceId/',
          data: {'teams': teams, 'editions': editions},
        ));
  }
}

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(
    ref.watch(dioProvider),
    ref.watch(deviceRepositoryProvider),
  ),
);
