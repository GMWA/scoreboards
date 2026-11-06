import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/match_statistics.dart';
import 'package:scoreboards/widgets/matchs/match_statistics_tab.dart';

Future<void> _pump(WidgetTester tester, MatchStatistics stats,
    {String home = 'Home FC', String away = 'Away FC'}) {
  return tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body:
          MatchStatisticsTab(statistics: stats, homeName: home, awayName: away),
    ),
  ));
}

void main() {
  testWidgets('shows known stats, "–" for a one-sided unknown, and the source',
      (tester) async {
    await _pump(
      tester,
      const MatchStatistics(
        home: TeamMatchStats(
            possession: 55, shots: 13, fouls: null, yellowCards: 2),
        away: TeamMatchStats(possession: 45, shots: 7, fouls: 14, redCards: 1),
        sourceNote: 'Diffusion TV',
      ),
    );

    expect(find.text('Possession'), findsOneWidget);
    expect(find.text('55%'), findsOneWidget);
    expect(find.text('45%'), findsOneWidget);
    expect(find.text('Fouls'), findsOneWidget);
    expect(find.text('–'), findsOneWidget, reason: 'home fouls unknown');
    expect(find.text('14'), findsOneWidget);
    expect(find.text('Source: Diffusion TV'), findsOneWidget);
  });

  testWidgets('leaves out a stat unknown for both teams', (tester) async {
    await _pump(
      tester,
      const MatchStatistics(
        home: TeamMatchStats(shots: 3),
        away: TeamMatchStats(shots: 3),
      ),
    );

    expect(find.text('Shots'), findsOneWidget);
    expect(find.text('Possession'), findsNothing);
    expect(find.text('Corners'), findsNothing);
    expect(find.text('Saves'), findsNothing);
    // Cards are always known (counted from the match's cards).
    expect(find.text('Yellow cards'), findsOneWidget);
    expect(find.textContaining('Source'), findsNothing);
  });

  testWidgets('fits a 320dp screen with the longest team names and values',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      const MatchStatistics(
        home: TeamMatchStats(
            possession: 100,
            shots: 999,
            shotsOnTarget: 999,
            corners: 999,
            fouls: 999,
            offsides: 999,
            saves: 999,
            yellowCards: 99,
            redCards: 9),
        away: TeamMatchStats(
            possession: 0,
            shots: 0,
            shotsOnTarget: 0,
            corners: 0,
            fouls: 0,
            offsides: 0,
            saves: 0),
        sourceNote: 'A long source note copied from a television broadcast',
      ),
      home: 'Ngoketunjia Foncha United FC',
      away: 'Aigle Royal de la Menoua',
    );

    expect(tester.takeException(), isNull);
  });
}
