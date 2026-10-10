import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/screens/championships/championship_details.dart';
import 'package:scoreboards/services/championship.dart';
import 'package:scoreboards/services/matchs.dart';
import 'package:scoreboards/services/player.dart';
import 'package:scoreboards/services/teams.dart';

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
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  Future<void> pumpEdition(WidgetTester tester, String competitionType) async {
    urls['EDITIONS']!['BY_SLUG'] = 'https://fake.dev/editions/slug/';
    ChampionshipService.client = MockClient((request) async {
      final body = request.url.path.startsWith('/editions/slug/')
          ? _edition(competitionType)
          : <dynamic>[];
      return Response(jsonEncode(body), 200);
    });
    final empty = MockClient((_) async => Response('[]', 200));
    MatchService.client = empty;
    TeamService.client = empty;
    PlayerService.client = empty;

    await tester.pumpWidget(
        const MaterialApp(home: ChampionshipDetails(slug: 'edition')));
    await tester.pumpAndSettle();
  }

  List<String> tabLabels(WidgetTester tester) => tester
      .widgetList<Tab>(find.byType(Tab))
      .map((tab) => tab.text!)
      .toList();

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
