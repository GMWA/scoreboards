import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/constants/urls.dart';

class MatchService {
  static Client client = Client();
  static Future<List<MatchBase>> getMatchsByDay(DateTime date) async {
    Response res = await client.get(Uri.parse(urls['MATCHS']['BY_DAY']
        .replaceAll('#date', DateFormat('dd-MM-yyyy').format(date))));

    if (res.statusCode == 200) {
      List<dynamic> matchsList = jsonDecode(res.body);
      List<MatchBase> matchs =
          matchsList.map((dynamic item) => MatchBase.fromJson(item)).toList();
      return matchs;
    } else {
      throw "Can't get matchs.";
    }
  }

  static Future<Match> getMatchById(matchId) async {
    Response res = await client.get(Uri.parse(
        urls['MATCHS']['BY_ID'].replaceAll('#matchId', matchId.toString())));

    if (res.statusCode == 200) {
      dynamic matchItem = jsonDecode(res.body);
      Match match = Match.fromJson(matchItem);
      return match;
    } else {
      throw "Can't get standings.";
    }
  }

  static Future<Match> getMatchBySlug(String slug) async {
    Response res =
        await client.get(Uri.parse(urls['MATCHS']['BY_SLUG'] + "$slug/"));

    if (res.statusCode == 200) {
      dynamic matchItem = jsonDecode(res.body);
      Match match = Match.fromJson(matchItem);
      return match;
    } else {
      throw "Can't get Match.";
    }
  }

  static Future<List<MatchBase>> getLiveMatches() async {
    Response res = await client.get(Uri.parse(urls['MATCHS']['LIVE']));

    if (res.statusCode == 200) {
      List<dynamic> matchsList = jsonDecode(res.body);
      List<MatchBase> matchs =
          matchsList.map((dynamic item) => MatchBase.fromJson(item)).toList();
      return matchs;
    } else {
      throw "Can't get standings.";
    }
  }

  static Future<List<MatchBase>> getMatchsByChampionshipEdition(
      int championshipId, int editionId,
      {String status = ""}) async {
    try {
      String url = urls['MATCHS']['BY_CHAMPIONSHIP_EDITION']
          .replaceAll('#championshipId', championshipId.toString())
          .replaceAll('#editionId', editionId.toString());

      if (status.isNotEmpty) {
        url += '?status=$status';
      }

      final res = await client.get(Uri.parse(url));

      if (res.statusCode == 200) {
        List<dynamic> matchsList = jsonDecode(res.body);
        // print(matchsList);
        return matchsList.map((item) => MatchBase.fromJson(item)).toList();
      } else {
        throw Exception(
            "Failed to fetch matches. Status code: ${res.statusCode}");
      }
    } catch (e) {
      rethrow; // Let the FutureBuilder or caller handle the exception
    }
  }

  static Future<List<MatchBase>> getMatchsByEdition(int editionId,
      {String status = ""}) async {
    try {
      String url = urls['MATCHS']['BY_EDITION']
          .replaceAll('#editionId', editionId.toString());

      if (status.isNotEmpty) {
        url += '?status=$status';
      }
      final res = await client.get(Uri.parse(url));
      if (res.statusCode == 200) {
        List<dynamic> matchsList = jsonDecode(res.body);
        return matchsList.map((item) => MatchBase.fromJson(item)).toList();
      } else {
        throw Exception(
            "Failed to fetch matches. Status code: ${res.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
