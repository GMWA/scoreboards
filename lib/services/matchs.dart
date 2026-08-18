import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/services/api_pagination.dart';

class MatchService {
  static Client client = Client();
  static Future<List<MatchBase>> getMatchsByDay(DateTime date) async {
    return fetchList(
      client: client,
      uri: Uri.parse(urls['MATCHS']['BY_DAY']
          .replaceAll('#date', DateFormat('dd-MM-yyyy').format(date))),
      fromJson: (item) => MatchBase.fromJson(item),
      errorMessage: "Can't get matchs.",
    );
  }

  static Future<Match> getMatchById(matchId) async {
    return fetchJson(
      client: client,
      uri: Uri.parse(
          urls['MATCHS']['BY_ID'].replaceAll('#matchId', matchId.toString())),
      fromJson: (item) => Match.fromJson(item),
      errorMessage: "Can't get standings.",
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
      errorMessage: "Can't get standings.",
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

  static Future<List<MatchBase>> getMatchsByEdition(int editionId,
      {String status = ""}) async {
    // /matchs/edition/#editionId/ is now paginated
    // ({"count","next","previous","results"}) rather than a bare array,
    // so this walks every page and flattens the results.
    String url = urls['MATCHS']['BY_EDITION']
        .replaceAll('#editionId', editionId.toString());

    final uri = Uri.parse(url).replace(queryParameters: {
      if (status.isNotEmpty) 'status': status,
    });

    return fetchPaginated(
      client: client,
      uri: uri,
      fromJson: (item) => MatchBase.fromJson(item),
    );
  }
}
