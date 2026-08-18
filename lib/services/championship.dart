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

    final standings = await fetchList(
      client: client,
      uri: Uri.parse(url),
      fromJson: (item) => Standing.fromJson(item),
      errorMessage: "Can't get standings.",
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
    return fetchList(
      client: client,
      uri: Uri.parse(urls['EDITIONS']['ACTIVE']),
      fromJson: (item) => Edition.fromJson(item),
      errorMessage: "Can't get Editions.",
    );
  }

  static Future<Edition> getEditionById(int editionId) async {
    return fetchJson(
      client: client,
      uri: Uri.parse(
          "${urls['EDITIONS']['ACTIVE']}${editionId.toString()}"),
      fromJson: (item) => Edition.fromJson(item),
      errorMessage: "Can't get Edition.",
    );
  }

  static Future<Edition> getEditionBySlug(String slug) async {
    return fetchJson(
      client: client,
      uri: Uri.parse(urls['EDITIONS']['BY_SLUG'] + "$slug/"),
      fromJson: (item) => Edition.fromJson(item),
      errorMessage: "Can't get Edition.",
    );
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
    return fetchJson(
      client: client,
      uri: Uri.parse(
          urls['CHAMPIONSHIPS']['BY_ID'].replaceAll('#championshipId', id)),
      fromJson: (item) => Championship.fromJson(item),
      errorMessage: "Can't get championship.",
    );
  }

  static Future<List<EditionStandingRule>> getRulesByChampionshipEdition(
      int editionId) async {
    return fetchList(
      client: client,
      uri: Uri.parse(urls['EDITIONS']['RULES']
          .replaceAll('#editionId', editionId.toString())),
      fromJson: (item) => EditionStandingRule.fromJson(item),
      errorMessage: "Can't get edition's rules.",
    );
  }
}
