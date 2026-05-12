import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:intl/intl.dart';
import 'package:scoreboards/services/matchs.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/models/match.dart';

void main() {
  group("MatchService Tests", () {
    setUp(() {
      // Ensure MATCHS map exists
      urls['MATCHS'] ??= {};
    });

    test("getMatchsByDay returns matches on success", () async {
      final testDate = DateTime(2025, 1, 20);
      final formatted = DateFormat('dd-MM-yyyy').format(testDate);

      urls['MATCHS']!['BY_DAY'] = "https://fake.dev/matches/day/#date";

      MatchService.client = MockClient((request) async {
        expect(
            request.url.toString(), "https://fake.dev/matches/day/$formatted");

        return Response(
            jsonEncode([
              {
                "id": 1,
                "slug": "team-a-vs-team-b-8",
                "date": "2022-01-01",
                "location": "test location 1",
                "round": "2",
                "type": "club",
                "status": "planned",
                "edition": {
                  "id": 1,
                  "slug": "test-championship-2024",
                  "championship": {
                    "id": 1,
                    "name": "Test Championship",
                    "country": "test Country"
                  },
                  "label": "Test Label",
                  "year": "2021",
                  "start_date": "2021-08-01",
                  "end_date": "2022-07-31",
                  "is_current": true
                },
                "home_team": {"id": 1, "slug": "team-a", "name": "Team A"},
                "away_team": {"id": 2, "slug": "team-b", "name": "Team B"},
                "cards": [],
                "goals": [],
                "substitutions": [],
                'lineups': []
              },
              {
                "id": 2,
                "slug": "team-c-vs-team-d-4",
                "date": "2022-01-01",
                "location": "test location 1",
                "round": "2",
                "type": "club",
                "status": "planned",
                "edition": {
                  "id": 1,
                  "slug": "test-championship-2022",
                  "championship": {
                    "id": 1,
                    "name": "Test Championship",
                    "country": "test Country"
                  },
                  "label": "Test Label",
                  "year": "2022",
                  "start_date": "2021-08-01",
                  "end_date": "2022-07-31",
                  "is_current": true
                },
                "home_team": {"id": 3, "slug": "team-c", "name": "Team C"},
                "away_team": {"id": 4, "slug": "team-d", "name": "Team D"},
                "cards": [],
                "goals": [],
                "substitutions": [],
                'lineups': []
              }
            ]),
            200);
      });

      final matches = await MatchService.getMatchsByDay(testDate);

      expect(matches, isA<List<MatchBase>>());
      expect(matches.length, 2);
    });

    test("getMatchByDay throws on error", () async {
      urls['MATCHS']!['BY_DAY'] = "https://fake.dev/day/#date";

      MatchService.client = MockClient((request) async {
        return Response("Error", 500);
      });

      expect(
        () async => await MatchService.getMatchsByDay(DateTime.now()),
        throwsA(isA<String>()),
      );
    });

    test("getMatchById returns a match when successful", () async {
      urls['MATCHS']!['BY_ID'] = "https://fake.dev/match/10";

      MatchService.client = MockClient((request) async {
        expect(request.url.toString(), "https://fake.dev/match/10");

        return Response(
            jsonEncode(
              {
                "id": 10,
                "slug": "team-a-vs-team-b-2",
                "date": "2022-01-01",
                "location": "test location 1",
                "round": "2",
                "type": "club",
                "status": "planned",
                "edition": {
                  "id": 1,
                  "slug": "test-champioship-2023",
                  "championship": {
                    "id": 1,
                    "name": "Test Championship",
                    "country": "test Country"
                  },
                  "label": "Test Label",
                  "year": "2021",
                  "start_date": "2021-08-01",
                  "end_date": "2022-07-31",
                  "is_current": true
                },
                "home_team": {"id": 1, "slug": "team-a", "name": "Team A"},
                "away_team": {"id": 2, "slug": "team-b", "name": "Team B"},
                "cards": [],
                "goals": [],
                "substitutions": [],
                'lineups': []
              },
            ),
            200);
      });

      final match = await MatchService.getMatchById(10);

      expect(match, isA<Match>());
      expect(match.id, 10);
    });

    test("getMatchById throws on failure", () async {
      urls['MATCHS']!['BY_DAY'] = "https://fake.dev/match/";

      MatchService.client = MockClient((request) async {
        return Response("Error", 404);
      });

      expect(
        () async => await MatchService.getMatchById(1),
        throwsA(isA<String>()),
      );
    });

    test("getLiveMatches returns list on success", () async {
      urls['MATCHS']!['LIVE'] = "https://fake.dev/live";

      MatchService.client = MockClient((request) async {
        return Response(
            jsonEncode([
              {
                "id": 1,
                "slug": "team-a-vs-team-b-6",
                "date": "2022-01-01",
                "location": "test location 1",
                "round": "2",
                "type": "club",
                "status": "planned",
                "edition": {
                  "id": 1,
                  "slug": "test-championship-2021",
                  "championship": {
                    "id": 1,
                    "name": "Test Championship",
                    "country": "test Country"
                  },
                  "label": "Test Label",
                  "year": "2021",
                  "start_date": "2021-08-01",
                  "end_date": "2022-07-31",
                  "is_current": true
                },
                "home_team": {"id": 1, "slug": "team-a", "name": "Team A"},
                "away_team": {"id": 2, "slug": "team-b", "name": "Team B"},
                "cards": [],
                "goals": [],
                "substitutions": [],
                'lineups': []
              },
            ]),
            200);
      });

      final matches = await MatchService.getLiveMatches();

      expect(matches, isA<List<MatchBase>>());
      expect(matches.length, 1);
    });

    test("getMatchsByChampionshipEdition returns list", () async {
      urls['MATCHS']!['BY_CHAMPIONSHIP_EDITION'] =
          "https://fake.dev/champ/#championshipId/edition/#editionId";

      MatchService.client = MockClient((request) async {
        expect(request.url.toString(), "https://fake.dev/champ/5/edition/2");

        return Response(
            jsonEncode([
              {
                "id": 1,
                "slug": "team-a-vs-team-b",
                "date": "2022-01-01",
                "location": "test location 1",
                "round": "2",
                "type": "club",
                "status": "planned",
                "edition": {
                  "id": 1,
                  "slug": "test-championship-2022",
                  "championship": {
                    "id": 1,
                    "name": "Test Championship",
                    "country": "test Country"
                  },
                  "label": "Test Label",
                  "year": "2021",
                  "start_date": "2021-08-01",
                  "end_date": "2022-07-31",
                  "is_current": true
                },
                "home_team": {"id": 1, "slug": "team-a", "name": "Team A"},
                "away_team": {"id": 2, "slug": "team-b", "name": "Team B"},
                "cards": [],
                "goals": [],
                "substitutions": [],
                'lineups': []
              },
            ]),
            200);
      });

      final matches = await MatchService.getMatchsByChampionshipEdition(5, 2);

      expect(matches.length, 1);
    });

    test("getMatchsByChampionshipEdition throws on error", () async {
      urls['MATCHS']!['BY_CHAMPIONSHIP_EDITION'] =
          "https://fake.dev/champ/#championshipId/edition/#editionId";

      MatchService.client = MockClient((request) async {
        return Response("Error", 400);
      });

      expect(
        () async => await MatchService.getMatchsByChampionshipEdition(1, 1),
        throwsA(isA<Exception>()),
      );
    });

    test("getMatchsByEdition returns list", () async {
      urls['MATCHS']!['BY_EDITION'] = "https://fake.dev/edition/#editionId";

      MatchService.client = MockClient((request) async {
        expect(request.url.toString(), "https://fake.dev/edition/7");

        return Response(
            jsonEncode([
              {
                "id": 1,
                "slug": "team-a-vs-team-b-3",
                "date": "2022-01-01",
                "location": "test location 1",
                "round": "2",
                "type": "club",
                "status": "planned",
                "edition": {
                  "id": 1,
                  "slug": "test-championship-2025",
                  "championship": {
                    "id": 1,
                    "name": "Test Championship",
                    "country": "test Country"
                  },
                  "label": "Test Label",
                  "year": "2021",
                  "start_date": "2021-08-01",
                  "end_date": "2022-07-31",
                  "is_current": true
                },
                "home_team": {"id": 1, "slug": "team-a", "name": "Team A"},
                "away_team": {"id": 2, "slug": "team-b", "name": "Team B"},
                "cards": [],
                "goals": [],
                "substitutions": [],
                'lineups': []
              },
            ]),
            200);
      });

      final matches = await MatchService.getMatchsByEdition(7);

      expect(matches.length, 1);
    });

    test("getMatchsByEdition throws on error", () async {
      urls['MATCHS']!['BY_EDITION'] = "https://fake.dev/edition/#editionId";

      MatchService.client = MockClient((request) async {
        return Response("Error", 500);
      });

      expect(
        () async => await MatchService.getMatchsByEdition(7),
        throwsA(isA<Exception>()),
      );
    });
  });
}
