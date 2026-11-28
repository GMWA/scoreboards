import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/features/competitions/competition_screen.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/harness.dart';

Map<String, dynamic> _edition(String competitionType) => {
      'id': 1,
      'slug': 'edition',
      'year': '2026',
      'label': 'Some Edition 2026',
      'start_date': '2026-01-01',
      'end_date': '2026-12-31',
      'is_current': true,
      'competition_type': competitionType,
      'championship': {'id': 1, 'name': 'Some', 'country': ''},
    };

void main() {
  Future<void> pumpEdition(WidgetTester tester, String competitionType) async {
    // A fresh screen for each type.
    await tester.pumpWidget(const SizedBox());
    await pumpScreen(
      tester,
      const CompetitionScreen(slug: 'edition'),
      api: (o) async => o.uri.path.endsWith('/editions/slug/edition/')
          ? jsonBody(200, _edition(competitionType))
          : jsonBody(200, []),
    );
  }

  List<String> tabLabels(WidgetTester tester) =>
      tester.widgetList<Tab>(find.byType(Tab)).map((tab) => tab.text!).toList();

  testWidgets('friendlies show only Matches and Teams, opening on Matches',
      (tester) async {
    await pumpEdition(tester, 'friendly');

    expect(tabLabels(tester), ['Matches', 'Teams']);
    expect(find.text('No matches available'), findsOneWidget);
  });

  testWidgets('leagues and cups keep standings and player stats',
      (tester) async {
    for (final type in ['league', 'cup']) {
      await pumpEdition(tester, type);
      expect(tabLabels(tester), ['Standings', 'Teams', 'Matches', 'P. Stats'],
          reason: type);
    }
  });
}
