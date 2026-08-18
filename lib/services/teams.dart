import 'package:http/http.dart';
import 'package:scoreboards/models/team.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/services/api_pagination.dart';

class TeamService {
  static Client client = Client();
  static Future<List<Team>> getTeamsByChampionshipAndYear(
      int championship, int year) async {
    return fetchList(
      client: client,
      uri: Uri.parse(urls['TEAMS']['BY_CHAMPIONSHIP_YEAR']
          .replaceAll('#championshipId', championship.toString())
          .replaceAll('#year', year.toString())),
      fromJson: (item) => Team.fromJson(item),
      errorMessage: "Can't get Teams.",
    );
  }

  static Future<List<Team>> getTeamsByEdition(int edition) async {
    return fetchList(
      client: client,
      uri: Uri.parse(urls['TEAMS']['BY_EDITION']
          .replaceAll('#editionId', edition.toString())),
      fromJson: (item) => Team.fromJson(item),
      errorMessage: "Can't get Teams.",
    );
  }

  static Future<List<Team>> getTeams() async {
    // /teams/ is now paginated ({"count","next","previous","results"})
    // rather than a bare array, so this walks every page and flattens
    // the results instead of assuming a plain list.
    return fetchPaginated(
      client: client,
      uri: Uri.parse(urls['TEAMS']['ALL']),
      fromJson: (item) => Team.fromJson(item),
    );
  }

  static Future<Team> getTeamById(int id) async {
    return fetchJson(
      client: client,
      uri: Uri.parse(
          urls['TEAMS']['BY_ID'].replaceAll('#teamId', id.toString())),
      fromJson: (item) => Team.fromJson(item),
      errorMessage: "Can't get Team.",
    );
  }

  static Future<Team> getTeamBySlug(String slug) async {
    return fetchJson(
      client: client,
      uri: Uri.parse(urls['TEAMS']['BY_SLUG'] + "$slug/"),
      fromJson: (item) => Team.fromJson(item),
      errorMessage: "Can't get Team.",
    );
  }
}
