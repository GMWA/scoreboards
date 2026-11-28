import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/features/scores/match_groups.dart';
import 'package:scoreboards/shared/models/match.dart';

import '../../helpers/fixtures.dart';

void main() {
  final cup = editionJson(id: 1, slug: 'cup', label: 'Cup');
  final league = editionJson(id: 2, slug: 'league', label: 'League');
  final matches = [
    MatchBase.fromJson(matchJson(1, edition: cup, status: 'completed')),
    MatchBase.fromJson(matchJson(2, edition: league, status: 'planned')),
    MatchBase.fromJson(matchJson(3, edition: cup, status: 'ongoing')),
    MatchBase.fromJson(matchJson(4, edition: league, status: 'ongoing')),
  ];

  // [label, match ids] per group.
  List<List<Object>> shape(List<MatchGroup> groups) => [
        for (final g in groups)
          [
            g.label,
            [for (final m in g.matches) m.id]
          ]
      ];

  test('groups by competition, live matches first', () {
    expect(shape(groupMatches(matches, ScoreFilter.all)), [
      [
        'Cup',
        [3, 1]
      ],
      [
        'League',
        [4, 2]
      ],
    ]);
  });

  test('the filters keep live, upcoming or finished matches', () {
    expect(shape(groupMatches(matches, ScoreFilter.live)), [
      [
        'Cup',
        [3]
      ],
      [
        'League',
        [4]
      ],
    ]);
    expect(shape(groupMatches(matches, ScoreFilter.upcoming)), [
      [
        'League',
        [2]
      ],
    ]);
    expect(shape(groupMatches(matches, ScoreFilter.finished)), [
      [
        'Cup',
        [1]
      ],
    ]);
  });

  test('a group links to its competition', () {
    final group = groupMatches(matches, ScoreFilter.all).first;
    expect(group.slug, 'cup');
    expect(group.editionId, 1);
  });
}
