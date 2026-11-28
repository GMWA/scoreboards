import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/core/api/paging.dart';
import 'package:scoreboards/core/providers.dart';
import 'package:scoreboards/shared/models/match.dart';

class MatchRepository {
  MatchRepository(this._dio);

  final Dio _dio;

  /// Matches kicking off on [date]'s local calendar day. The backend groups
  /// matches by UTC day, and a local day can overlap two UTC days, so this
  /// fetches each overlapping UTC day and keeps only the local day's matches.
  Future<List<MatchBase>> byDay(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day + 1);
    final utcDays = {
      DateFormat('yyyy-MM-dd').format(start.toUtc()),
      DateFormat('yyyy-MM-dd')
          .format(end.subtract(const Duration(microseconds: 1)).toUtc()),
    };

    final responses = await Future.wait(utcDays.map(
      (day) => getList(_dio, '/matchs/day/', query: {'date': day}),
    ));

    final byId = <int, MatchBase>{};
    for (final row in responses.expand((rows) => rows)) {
      final match = MatchBase.fromJson(row);
      if (!match.date.isBefore(start) && match.date.isBefore(end)) {
        byId[match.id] = match;
      }
    }
    return byId.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<List<MatchBase>> live() async =>
      (await getList(_dio, '/matchs/live/')).map(MatchBase.fromJson).toList();

  Future<Match> bySlug(String slug) async =>
      Match.fromJson(await getJson<Json>(_dio, '/matchs/slug/$slug/'));

  /// One page of an edition's matches. Pages are kept small because this
  /// endpoint returns full match details (lineups, goals, ...) per match,
  /// so large pages are slow.
  Future<ApiPage<MatchBase>> byEditionPage(
    int editionId, {
    String status = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final result = await getPage(
      _dio,
      '/matchs/edition/$editionId/',
      query: {if (status.isNotEmpty) 'status': status},
      page: page,
      pageSize: pageSize,
    );
    return (
      items: result.items.map(MatchBase.fromJson).toList(),
      nextPage: result.nextPage,
    );
  }
}

final matchRepositoryProvider = Provider<MatchRepository>(
  (ref) => MatchRepository(ref.watch(dioProvider)),
);
