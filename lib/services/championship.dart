import 'dart:convert';
import 'package:http/http.dart';
import 'package:scoreboards/models/championship.dart';
import 'package:scoreboards/models/editions.dart';
import 'package:scoreboards/models/standing.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/helpers/utils.dart';

class ChampionshipService {
  static Client client = Client();
  static Future<List<Standing>> getStandingsByChampionship(
      int editionId) async {
    try {
      final url = urls['STANDINGS']['CHAMPIONSHIP']
          .replaceAll('#editionId', editionId.toString());

      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> standingsJson = jsonDecode(response.body);
        return standingsJson.map((json) => Standing.fromJson(json)).toList()
          ..sort(standingSort);
      } else {
        throw Exception("Can't get standings.");
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Championship>> getChampionships() async {
    Response res = await client.get(Uri.parse(urls['CHAMPIONSHIPS']['ALL']));
    List<Championship> championships = [];
    if (res.statusCode == 200) {
      List<dynamic> championshipsList = jsonDecode(res.body);
      championships = championshipsList
          .map((dynamic item) => Championship.fromJson(item))
          .toList();
      return championships;
    } else {
      throw "Can't get championships.";
    }
  }

  static Future<List<Edition>> getActiveEditions() async {
    Response res = await client.get(Uri.parse(urls['EDITIONS']['ACTIVE']));
    List<Edition> editions = [];
    if (res.statusCode == 200) {
      List<dynamic> editionsList = jsonDecode(res.body);
      editions =
          editionsList.map((dynamic item) => Edition.fromJson(item)).toList();
      return editions;
    } else {
      throw "Can't get Editions.";
    }
  }

  static Future<Edition> getEditionById(int editionId) async {
    Response res = await client
        .get(Uri.parse("${urls['EDITIONS']['ACTIVE']}${editionId.toString()}"));
    if (res.statusCode == 200) {
      dynamic item = jsonDecode(res.body);
      return Edition.fromJson(item);
    } else {
      throw "Can't get Edition.";
    }
  }

  static Future<Edition> getEditionBySlug(String slug) async {
    Response res =
        await client.get(Uri.parse(urls['EDITIONS']['BY_SLUG'] + "$slug/"));

    if (res.statusCode == 200) {
      dynamic editionItem = jsonDecode(res.body);
      Edition edition = Edition.fromJson(editionItem);
      return edition;
    } else {
      throw "Can't get Edition.";
    }
  }

  static Future<List<Championship>> getChampionshipsByEdition(
      int edition) async {
    Response res = await client.get(Uri.parse(urls['CHAMPIONSHIPS']['ALL']));
    List<Championship> championships = [];
    if (res.statusCode == 200) {
      List<dynamic> championshipsList = jsonDecode(res.body);
      championships = championshipsList
          .map((dynamic item) => Championship.fromJson(item))
          .toList();
      return championships;
    } else {
      throw "Can't get championships.";
    }
  }

  static Future<Championship> getChampionshipById(String id) async {
    Response res = await client.get(Uri.parse(
        urls['CHAMPIONSHIPS']['BY_ID'].replaceAll('#championshipId', id)));
    if (res.statusCode == 200) {
      Map<String, dynamic> championshipMap = jsonDecode(res.body);
      Championship championship = Championship.fromJson(championshipMap);
      return championship;
    } else {
      throw "Can't get championship.";
    }
  }

  static Future<List<EditionStandingRule>> getRulesByChampionshipEdition(
      int editionId) async {
    Response res = await client.get(Uri.parse(urls['EDITIONS']['RULES']
        .replaceAll('#editionId', editionId.toString())));
    List<EditionStandingRule> rules = [];
    if (res.statusCode == 200) {
      List<dynamic> rulesList = jsonDecode(res.body);
      rules = rulesList
          .map((dynamic item) => EditionStandingRule.fromJson(item))
          .toList();
      return rules;
    } else {
      throw "Can't get edition's rules.";
    }
  }
}
