import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/screens/matchs/match_details_screen.dart';
import 'package:scoreboards/services/device_service.dart';
import 'package:scoreboards/services/matchs.dart';
import 'package:scoreboards/services/motm_service.dart';

const _home = {'id': 1, 'slug': 'home', 'name': 'Home FC'};
const _away = {'id': 2, 'slug': 'away', 'name': 'Away FC'};

Map<String, dynamic> _player(int id, String lastname) => {
      'id': id,
      'slug': 'p$id',
      'firstname': 'Test',
      'lastname': lastname,
      'jersey_number': id,
    };

Map<String, dynamic> _lineup(int id, Map team, String lastname, bool starting) => {
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
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'device_id': 'device-1'});
    DeviceService().resetCache();

    urls['MATCHS']!['BY_SLUG'] = 'https://fake.dev/matchs/slug/';
    urls['MATCHS']!['PLAYER_OF_THE_MATCH'] =
        'https://fake.dev/matchs/#matchId/player-of-the-match/';

    MatchService.client =
        MockClient((_) async => Response(jsonEncode(_matchJson), 200));
    MotmService.client =
        MockClient((_) async => Response(jsonEncode(_motmJson), 200));
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: MatchDetailsScreen(slug: 'home-vs-away')));
    await tester.pumpAndSettle();
  }

  testWidgets('timeline shows a second yellow as a sending-off', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Test Booked'), findsOneWidget);
    expect(find.text('Second yellow'), findsOneWidget);
  });

  testWidgets('lineups tab lists starters and substitutes', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Lineups'));
    await tester.pumpAndSettle();

    expect(find.text('T. HomeStarter'), findsOneWidget);
    expect(find.text('T. AwayStarter'), findsOneWidget);
    expect(find.text('SUBSTITUTES'), findsOneWidget);
    expect(find.text('T. HomeBench'), findsOneWidget);
  });

  testWidgets('MOTM tab loads the voting panel', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('MOTM'));
    await tester.pumpAndSettle();

    expect(find.text('Vote for Man of the Match'), findsOneWidget);
    expect(find.text('Test HomeStarter'), findsOneWidget);
  });

  testWidgets('a live match refreshes its score every 30 seconds',
      (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    var homeGoals = 0;
    var requests = 0;
    MatchService.client = MockClient((_) async {
      requests++;
      return Response(
          jsonEncode({
            ..._matchJson,
            'status': 'ongoing',
            'score_final_home': homeGoals,
          }),
          200);
    });

    await pumpScreen(tester);
    expect(find.text('0 - 0'), findsOneWidget);

    homeGoals = 1;
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();

    expect(requests, 2);
    expect(find.text('1 - 0'), findsOneWidget);
  });
}
