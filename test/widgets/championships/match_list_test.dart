import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/services/matchs.dart';
import 'package:scoreboards/widgets/championships/match_list.dart';

Map<String, dynamic> _match(int id) => {
      'id': id,
      'slug': 'match-$id',
      'date': '2026-08-12T17:00:00Z',
      'status': 'completed',
      'round': 'R1',
      'edition': {
        'id': 1,
        'slug': 'e',
        'championship': {'id': 1, 'name': 'C', 'country': ''},
        'year': '2026',
        'start_date': '2026-01-01',
        'end_date': '2026-12-31',
        'is_current': true,
      },
      'home_team': {'id': 1, 'slug': 'h', 'name': 'Home $id'},
      'away_team': {'id': 2, 'slug': 'a', 'name': 'Away $id'},
      'score_final_home': 1,
      'score_final_away': 0,
    };

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  testWidgets('shows the first page, then loads the next on scroll',
      (tester) async {
    urls['MATCHS']!['BY_EDITION'] = 'https://fake.dev/edition/#editionId';
    final requested = <String>[];

    MatchService.client = MockClient((request) async {
      requested.add(request.url.toString());
      final secondPage = request.url.queryParameters['page'] == '2';
      return Response(
          jsonEncode({
            'count': 25,
            'next': secondPage ? null : 'https://fake.dev/edition/1?page=2&page_size=20',
            'previous': null,
            'results': secondPage
                ? [for (var i = 21; i <= 25; i++) _match(i)]
                : [for (var i = 1; i <= 20; i++) _match(i)],
          }),
          200);
    });

    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MatchList(editionId: 1))));
    await tester.pumpAndSettle();

    expect(requested, ['https://fake.dev/edition/1?page_size=20']);
    expect(find.text('Home 1'), findsOneWidget);

    await tester.dragUntilVisible(
        find.text('Home 25'), find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(requested.length, 2);
    expect(find.text('Home 25'), findsOneWidget);
  });
}
