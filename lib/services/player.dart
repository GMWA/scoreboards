import 'package:http/http.dart';
import 'package:scoreboards/models/player.dart';
import 'package:scoreboards/models/transfert.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/services/api_pagination.dart';

class PlayerService {
  static Client client = Client();
  static Future<List<Player>> getPlayersByTeam(int teamId) async {
    return fetchList(
      client: client,
      uri: Uri.parse(
          urls['PLAYERS']['BY_TEAM'].replaceAll('#teamId', teamId.toString())),
      fromJson: (item) => Player.fromJson(item),
      errorMessage: 'Failed to load players',
    );
  }

  static Future<Player> getPlayerBySlug(String slug) async {
    return fetchJson(
      client: client,
      uri: Uri.parse(urls['PLAYERS']['BY_SLUG'] + "$slug/"),
      fromJson: (item) => Player.fromJson(item),
      errorMessage: "Can't get Player.",
    );
  }

  static Future<List<PlayerStats>> getPlayerStatsByEdition(
      int editionId) async {
    return fetchList(
      client: client,
      uri: Uri.parse(urls['PLAYERS']['STATS_BY_EDITION']
          .replaceAll('#editionId', editionId.toString())),
      fromJson: (item) => PlayerStats.fromJson(item),
      errorMessage: "Can't get players stats by edition.",
    );
  }

  static Future<List<PlayerStats>> getPlayerStatsByTeam(int teamId) async {
    return fetchList(
      client: client,
      uri: Uri.parse(urls['PLAYERS']['STATS_BY_TEAM']
          .replaceAll('#teamId', teamId.toString())),
      fromJson: (item) => PlayerStats.fromJson(item),
      errorMessage: "Can't get players stats by team.",
    );
  }

  static Future<List<PlayerContract>> getPlayerContracts(int playerId) async {
    return fetchList(
      client: client,
      uri: Uri.parse(urls['PLAYERS']['CONTRACT_BY_PLAYER']
          .replaceAll('#playerId', playerId.toString())),
      fromJson: (item) => PlayerContract.fromJson(item),
      errorMessage: "Can't get players Contacts by player.",
    );
  }

  static Future<List<PlayerTransfert>> getPlayerTransfers(int playerId) async {
    return fetchList(
      client: client,
      uri: Uri.parse(urls['PLAYERS']['TRANSFER_BY_PLAYER']
          .replaceAll('#playerId', playerId.toString())),
      fromJson: (item) => PlayerTransfert.fromJson(item),
      errorMessage: "Can't get players transfer by player.",
    );
  }

  static Future<List<PlayerTeamHistory>> getPlayerTeamsHistory(
      int playerId) async {
    return fetchList(
      client: client,
      uri: Uri.parse(urls['PLAYERS']['PLAYER_TEAM_HISTORY']
          .replaceAll('#playerId', playerId.toString())),
      fromJson: (item) => PlayerTeamHistory.fromJson(item),
      errorMessage: "Can't get players team history by player.",
    );
  }
}
