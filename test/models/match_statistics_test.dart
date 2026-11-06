import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/models/match_statistics.dart';

Map<String, dynamic> _match([Map<String, dynamic> extra = const {}]) => {
      'id': 1,
      'slug': 'a-vs-b',
      'date': '2026-11-01T15:00:00Z',
      'status': 'completed',
      'edition': {
        'id': 1,
        'slug': 'e',
        'championship': {'id': 1, 'name': 'C', 'country': ''},
        'year': '2026',
        'start_date': '2026-01-01',
        'end_date': '2026-12-31',
        'is_current': true,
      },
      'home_team': {'id': 1, 'slug': 'a', 'name': 'A'},
      'away_team': {'id': 2, 'slug': 'b', 'name': 'B'},
      'score_final_home': 1,
      'score_final_away': 0,
      ...extra,
    };

void main() {
  test('parses the statistics, keeping unknown stats null rather than 0', () {
    final match = Match.fromJson(_match({
      'statistics': {
        'home': {
          'possession': 55,
          'shots': 13,
          'shots_on_target': 6,
          'corners': 0,
          'fouls': null,
          'offsides': null,
          'saves': null,
          'yellow_cards': 2,
          'red_cards': 0,
        },
        'away': {
          'possession': 45,
          'shots': 7,
          'shots_on_target': 2,
          'corners': 3,
          'fouls': 14,
          'offsides': null,
          'saves': null,
          'yellow_cards': 1,
          'red_cards': 1,
        },
        'source': 'data_file',
        'source_note': 'Diffusion TV',
      },
    }));

    final stats = match.statistics!;
    expect(stats.home.possession, 55);
    expect(stats.home.shotsOnTarget, 6);
    expect(stats.home.corners, 0);
    expect(stats.home.fouls, isNull);
    expect(stats.away.fouls, 14);
    expect(stats.home.yellowCards, 2);
    expect(stats.away.redCards, 1);
    expect(stats.source, 'data_file');
    expect(stats.sourceNote, 'Diffusion TV');
  });

  test('a match without statistics, or from an older API, has none', () {
    expect(Match.fromJson(_match({'statistics': null})).statistics, isNull);
    expect(Match.fromJson(_match()).statistics, isNull);
  });

  test('missing team fields parse as unknown', () {
    final stats = TeamMatchStats.fromJson({});
    expect(stats.shots, isNull);
    expect(stats.yellowCards, 0);
  });
}
