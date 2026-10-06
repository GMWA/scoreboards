import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/helpers/utils.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/models/timeline_event.dart';

Map<String, dynamic> _goal(int id, int minute, String type, String status,
        String scorer) =>
    {
      'id': id,
      'match': 1,
      'team': {'id': 1, 'slug': 'home', 'name': 'Home'},
      'minute': minute,
      'goal_type': type,
      'status': status,
      'is_penalty': type == 'penalty',
      'scorer': {'id': id, 'slug': scorer, 'firstname': '', 'lastname': scorer},
    };

void main() {
  group('appRouteForLink', () {
    final website = Uri.parse('https://scoreboards.cm');
    String? route(String link) => appRouteForLink(Uri.parse(link), website);

    test('maps website paths used in articles to app routes', () {
      expect(route('/teams/cameroun-w'), '/teams/cameroun-w');
      expect(route('/players/temwa-chawinga'), '/players/temwa-chawinga');
      expect(route('/leagues/wafcon-2026'), '/championships/wafcon-2026');
      expect(route('/matchs/a-vs-b'), '/matchs/details/a-vs-b');
      expect(route('/blogs/some-article'), '/blogs/some-article');
    });

    test('maps absolute links to the website the same way', () {
      expect(route('https://scoreboards.cm/teams/cameroun-w'),
          '/teams/cameroun-w');
    });

    test('returns null for pages the app does not have and other sites', () {
      expect(route('/predictions'), isNull);
      expect(route('/teams'), isNull);
      expect(route('https://example.com/teams/cameroun-w'), isNull);
    });
  });

  test('buildTimelineEvents shows only valid in-play goals', () {
    // Shaped like staging's 2026-maroc-w-vs-cameroun-w-sf: 0-0, decided on
    // penalties, with a missed in-play penalty.
    final match = Match.fromJson({
      'id': 1,
      'slug': 'm',
      'date': '2026-08-12T20:00:00Z',
      'status': 'completed',
      'edition': {
        'id': 1,
        'slug': 'e',
        'championship': {'id': 1, 'name': 'C', 'country': ''},
        'year': '2026',
        'start_date': '2026-07-26',
        'end_date': '2026-08-16',
        'is_current': true,
      },
      'home_team': {'id': 1, 'slug': 'home', 'name': 'Home'},
      'away_team': {'id': 2, 'slug': 'away', 'name': 'Away'},
      'score_final_home': 1,
      'score_final_away': 0,
      'goals': [
        _goal(1, 30, 'normal', 'valid', 'Scorer'),
        _goal(2, 55, 'normal', 'cancelled', 'Offside'),
        _goal(3, 70, 'normal', 'pending', 'UnderReview'),
        _goal(4, 118, 'penalty', 'missed', 'MissedPen'),
        _goal(5, 120, 'pso', 'valid', 'ShootoutScored'),
        _goal(6, 120, 'pso', 'missed', 'ShootoutMissed'),
      ],
    });

    final goals = buildTimelineEvents(match)
        .where((e) => e.type != TimelineEventType.substitution);

    expect(goals.map((e) => e.title.trim()), ['Scorer']);
  });
}
