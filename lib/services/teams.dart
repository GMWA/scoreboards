import 'dart:convert';
import 'package:http/http.dart';
import 'package:scoreboards/models/team.dart';
import 'package:scoreboards/constants/urls.dart';

class TeamService {
  static Client client = Client();
  static Future<List<Team>> getTeamsByChampionshipAndYear(
      int championship, int year) async {
    Response res = await client.get(Uri.parse(urls['TEAMS']
            ['BY_CHAMPIONSHIP_YEAR']
        .replaceAll('#championshipId', championship.toString())
        .replaceAll('#year', year.toString())));

    if (res.statusCode == 200) {
      List<dynamic> teamsList = jsonDecode(res.body);
      List<Team> teams =
          teamsList.map((dynamic item) => Team.fromJson(item)).toList();
      return teams;
    } else {
      throw "Can't get Teams.";
    }
  }

  static Future<List<Team>> getTeamsByEdition(int edition) async {
    Response res = await client.get(Uri.parse(urls['TEAMS']['BY_EDITION']
        .replaceAll('#editionId', edition.toString())));

    if (res.statusCode == 200) {
      List<dynamic> teamsList = jsonDecode(res.body);
      List<Team> teams =
          teamsList.map((dynamic item) => Team.fromJson(item)).toList();
      return teams;
    } else {
      throw "Can't get Teams.";
    }
  }

  static Future<List<Team>> getTeams() async {
    Response res = await client.get(Uri.parse(urls['TEAMS']['ALL']));

    if (res.statusCode == 200) {
      List<dynamic> teamsList = jsonDecode(res.body);
      List<Team> teams =
          teamsList.map((dynamic item) => Team.fromJson(item)).toList();
      return teams;
    } else {
      throw "Can't get Teams.";
    }
  }

  static Future<Team> getTeamById(int id) async {
    Response res = await client.get(
        Uri.parse(urls['TEAMS']['BY_ID'].replaceAll('#teamId', id.toString())));

    if (res.statusCode == 200) {
      Map<String, dynamic> teamMap = jsonDecode(res.body);
      Team team = Team.fromJson(teamMap);
      return team;
    } else {
      throw "Can't get Team.";
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
      throw "Can't get Team.";
    }
  }
}
