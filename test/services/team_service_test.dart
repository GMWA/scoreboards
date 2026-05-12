import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart';
import 'package:scoreboards/services/teams.dart';
import 'package:scoreboards/models/team.dart';

void main() {
  group('TeamService Tests', () {
    test('getTeamsByChampionshipAndYear returns list of teams', () async {
      TeamService.client = MockClient((request) async {
        return Response(
            jsonEncode([
              {
                "id": 1,
                "slug": "team-a",
                "name": "Team A",
                "logo": "logo.png",
                "team_type": "club",
                "coach": "Test Coach",
                "stadium": null,
                "league": null,
                "country": "Country",
                "confederation": "CAF"
              }
            ]),
            200);
      });

      final teams = await TeamService.getTeamsByChampionshipAndYear(1, 2024);

      expect(teams, isA<List<Team>>());
      expect(teams.length, 1);
      expect(teams.first.id, 1);
      expect(teams.first.name, "Team A");
    });

    test('getTeamsByEdition returns list of teams', () async {
      TeamService.client = MockClient((request) async {
        return Response(
            jsonEncode([
              {
                "id": 10,
                "slug": "edition-team",
                "name": "Edition Team",
                "team_type": "club",
                "coach": "Test Coach"
              }
            ]),
            200);
      });

      final teams = await TeamService.getTeamsByEdition(33);

      expect(teams.length, 1);
      expect(teams.first.id, 10);
    });

    test('getTeams returns all teams', () async {
      TeamService.client = MockClient((request) async {
        return Response(
            jsonEncode([
              {
                "id": 1,
                "name": "T1",
                "slug": "t1",
                "team_type": "club",
                "coach": "Test Coach"
              },
              {
                "id": 2,
                "name": "T2",
                "slug": "t2",
                "team_type": "club",
                "coach": "Test Coach"
              }
            ]),
            200);
      });

      final teams = await TeamService.getTeams();

      expect(teams.length, 2);
      expect(teams[0].id, 1);
    });

    test('getTeamById returns a single team', () async {
      TeamService.client = MockClient((request) async {
        return Response(
            jsonEncode({
              "id": 99,
              "slug": "single-team",
              "name": "Single Team",
              "team_type": "club",
              "coach": "Test Coach"
            }),
            200);
      });

      final team = await TeamService.getTeamById(99);

      expect(team.id, 99);
      expect(team.name, "Single Team");
    });

    test('getTeams throws exception on non-200 response', () async {
      TeamService.client = MockClient((request) async {
        return Response("Error", 500);
      });

      expect(
        () async => await TeamService.getTeams(),
        throwsA(isA<String>()),
      );
    });
  });
}
