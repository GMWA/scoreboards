import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/core/api/paging.dart';
import 'package:scoreboards/core/providers.dart';
import 'package:scoreboards/features/competitions/standing.dart';
import 'package:scoreboards/shared/models/editions.dart';

class CompetitionsRepository {
  CompetitionsRepository(this._dio);

  final Dio _dio;

  /// The editions shown on the Leagues tab, current and archived.
  Future<List<Edition>> activeEditions() async =>
      (await getList(_dio, '/championships/editions/'))
          .map(Edition.fromJson)
          .toList();

  Future<Edition> editionBySlug(String slug) async => Edition.fromJson(
      await getJson<Json>(_dio, '/championships/editions/slug/$slug/'));

  /// The edition's standings, in table order.
  Future<List<Standing>> standings(int editionId) async =>
      (await getList(_dio, '/edition/$editionId/standings/'))
          .map(Standing.fromJson)
          .toList()
        ..sort(standingSort);

  /// The qualification rules that colour the standings.
  Future<List<EditionStandingRule>> standingRules(int editionId) async =>
      (await getList(_dio, '/edition/$editionId/rules/'))
          .map(EditionStandingRule.fromJson)
          .toList();
}

final competitionsRepositoryProvider = Provider<CompetitionsRepository>(
  (ref) => CompetitionsRepository(ref.watch(dioProvider)),
);
