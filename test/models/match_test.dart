import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/enums/matchs.dart';

void main() {
  group('Match Models', () {
    final Map<String, dynamic> matchJson = {
      'id': 1,
      'slug': 'team-a-vs-team-b-4',
      'date': '2025-01-15T15:00:00Z',
      'type': 'League',
      'location': 'Stadium A',
      'round': 'Matchday 3',
      'status': 'completed', // Using backend-style slug
      'edition': {
        'id': 10,
        'slug': 'uefa-champions-league-2025-*+',
        'year': '2025',
        'label': 'Season 2025',
        'championship': {
          'id': 1,
          'name': 'UEFA Champions League',
          'country': 'Europe',
          'logo': 'ucl.png',
        },
        'start_date': '2024-08-01',
        'end_date': '2025-05-15',
        'is_current': true,
      },
      'home_team': {'id': 100, 'slug': 'team-a', 'name': 'Team A', 'logo': 'a.png'},
      'away_team': {'id': 200, 'slug': 'team-b', 'name': 'Team B', 'logo': 'b.png'},
      // Scores coming directly from backend
      'score_final_home': 1,
      'score_final_away': 2,
      'score_ht_home': 0,
      'score_ht_away': 1,
      'went_to_extra_time': false,
      'went_to_penalties': false,
      'goals': [
        {
          'id': 1,
          'minute': 10,
          'stoppage_minute': 0,
          'match': 1,
          'team': {'id': 100, 'slug': 'team-a', 'name': 'Team A'},
          'scorer': {'id': 501, 'slug': 'john-doe', 'firstname': 'John', 'lastname': 'Doe'},
          'is_penalty': false,
          'is_csc': false,
          'status': 'valid',
          'goal_type': 'normal'
        }
      ],
      'cards': [],
      'substitutions': [],
      'lineups': []
    };

    test('MatchBase.fromJson should parse lightweight data correctly', () {
      final matchBase = MatchBase.fromJson(matchJson);

      expect(matchBase.id, 1);
      expect(matchBase.slug, 'team-a-vs-team-b-4');
      expect(
          matchBase.status, MatchStatus.completed); // Testing Enum conversion
      expect(matchBase.scoreFinalHome, 1);
      expect(matchBase.scoreFinalAway, 2);
      expect(matchBase.scoreHTHome, 0);
      expect(matchBase.homeTeam.name, 'Team A');
    });

    test('MatchDetailed.fromJson should parse events correctly', () {
      // In your project, MatchDetailed might be named 'Match'
      final matchDetailed = Match.fromJson(matchJson);

      expect(matchDetailed.id, 1);
      expect(matchDetailed.goals.length, 1);
      expect(matchDetailed.goals.first.minute, 10);
      expect(matchDetailed.scoreFinalHome, 1);
    });

    test('MatchStatus enum should handle unknown strings gracefully', () {
      final jsonWithUnknownStatus = {...matchJson, 'status': 'something_new'};
      final match = MatchBase.fromJson(jsonWithUnknownStatus);

      // Testing the 'orElse' logic in your Enum
      expect(match.status, MatchStatus.planned);
    });

    test('only played or in-progress statuses have a meaningful score', () {
      expect(
        MatchStatus.values.where((s) => s.hasScore),
        [
          MatchStatus.ongoing,
          MatchStatus.completed,
          MatchStatus.awarded,
          MatchStatus.abandoned,
        ],
      );
    });

    test('isLiveOrDue: live, or kicked off recently but not yet started', () {
      MatchBase at(String status, Duration sinceKickoff) => MatchBase.fromJson({
            ...matchJson,
            'status': status,
            'date': DateTime.now().subtract(sinceKickoff).toUtc().toIso8601String(),
          });

      expect(at('ongoing', const Duration(minutes: 30)).isLiveOrDue, isTrue);
      expect(at('scheduled', const Duration(minutes: 5)).isLiveOrDue, isTrue);
      expect(at('scheduled', const Duration(minutes: -60)).isLiveOrDue, isFalse,
          reason: 'not kicked off yet');
      expect(at('planned', const Duration(days: 2)).isLiveOrDue, isFalse,
          reason: 'stale data, not about to change');
      expect(at('completed', const Duration(minutes: 30)).isLiveOrDue, isFalse);
    });

    test('MatchStatus parses every status the backend sends', () {
      // Mirrors matches.models.MatchStatus in championshiptracker/backend.
      const backendStatuses = {
        'planned': MatchStatus.planned,
        'scheduled': MatchStatus.scheduled,
        'ongoing': MatchStatus.ongoing,
        'completed': MatchStatus.completed,
        'awarded': MatchStatus.awarded,
        'postponed': MatchStatus.postponed,
        'cancelled': MatchStatus.cancelled,
        'abandoned': MatchStatus.abandoned,
      };

      backendStatuses.forEach((value, expected) {
        final match = MatchBase.fromJson({...matchJson, 'status': value});
        expect(match.status, expected, reason: 'status "$value"');
      });
    });
  });
}
