import 'dart:convert';
import 'package:http/http.dart';
import 'package:scoreboards/models/championship.dart';
import 'package:scoreboards/models/editions.dart';
import 'package:scoreboards/models/standing.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/helpers/utils.dart';
import 'package:scoreboards/services/api_pagination.dart';

class ChampionshipService {
  static Client client = Client();
static Future<List<Standing>> getStandingsByChampionship(
    int editionId) async {
  final url = urls['STANDINGS']['CHAMPIONSHIP']
      .replaceAll('#editionId', editionId.toString());

  final standings = await fetchPaginated(
    client: client,
    uri: Uri.parse(url),
    fromJson: (item) => Standing.fromJson(item),
  );

  return standings..sort(standingSort);
}

  static Future<List<Championship>> getChampionships() async {
    // /championships/ is now paginated
    // ({"count","next","previous","results"}) rather than a bare array,
    // so this walks every page and flattens the results.
    return fetchPaginated(
      client: client,
      uri: Uri.parse(urls['CHAMPIONSHIPS']['ALL']),
      fromJson: (item) => Championship.fromJson(item),
    );
  }

  static Future<List<Edition>> getActiveEditions() async {
  return fetchPaginated(
    client: client,
    uri: Uri.parse(urls['EDITIONS']['ACTIVE']),
    fromJson: (item) => Edition.fromJson(item),
  );
}

  static Future<Edition> getEditionById(int editionId) async {
    Response res = await client
        .get(Uri.parse("${urls['EDITIONS']['ACTIVE']}${editionId.toString()}"));
    if (res.statusCode == 200) {
      dynamic item = jsonDecode(res.body);
      return Edition.fromJson(item);
    } else {
      throw Exception("Can't get Edition.");
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
      throw Exception("Can't get Edition.");
    }
  }

  static Future<List<Championship>> getChampionshipsByEdition(
      int edition) async {
    return fetchPaginated(
      client: client,
      uri: Uri.parse(urls['CHAMPIONSHIPS']['ALL']),
      fromJson: (item) => Championship.fromJson(item),
    );
  }

  static Future<Championship> getChampionshipById(String id) async {
    Response res = await client.get(Uri.parse(
        urls['CHAMPIONSHIPS']['BY_ID'].replaceAll('#championshipId', id)));
    if (res.statusCode == 200) {
      Map<String, dynamic> championshipMap = jsonDecode(res.body);
      Championship championship = Championship.fromJson(championshipMap);
      return championship;
    } else {
      throw Exception("Can't get championship.");
    }
  }

  static Future<List<EditionStandingRule>> getRulesByChampionshipEdition(
    int editionId) async {
  return fetchPaginated(
    client: client,
    uri: Uri.parse(urls['EDITIONS']['RULES']
        .replaceAll('#editionId', editionId.toString())),
    fromJson: (item) => EditionStandingRule.fromJson(item),
  );
}
}
