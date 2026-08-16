import 'dart:convert';
import 'package:http/http.dart';
import 'package:scoreboards/models/player.dart';
import 'package:scoreboards/models/transfert.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/services/api_pagination.dart';

class PlayerService {
  static Client client = Client();
  static Future<List<Player>> getPlayersByTeam(int teamId) async {
  return fetchPaginated(
    client: client,
    uri: Uri.parse(
        urls['PLAYERS']['BY_TEAM'].replaceAll('#teamId', teamId.toString())),
    fromJson: (item) => Player.fromJson(item),
  );
}

  static Future<Player> getPlayerBySlug(String slug) async {
    Response res =
        await client.get(Uri.parse(urls['PLAYERS']['BY_SLUG'] + "$slug/"));

    if (res.statusCode == 200) {
      dynamic playerItem = jsonDecode(res.body);
      Player player = Player.fromJson(playerItem);
      return player;
    } else {
      throw Exception("Can't get Player.");
    }
  }

  static Future<List<PlayerStats>> getPlayerStatsByEdition(
    int editionId) async {
  try {
    final res = await client.get(Uri.parse(
      urls['PLAYERS']['STATS_BY_EDITION']
          .replaceAll('#editionId', editionId.toString()),
    ));

    if (res.statusCode == 200) {
      final playersList = jsonDecode(res.body);

      final playerStats = (playersList as List)
          .map((item) => PlayerStats.fromJson(item))
          .toList();

      return playerStats;
    } else {
      throw Exception("Can't get players stats by edition.");
    }
  } catch (e) {
    rethrow;
  }
}

  static Future<List<PlayerStats>> getPlayerStatsByTeam(int teamId) async {
  return fetchPaginated(
    client: client,
    uri: Uri.parse(urls['PLAYERS']['STATS_BY_TEAM']
        .replaceAll('#teamId', teamId.toString())),
    fromJson: (item) => PlayerStats.fromJson(item),
  );
}

  static Future<List<PlayerContract>> getPlayerContracts(int playerId) async {
  return fetchPaginated(
    client: client,
    uri: Uri.parse(urls['PLAYERS']['CONTRACT_BY_PLAYER']
        .replaceAll('#playerId', playerId.toString())),
    fromJson: (item) => PlayerContract.fromJson(item),
  );
}

  static Future<List<PlayerTransfert>> getPlayerTransfers(int playerId) async {
  return fetchPaginated(
    client: client,
    uri: Uri.parse(urls['PLAYERS']['TRANSFER_BY_PLAYER']
        .replaceAll('#playerId', playerId.toString())),
    fromJson: (item) => PlayerTransfert.fromJson(item),
  );
}

  static Future<List<PlayerTeamHistory>> getPlayerTeamsHistory(
    int playerId) async {
  return fetchPaginated(
    client: client,
    uri: Uri.parse(urls['PLAYERS']['PLAYER_TEAM_HISTORY']
        .replaceAll('#playerId', playerId.toString())),
    fromJson: (item) => PlayerTeamHistory.fromJson(item),
  );
}
}
