import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/features/match/match_screen.dart';
import 'package:scoreboards/features/match/widgets/match_header.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/harness.dart';

const _home = {'id': 1, 'slug': 'home', 'name': 'Home FC'};
const _away = {'id': 2, 'slug': 'away', 'name': 'Away FC'};

Map<String, dynamic> _player(int id, String lastname) => {
      'id': id,
      'slug': 'p$id',
      'firstname': 'Test',
      'lastname': lastname,
      'jersey_number': id,
    };

Map<String, dynamic> _lineup(
        int id, Map team, String lastname, bool starting) =>
    {
      'id': id,
      'match': 1,
      'team': team,
      'player': _player(id, lastname),
      'minutes_played': starting ? 90 : 0,
      'is_starting': starting,
      'is_captain': false,
      'position': 'midfielder',
    };

final _matchJson = {
  'id': 1,
  'slug': 'home-vs-away',
  'date': '2026-10-04T18:00:00Z',
  'status': 'completed',
  'round': 'R1',
  'location': 'Stadium',
  'edition': {
    'id': 1,
    'slug': 'cup-2026',
    'championship': {'id': 1, 'name': 'Cup', 'country': ''},
    'year': '2026',
    'label': 'Cup 2026',
    'start_date': '2026-01-01',
    'end_date': '2026-12-31',
    'is_current': true,
  },
  'home_team': _home,
  'away_team': _away,
  'score_final_home': 0,
  'score_final_away': 0,
  'goals': [],
  'substitutions': [],
  'cards': [
    {
      'id': 1,
      'card_type': 'yellow',
      'minute': 70,
      'team': _home,
      'player': _player(10, 'Booked'),
      'is_second_yellow': true,
    },
  ],
  'lineups': [
    _lineup(10, _home, 'HomeStarter', true),
    _lineup(11, _home, 'HomeBench', false),
    _lineup(20, _away, 'AwayStarter', true),
  ],
};

final _motmJson = {
  'window': {
    'is_open': true,
    'opens_at': '2026-10-04T18:00:00Z',
    'closes_at': '2026-10-05T00:00:00Z',
    'has_closed': false,
  },
  'candidates': [
    {
      'player': _player(10, 'HomeStarter'),
      'team': _home,
      'is_starting': true,
      'is_captain': false,
      'position': 'midfielder',
    },
  ],
  'tally': [],
  'total_votes': 0,
  'your_vote': null,
  'result': null,
};

void main() {
  late Map<String, dynamic> matchBody;

  setUp(() => matchBody = _matchJson);

  /// Opens the match, answered with [match] (by default, [matchBody]).
  Future<void> openMatch(WidgetTester tester,
      {Map<String, dynamic> Function()? match}) async {
    await pumpScreen(
      tester,
      const MatchScreen(slug: 'home-vs-away'),
      prefs: {'device_id': 'device-1'},
      api: (o) async => switch (o.uri.path) {
        '/api/v1/matchs/slug/home-vs-away/' =>
          jsonBody(200, match?.call() ?? matchBody),
        '/api/v1/matchs/1/player-of-the-match/' => jsonBody(200, _motmJson),
        _ => jsonBody(404, {}),
      },
    );
  }

  testWidgets('timeline shows a second yellow as a sending-off',
      (tester) async {
    await openMatch(tester);

    expect(find.text('Test Booked'), findsOneWidget);
    expect(find.text('Second yellow'), findsOneWidget);
  });

  testWidgets('lineups tab lists starters and substitutes', (tester) async {
    await openMatch(tester);

    await tester.tap(find.text('Lineups'));
    await tester.pumpAndSettle();

    expect(find.text('T. HomeStarter'), findsOneWidget);
    expect(find.text('T. AwayStarter'), findsOneWidget);
    expect(find.text('SUBSTITUTES'), findsOneWidget);
    expect(find.text('T. HomeBench'), findsOneWidget);
  });

  testWidgets('MOTM tab loads the voting panel', (tester) async {
    await openMatch(tester);

    await tester.tap(find.text('MOTM'));
    await tester.pumpAndSettle();

    expect(find.text('Vote for Man of the Match'), findsOneWidget);
    expect(find.text('Test HomeStarter'), findsOneWidget);
  });

  testWidgets('the Stats tab only appears when the match has statistics',
      (tester) async {
    await openMatch(tester);
    expect(find.text('Stats'), findsNothing);

    matchBody = {
      ..._matchJson,
      'statistics': {
        'home': {
          'possession': 60,
          'shots': 9,
          'yellow_cards': 1,
          'red_cards': 0
        },
        'away': {
          'possession': 40,
          'shots': 4,
          'yellow_cards': 0,
          'red_cards': 0
        },
        'source': 'admin',
        'source_note': '',
      },
    };
    await tester.pumpWidget(const SizedBox());
    await openMatch(tester);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('Shots'), findsOneWidget);

    // The other tabs still work with four of them.
    await tester.tap(find.text('Lineups'));
    await tester.pumpAndSettle();
    expect(find.text('T. HomeStarter'), findsOneWidget);
  });

  testWidgets('a live match refreshes its score every 30 seconds',
      (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    var homeGoals = 0;
    var requests = 0;
    await openMatch(tester, match: () {
      requests++;
      return {
        ..._matchJson,
        'status': 'ongoing',
        'score_final_home': homeGoals
      };
    });
    expect(find.text('0 - 0'), findsOneWidget);

    homeGoals = 1;
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();

    expect(requests, 2);
    expect(find.text('1 - 0'), findsOneWidget);
  });

  testWidgets('scrolling a tab collapses the header to a compact score bar',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final lineups = [
      for (var i = 0; i < 15; i++) _lineup(100 + i, _home, 'Home$i', true),
      for (var i = 0; i < 15; i++) _lineup(200 + i, _away, 'Away$i', true),
    ];
    matchBody = {..._matchJson, 'lineups': lineups};

    await openMatch(tester);
    expect(find.byType(MatchScoreBar), findsNothing);

    await tester.tap(find.text('Lineups'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('T. Home3'), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.byType(MatchScoreBar), findsOneWidget);
    expect(find.text('Lineups'), findsOneWidget,
        reason: 'tab bar stays pinned');

    await tester.drag(find.byType(TabBarView), const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.byType(MatchScoreBar), findsNothing);
  });
}
