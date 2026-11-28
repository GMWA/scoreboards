import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/core/api/paging.dart';
import 'package:scoreboards/core/providers.dart';
import 'package:scoreboards/shared/models/player.dart';

class PlayersRepository {
  PlayersRepository(this._dio);

  final Dio _dio;

  Future<Player> bySlug(String slug) async =>
      Player.fromJson(await getJson<Json>(_dio, '/players/slug/$slug/'));

  /// The clubs the player has played for, past and current.
  Future<List<PlayerTeamHistory>> teamsHistory(int playerId) async =>
      (await getList(_dio, '/players/$playerId/teams-history/'))
          .map(PlayerTeamHistory.fromJson)
          .toList();

  /// Every player's statistics in an edition (top scorers).
  Future<List<PlayerStats>> statsByEdition(int editionId) async =>
      (await getList(_dio, '/players/stats/edition/$editionId/'))
          .map(PlayerStats.fromJson)
          .toList();

  /// Every player's statistics for a team.
  Future<List<PlayerStats>> statsByTeam(int teamId) async =>
      (await getList(_dio, '/players/stats/team/$teamId/'))
          .map(PlayerStats.fromJson)
          .toList();
}

final playersRepositoryProvider = Provider<PlayersRepository>(
  (ref) => PlayersRepository(ref.watch(dioProvider)),
);
