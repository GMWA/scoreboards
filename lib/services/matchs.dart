import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/services/api_pagination.dart';

class MatchService {
  static Client client = Client();
  /// Matches kicking off on [date]'s local calendar day. The backend groups
  /// matches by UTC day, and a local day can overlap two UTC days, so this
  /// fetches each overlapping UTC day and keeps only the local day's matches.
  static Future<List<MatchBase>> getMatchsByDay(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day + 1);
    final utcDays = {
      DateFormat('dd-MM-yyyy').format(start.toUtc()),
      DateFormat('dd-MM-yyyy')
          .format(end.subtract(const Duration(microseconds: 1)).toUtc()),
    };

    final responses = await Future.wait(utcDays.map((day) => fetchList(
          client: client,
          uri: Uri.parse(urls['MATCHS']['BY_DAY'].replaceAll('#date', day)),
          fromJson: (item) => MatchBase.fromJson(item),
          errorMessage: "Can't get matchs.",
        )));

    final byId = <int, MatchBase>{};
    for (final match in responses.expand((list) => list)) {
      if (!match.date.isBefore(start) && match.date.isBefore(end)) {
        byId[match.id] = match;
      }
    }
    return byId.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  static Future<Match> getMatchById(matchId) async {
    return fetchJson(
      client: client,
      uri: Uri.parse(
          urls['MATCHS']['BY_ID'].replaceAll('#matchId', matchId.toString())),
      fromJson: (item) => Match.fromJson(item),
      errorMessage: "Can't get Match.",
    );
  }

  static Future<Match> getMatchBySlug(String slug) async {
    return fetchJson(
      client: client,
      uri: Uri.parse(urls['MATCHS']['BY_SLUG'] + "$slug/"),
      fromJson: (item) => Match.fromJson(item),
      errorMessage: "Can't get Match.",
    );
  }

  static Future<List<MatchBase>> getLiveMatches() async {
    return fetchList(
      client: client,
      uri: Uri.parse(urls['MATCHS']['LIVE']),
      fromJson: (item) => MatchBase.fromJson(item),
      errorMessage: "Can't get live matches.",
    );
  }

  static Future<List<MatchBase>> getMatchsByChampionshipEdition(
      int championshipId, int editionId,
      {String status = ""}) async {
    String url = urls['MATCHS']['BY_CHAMPIONSHIP_EDITION']
        .replaceAll('#championshipId', championshipId.toString())
        .replaceAll('#editionId', editionId.toString());

    if (status.isNotEmpty) {
      url += '?status=$status';
    }

    return fetchList(
      client: client,
      uri: Uri.parse(url),
      fromJson: (item) => MatchBase.fromJson(item),
    );
  }

  /// One page of an edition's matches. Pass the previous page's `next` to
  /// continue. Pages are kept small because this endpoint returns full match
  /// details (lineups, goals, ...) per match, so large pages are slow.
  static Future<({List<MatchBase> items, Uri? next})> getMatchsByEditionPage(
      int editionId,
      {String status = "",
      Uri? next,
      int pageSize = 20}) async {
    final firstPage = Uri.parse(urls['MATCHS']['BY_EDITION']
            .replaceAll('#editionId', editionId.toString()))
        .replace(queryParameters: {
      if (status.isNotEmpty) 'status': status,
    });

    return fetchPage(
      client: client,
      uri: next ?? withPageSize(firstPage, pageSize),
      fromJson: (item) => MatchBase.fromJson(item),
    );
  }
}
