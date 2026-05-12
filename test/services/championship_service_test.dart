import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:scoreboards/services/championship.dart';
import 'package:scoreboards/models/championship.dart';
import 'package:scoreboards/models/standing.dart';
import 'package:scoreboards/models/editions.dart';

void main() {
  group('ChampionshipService Tests', () {
    test('getChampionships returns list of championships', () async {
      // Mock API response
      ChampionshipService.client = MockClient((request) async {
        return Response(jsonEncode([
          {
            "id": 1,
            "name": "Premier League",
            "country": "England",
            "logo": "premier.png",
            "editions": []
          }
        ]), 200);
      });

      final list = await ChampionshipService.getChampionships();

      expect(list, isA<List<Championship>>());
      expect(list.length, 1);
      expect(list.first.name, "Premier League");
    });

    test('getActiveEditions returns list of Edition', () async {
      ChampionshipService.client = MockClient((request) async {
        return Response(jsonEncode([
          {
            "id": 55,
            "slug": "la-liga-2024",
            "year": "2024",
            "label": "Season 2024",
            "start_date": "2024-01-01",
            "end_date": "2024-12-31",
            "is_current": true,
            "championship": {
              "id": 1,
              "name": "La Liga",
              "country": "Spain",
              "logo": "laliga.png"
            }
          }
        ]), 200);
      });

      final list = await ChampionshipService.getActiveEditions();

      expect(list, isA<List<Edition>>());
      expect(list.first.year, "2024");
      expect(list.first.championship.name, "La Liga");
    });

    test('getStandingsByChampionship returns sorted standings', () async {
      ChampionshipService.client = MockClient((request) async {
        return Response(jsonEncode([
          {
            "id": 10,
            "participation": {
              "id": 1,
              "team": {"id": 1, "slug": "team-a", "name": "Team A"},
              "group": null
            },
            "points": 60,
            "matches_played": 20,
            "wins": 18,
            "draws": 2,
            "losses": 0,
            "goals_for": 40,
            "goals_against": 10
          }
        ]), 200);
      });

      final list =
          await ChampionshipService.getStandingsByChampionship(123);

      expect(list, isA<List<Standing>>());
      expect(list.first.points, 60);
      expect(list.first.goalsFor, 40);
    });

    test('getEditionById returns Edition', () async {
      ChampionshipService.client = MockClient((request) async {
        return Response(jsonEncode({
          "id": 55,
          "slug": "serie-a-2024",
          "year": "2024",
          "label": "Season 2024",
          "start_date": "2024-01-01",
          "end_date": "2024-12-31",
          "is_current": true,
          "championship": {
            "id": 1,
            "name": "Serie A",
            "country": "Italy",
            "logo": "seriea.png"
          }
        }), 200);
      });

      final edition = await ChampionshipService.getEditionById(55);

      expect(edition.id, 55);
      expect(edition.championship.name, "Serie A");
    });
  });
}
