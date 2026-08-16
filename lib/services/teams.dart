import 'dart:convert';
import 'package:http/http.dart';
import 'package:scoreboards/models/team.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/services/api_pagination.dart';

class TeamService {
  static Client client = Client();
  static Future<List<Team>> getTeamsByChampionshipAndYear(
    int championship, int year) async {
  return fetchPaginated(
    client: client,
    uri: Uri.parse(urls['TEAMS']['BY_CHAMPIONSHIP_YEAR']
        .replaceAll('#championshipId', championship.toString())
        .replaceAll('#year', year.toString())),
    fromJson: (item) => Team.fromJson(item),
  );
}

  static Future<List<Team>> getTeamsByEdition(int edition) async {
  return fetchPaginated(
    client: client,
    uri: Uri.parse(urls['TEAMS']['BY_EDITION']
        .replaceAll('#editionId', edition.toString())),
    fromJson: (item) => Team.fromJson(item),
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
    Response res = await client.get(
        Uri.parse(urls['TEAMS']['BY_ID'].replaceAll('#teamId', id.toString())));

    if (res.statusCode == 200) {
      Map<String, dynamic> teamMap = jsonDecode(res.body);
      Team team = Team.fromJson(teamMap);
      return team;
    } else {
      throw Exception("Can't get Team.");
    }
  }

  static Future<Team> getTeamBySlug(String slug) async {
    Response res =
        await client.get(Uri.parse(urls['TEAMS']['BY_SLUG'] + "$slug/"));

    if (res.statusCode == 200) {
      dynamic teamItem = jsonDecode(res.body);
      Team team = Team.fromJson(teamItem);
      return team;
    } else {
      throw Exception("Can't get Team.");
    }
  }
}
