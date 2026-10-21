import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/widgets/matchs/match_header.dart';
import 'package:scoreboards/widgets/ui/match_card.dart';

// Worst cases taken from production data: the longest stadium (32 chars),
// the longest team names, and a two-digit score with a penalty shootout.
MatchBase _match({
  String home = 'Ngoketunjia Foncha United FC',
  String away = 'Aigle Royal de la Menoua',
  String location = 'Mankon Municipal Stadium Bamenda',
  String round = '22',
  int homeGoals = 12,
  int awayGoals = 10,
}) =>
    MatchBase.fromJson({
      'id': 1,
      'slug': 's',
      'date': '2026-08-12T17:00:00Z',
      'status': 'completed',
      'round': round,
      'location': location,
      'edition': {
        'id': 1,
        'slug': 'e',
        'championship': {'id': 1, 'name': 'C', 'country': ''},
        'year': '2026',
        'start_date': '2026-01-01',
        'end_date': '2026-12-31',
        'is_current': true,
      },
      'home_team': {'id': 1, 'slug': 'h', 'name': home},
      'away_team': {'id': 2, 'slug': 'a', 'name': away},
      'score_final_home': homeGoals,
      'score_final_away': awayGoals,
      'went_to_penalties': true,
      'score_pso_home': 10,
      'score_pso_away': 11,
    });

void main() {
  final widgets = <String, Widget Function(MatchBase)>{
    'MatchHeader': (m) => MatchHeader(match: m),
    'MatchCard': (m) => MatchCard(match: m),
    'MatchScoreBar': (m) => MatchScoreBar(match: m),
  };

  for (final width in [360.0, 320.0]) {
    for (final scale in [1.0, 1.3, 1.5, 2.0]) {
      for (final entry in widgets.entries) {
        testWidgets(
            '${entry.key} survives worst-case data at ${width.toInt()}dp, '
            '${scale}x text', (tester) async {
          tester.view.physicalSize = Size(width * 3, 780 * 3);
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                  size: Size(width, 780), textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: SingleChildScrollView(child: entry.value(_match())),
              ),
            ),
          ));
          await tester.pump();

          final error = tester.takeException();
          expect(error, isNull, reason: error?.toString().split('\n').first);
        });
      }
    }
  }
}
