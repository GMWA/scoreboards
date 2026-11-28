import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/features/competitions/widgets/standings_table.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/harness.dart';

Map<String, dynamic> _standing(
        int id, String team, String? group, int points) =>
    {
      'id': id,
      'participation': {
        'id': id,
        'team': {'id': id, 'slug': 't$id', 'name': team},
        'group': group,
      },
      'points': points,
      'matches_played': 3,
      'wins': 0,
      'draws': 0,
      'losses': 0,
      'goals_for': 0,
      'goals_against': 0,
    };

const _rules = [
  {
    'id': 1,
    'edition': 1,
    'phase': 'group',
    'from_position': 1,
    'to_position': 2,
    'outcome': 'Quarter-finals',
    'color': 'green',
    'priority': 0,
  },
];

void main() {
  late List<Map<String, dynamic>> standings;

  Future<void> pump(WidgetTester tester) => pumpScreen(
        tester,
        const Scaffold(body: StandingsTable(editionId: 1)),
        api: routes({
          '/edition/1/standings/': standings,
          '/edition/1/rules/': _rules,
        }),
      );

  testWidgets('cup standings are split into one table per group',
      (tester) async {
    // Group B's leader has the most points overall, so it comes first in the
    // API's points-sorted order; groups should still be listed A, B.
    standings = [
      _standing(2, 'B1', 'Group B', 9),
      _standing(1, 'A1', 'Group A', 7),
      _standing(3, 'A2', 'Group A', 4),
      _standing(4, 'B2', 'Group B', 5),
    ];

    await pump(tester);

    final groupA = tester.getTopLeft(find.text('GROUP A')).dy;
    final groupB = tester.getTopLeft(find.text('GROUP B')).dy;
    expect(groupA, lessThan(groupB));
    expect(find.byType(DataTable), findsNWidgets(2));
    // Positions restart in each group.
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('2'), findsNWidgets(2));
    expect(find.text('Quarter-finals'), findsOneWidget);
  });

  testWidgets('all columns fit a 360dp-wide phone without scrolling',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3; // 360 x 780 dp
    addTearDown(tester.view.reset);
    standings = [
      _standing(1, 'Afrique du Sud W', 'Group A', 9),
      _standing(2, "Cote d'Ivoire W", 'Group A', 4),
    ];

    await pump(tester);

    expect(
        tester.getTopRight(find.text('GD').first).dx, lessThanOrEqualTo(360));
  });

  testWidgets('league standings stay in a single table', (tester) async {
    standings = [
      _standing(1, 'T1', null, 9),
      _standing(2, 'T2', null, 4),
    ];

    await pump(tester);

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.textContaining('GROUP'), findsNothing);
  });

  test('ruleColor maps names and hex values', () {
    expect(ruleColor('green'), AppColors.mint);
    expect(ruleColor('Red'), AppColors.coral);
    expect(ruleColor('#112233'), const Color(0xFF112233));
    expect(ruleColor('not-a-colour'), AppColors.textSecondary);
  });
}
