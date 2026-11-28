import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/features/competitions/widgets/edition_matches.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/harness.dart';

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
  testWidgets('shows the first page, then loads the next on scroll',
      (tester) async {
    final requested = <Map<String, dynamic>>[];

    await pumpScreen(
      tester,
      const Scaffold(body: EditionMatches(editionId: 1)),
      api: (o) async {
        expect(o.uri.path, '/api/v1/matchs/edition/1/');
        requested.add(o.queryParameters);
        final secondPage = o.queryParameters['page'] == 2;
        return jsonBody(200, {
          'count': 25,
          'next': secondPage ? null : 'https://fake.dev/edition/1?page=2',
          'results': secondPage
              ? [for (var i = 21; i <= 25; i++) _match(i)]
              : [for (var i = 1; i <= 20; i++) _match(i)],
        });
      },
    );

    expect(requested, [
      {'page_size': 20, 'page': 1},
    ]);
    expect(find.text('Home 1'), findsOneWidget);

    await tester.dragUntilVisible(
        find.text('Home 25'), find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(requested.length, 2);
    expect(find.text('Home 25'), findsOneWidget);
  });
}
