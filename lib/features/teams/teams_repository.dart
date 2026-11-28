import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/core/api/paging.dart';
import 'package:scoreboards/core/providers.dart';
import 'package:scoreboards/shared/models/team.dart';

class TeamsRepository {
  TeamsRepository(this._dio);

  final Dio _dio;

  /// Every team (the endpoint is paginated).
  Future<List<Team>> all() async =>
      (await getAll(_dio, '/teams/')).map(Team.fromJson).toList();

  Future<Team> bySlug(String slug) async =>
      Team.fromJson(await getJson<Json>(_dio, '/teams/slug/$slug/'));

  /// The teams taking part in an edition.
  Future<List<Team>> byEdition(int editionId) async =>
      (await getList(_dio, '/edition/$editionId/teams/'))
          .map(Team.fromJson)
          .toList();
}

final teamsRepositoryProvider = Provider<TeamsRepository>(
  (ref) => TeamsRepository(ref.watch(dioProvider)),
);
