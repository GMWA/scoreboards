import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scoreboards/services/matchs.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/models/match.dart';

Map<String, dynamic> _matchJson(int id, DateTime localKickoff) => {
      "id": id,
      "slug": "match-$id",
      "date": localKickoff.toUtc().toIso8601String(),
      "location": "test location",
      "round": "1",
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
        "year": "2025",
        "start_date": "2025-01-01",
        "end_date": "2025-12-31",
        "is_current": true
      },
      "home_team": {"id": 1, "slug": "team-a", "name": "Team A"},
      "away_team": {"id": 2, "slug": "team-b", "name": "Team B"},
      "score_final_home": 0,
      "score_final_away": 0,
    };

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });
  group("MatchService Tests", () {
    setUp(() {
      // Ensure MATCHS map exists
      urls['MATCHS'] ??= {};
    });

    test("getMatchsByDay returns matches on success", () async {
      final testDate = DateTime(2025, 1, 20);
      urls['MATCHS']!['BY_DAY'] = "https://fake.dev/matches/day/#date";

      MatchService.client = MockClient((request) async {
        expect(request.url.toString(),
            matches(r'^https://fake\.dev/matches/day/\d{2}-\d{2}-\d{4}$'));
        return Response(
            jsonEncode([
              _matchJson(1, DateTime(2025, 1, 20, 15)),
              _matchJson(2, DateTime(2025, 1, 20, 18)),
            ]),
            200);
      });

      final result = await MatchService.getMatchsByDay(testDate);

      expect(result, isA<List<MatchBase>>());
      expect(result.map((m) => m.id), [1, 2]);
    });

    test("getMatchsByDay keeps only matches on the local calendar day",
        () async {
      urls['MATCHS']!['BY_DAY'] = "https://fake.dev/matches/day/#date";

      // The backend buckets by UTC day, so a request can return matches from
      // either side of the local day; only the local day's should remain.
      MatchService.client = MockClient((request) async {
        return Response(
            jsonEncode([
              _matchJson(1, DateTime(2025, 1, 19, 23, 30)),
              _matchJson(2, DateTime(2025, 1, 20, 0, 30)),
              _matchJson(3, DateTime(2025, 1, 21, 0, 10)),
            ]),
            200);
      });

      final matches = await MatchService.getMatchsByDay(DateTime(2025, 1, 20));

      expect(matches.map((m) => m.id), [2]);
    });

    test("getMatchByDay throws on error", () async {
      urls['MATCHS']!['BY_DAY'] = "https://fake.dev/day/#date";

      MatchService.client = MockClient((request) async {
        return Response("Error", 500);
      });

      expect(
        () async => await MatchService.getMatchsByDay(DateTime.now()),
        throwsA(isA<Exception>()),
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
                "score_ht_home": 3,
                "score_ht_away": 0,
                "score_90_home": 0,
                "score_90_away": 0,
                "score_final_home": 0,
                "score_final_away": 0,
                "score_pso_home": 0,
                "score_pso_away": 0,
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
        throwsA(isA<Exception>()),
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
                "score_ht_home": 3,
                "score_ht_away": 0,
                "score_90_home": 0,
                "score_90_away": 0,
                "score_final_home": 0,
                "score_final_away": 0,
                "score_pso_home": 0,
                "score_pso_away": 0,
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
                "score_ht_home": 3,
                "score_ht_away": 0,
                "score_90_home": 0,
                "score_90_away": 0,
                "score_final_home": 0,
                "score_final_away": 0,
                "score_pso_home": 0,
                "score_pso_away": 0,
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
        expect(request.url.toString(), "https://fake.dev/edition/7?page_size=100");

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
                "score_ht_home": 3,
                "score_ht_away": 0,
                "score_90_home": 0,
                "score_90_away": 0,
                "score_final_home": 0,
                "score_final_away": 0,
                "score_pso_home": 0,
                "score_pso_away": 0,
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
