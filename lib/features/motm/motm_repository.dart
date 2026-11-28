import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/core/api/paging.dart';
import 'package:scoreboards/core/device/device_repository.dart';
import 'package:scoreboards/core/providers.dart';
import 'package:scoreboards/features/motm/motm_models.dart';

/// Fan "Man of the Match" voting. A vote belongs to this install's device.
class MotmRepository {
  MotmRepository(this._dio, this._device);

  final Dio _dio;
  final DeviceRepository _device;

  String _path(int matchId) => '/matchs/$matchId/player-of-the-match/';

  /// The candidates, tally and this device's vote.
  Future<MotmSummary> summary(int matchId) async {
    final deviceId = await _device.id();
    return MotmSummary.fromJson(await getJson<Json>(
      _dio,
      _path(matchId),
      query: {'device_id': deviceId},
    ));
  }

  /// Throws [ApiException] when the backend refuses (409 voting closed, 400
  /// invalid candidate, 403 device not eligible), with its explanation.
  Future<MotmSummary> vote(int matchId, int playerId) async {
    final deviceId = await _device.id();
    final response = await apiCall(() => _dio.post<Json>(
          _path(matchId),
          data: {'device_id': deviceId, 'player_id': playerId},
        ));
    return MotmSummary.fromJson(response.data!);
  }

  Future<MotmSummary> retract(int matchId) async {
    final deviceId = await _device.id();
    final response = await apiCall(() => _dio.delete<Json>(
          _path(matchId),
          data: {'device_id': deviceId},
        ));
    return MotmSummary.fromJson(response.data!);
  }
}

final motmRepositoryProvider = Provider<MotmRepository>(
  (ref) => MotmRepository(
    ref.watch(dioProvider),
    ref.watch(deviceRepositoryProvider),
  ),
);
