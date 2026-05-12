import 'dart:convert';
import 'package:http/http.dart';
import 'package:scoreboards/models/player.dart';
import 'package:scoreboards/models/transfert.dart';
import 'package:scoreboards/constants/urls.dart';

class PlayerService {
  static Client client = Client();
  static Future<List<Player>> getPlayersByTeam(int teamId) async {
    Response res = await client.get(Uri.parse(
        urls['PLAYERS']['BY_TEAM'].replaceAll('#teamId', teamId.toString())));

    if (res.statusCode == 200) {
      List<dynamic> playersList = jsonDecode(res.body);
      List<Player> players =
          playersList.map((dynamic item) => Player.fromJson(item)).toList();
      return players;
    } else {
      throw "Can't get players.";
    }
  }

  static Future<Player> getPlayerBySlug(String slug) async {
    Response res =
        await client.get(Uri.parse(urls['PLAYERS']['BY_SLUG'] + "$slug/"));

    if (res.statusCode == 200) {
      dynamic playerItem = jsonDecode(res.body);
      Player player = Player.fromJson(playerItem);
      return player;
    } else {
      throw "Can't get Player.";
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
    try {
      final res = await client.get(Uri.parse(
        urls['PLAYERS']['STATS_BY_TEAM']
            .replaceAll('#teamId', teamId.toString()),
      ));

      if (res.statusCode == 200) {
        final playersList = jsonDecode(res.body);

        final playerStats = (playersList as List)
            .map((item) => PlayerStats.fromJson(item))
            .toList();

        return playerStats;
      } else {
        throw Exception("Can't get players stats by team.");
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PlayerContract>> getPlayerContracts(int playerId) async {
    try {
      final res = await client.get(Uri.parse(
        urls['PLAYERS']['CONTRACT_BY_PLAYER']
            .replaceAll('#playerId', playerId.toString()),
      ));

      if (res.statusCode == 200) {
        final dataList = jsonDecode(res.body);

        final playerContrats = (dataList as List)
            .map((item) => PlayerContract.fromJson(item))
            .toList();

        return playerContrats;
      } else {
        throw Exception("Can't get players Contacts by player.");
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PlayerTransfert>> getPlayerTransfers(int playerId) async {
    try {
      final res = await client.get(Uri.parse(
        urls['PLAYERS']['TRANSFER_BY_PLAYER']
            .replaceAll('#playerId', playerId.toString()),
      ));

      if (res.statusCode == 200) {
        final playersTranseferList = jsonDecode(res.body);

        final playerTransferts = (playersTranseferList as List)
            .map((item) => PlayerTransfert.fromJson(item))
            .toList();

        return playerTransferts;
      } else {
        throw Exception("Can't get players transfer by player.");
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PlayerTeamHistory>> getPlayerTeamsHistory(
      int playerId) async {
    try {
      final res = await client.get(Uri.parse(
        urls['PLAYERS']['PLAYER_TEAM_HISTORY']
            .replaceAll('#playerId', playerId.toString()),
      ));

      if (res.statusCode == 200) {
        final dataList = jsonDecode(res.body);

        final playerTeams = (dataList as List)
            .map((item) => PlayerTeamHistory.fromJson(item))
            .toList();

        return playerTeams;
      } else {
        throw Exception("Can't get players team history by player.");
      }
    } catch (e) {
      rethrow;
    }
  }
}
