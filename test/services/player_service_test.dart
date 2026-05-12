import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:scoreboards/services/player.dart';
import 'package:scoreboards/models/player.dart';
import 'package:scoreboards/models/transfert.dart';

void main() {
  group('PlayerService Tests', () {
    test('getPlayersByTeam returns list of players', () async {
      PlayerService.client = MockClient((request) async {
        return Response(
            jsonEncode([
              {
                "id": 1,
                "slug": "lionel-messi",
                "position": "FW",
                "nationality": "CMR",
                "firstname": "Lionel",
                "lastname": "Messi",
                "date_of_birth": "2025-01-01",
                "jersey_number": 2,
                "matricule": "#20251745"
              }
            ]),
            200);
      });

      final players = await PlayerService.getPlayersByTeam(5);

      expect(players, isA<List<Player>>());
      expect(players.length, 1);
      expect(players.first.id, 1);
      expect(players.first.firstname, "Lionel");
    });

    test('getPlayerStatsByEdition returns list of player stats', () async {
      PlayerService.client = MockClient((request) async {
        return Response(
            jsonEncode([
              {
                "player": {
                  'id': 10,
                  'slug': 'lionel-messi',
                  'firstname': 'Lionel',
                  'lastname': 'Messi'
                },
                "team": {"id": 1, "slug": "old-club", "name": "Old Club"},
                "goals": 12,
                "assists": 7,
                "yellow_cards": 0,
                "red_cards": 3
              }
            ]),
            200);
      });

      final stats = await PlayerService.getPlayerStatsByEdition(3);

      expect(stats.length, 1);
      expect(stats.first.goals, 12);
      expect(stats.first.assists, 7);
      expect(stats.first.yellowCards, 0);
      expect(stats.first.redCards, 3);
    });

    test('getPlayerStatsByTeam returns list of player stats', () async {
      PlayerService.client = MockClient((request) async {
        return Response(
            jsonEncode([
              {
                "player": {
                  'id': 10,
                  'slug': 'lionel-messi',
                  'firstname': 'Lionel',
                  'lastname': 'Messi'
                },
                "team": {"id": 1, "slug": "old-club", "name": "Old Club"},
                "goals": 4,
                "assists": 7,
                "yellow_cards": 0,
                "red_cards": 3
              }
            ]),
            200);
      });

      final stats = await PlayerService.getPlayerStatsByTeam(7);

      expect(stats.length, 1);
      expect(stats.first.assists, 7);
      expect(stats.first.goals, 4);
    });

    test('getPlayerContracts returns list of player contracts', () async {
      PlayerService.client = MockClient((request) async {
        return Response(
            jsonEncode([
              {
                "id": 97,
                "team": {"id": 1, "slug": "old-club", "name": "Old Club"},
                "player": {
                  'id': 10,
                  'slug': 'lionel-messi',
                  'firstname': 'Lionel',
                  'lastname': 'Messi'
                },
                "start_date": "2021-01-01"
              }
            ]),
            200);
      });

      final contracts = await PlayerService.getPlayerContracts(3);

      expect(contracts.length, 1);
      expect(contracts.first.startDate.year, 2021);
    });

    test('getPlayerTransfers returns list of transfers', () async {
      PlayerService.client = MockClient((request) async {
        return Response(
            jsonEncode([
              {
                "id": 58,
                "team": {"id": 1, "slug": "old-club", "name": "Old Club"},
                "player": {
                  'id': 10,
                  'slug': 'lionel-messi',
                  'firstname': 'Lionel',
                  'lastname': 'Messi'
                },
                "start_date": "2022-01-01"
              }
            ]),
            200);
      });

      final transfers = await PlayerService.getPlayerTransfers(8);

      expect(transfers, isA<List<PlayerTransfert>>());
      expect(transfers.first.team.name, "Old Club");
    });

    test('getPlayerTeamsHistory returns list of team history', () async {
      PlayerService.client = MockClient((request) async {
        return Response(
            jsonEncode([
              {
                "team": {
                  "id": 3,
                  "slug": "team-history",
                  "name": "Team History",
                  "team_type": "club",
                  "coach": "Test Coach"
                },
                "start_date": "2022-01-01"
              }
            ]),
            200);
      });

      final history = await PlayerService.getPlayerTeamsHistory(1);

      expect(history.length, 1);
      expect(history.first.team.name, "Team History");
    });

    test('getPlayersByTeam throws error on non-200', () async {
      PlayerService.client = MockClient((request) async {
        return Response("Server error", 500);
      });

      expect(
        () async => await PlayerService.getPlayersByTeam(99),
        throwsA(isA<String>()),
      );
    });
  });
}
