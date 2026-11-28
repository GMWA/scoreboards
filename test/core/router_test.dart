import 'package:flutter/material.dart';
import 'package:scoreboards/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:scoreboards/core/router.dart';
import 'package:scoreboards/features/blogs/blog_screen.dart';
import 'package:scoreboards/features/blogs/blogs_screen.dart';
import 'package:scoreboards/features/competitions/competition_screen.dart';
import 'package:scoreboards/features/competitions/competitions_screen.dart';
import 'package:scoreboards/features/favorites/favorite_item.dart';
import 'package:scoreboards/features/favorites/favorites_screen.dart';
import 'package:scoreboards/features/match/match_screen.dart';
import 'package:scoreboards/features/players/player_screen.dart';
import 'package:scoreboards/features/scores/scores_screen.dart';
import 'package:scoreboards/features/settings/settings_screen.dart';
import 'package:scoreboards/features/teams/team_screen.dart';
import 'package:scoreboards/features/teams/teams_screen.dart';

import '../helpers/fake_http.dart';
import '../helpers/fixtures.dart';
import '../helpers/harness.dart';

/// A backend with something on every screen.
final _backend = routes({
  '/matchs/day/': [matchJson(1, kickoff: DateTime.now())],
  '/matchs/live/': [matchJson(1, status: 'ongoing')],
  '/matchs/slug/match-1/': {
    ...matchJson(1),
    'goals': [],
    'cards': [],
    'substitutions': [],
    'lineups': [],
  },
  '/championships/editions/': [editionJson()],
  '/championships/editions/slug/cup-2026/': editionJson(),
  '/edition/1/standings/': [standingJson(1, 'Home FC', points: 3)],
  '/edition/1/rules/': [],
  '/teams/': {
    'next': null,
    'results': [teamJson(1, 'Home FC')]
  },
  '/teams/slug/team-1/': teamJson(1, 'Home FC'),
  '/players/slug/p1/': playerJson(1, 'Mbougain'),
  '/players/1/teams-history/': [],
  '/articles/': {
    'next': null,
    'results': [
      {'id': 4, 'slug': 'top-scorers', 'title': 'Top scorers'},
    ],
  },
  '/articles/slug/top-scorers/': {
    'id': 4,
    'slug': 'top-scorers',
    'title': 'Top scorers',
    'body': '<p>Six goals.</p>',
    'created_at': '2026-11-16T10:00:00Z',
    'updated_at': '2026-11-16T10:00:00Z',
  },
});

void main() {
  late GoRouter router;

  Future<void> open(WidgetTester tester, String location) async {
    router.go(location);
    await tester.pumpAndSettle();
  }

  testWidgets('every screen opens at its path', (tester) async {
    final container = await testContainer(
      api: _backend,
      prefs: {'device_id': 'device-1'},
    );
    router = container.read(routerProvider);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
  localizationsDelegates: AppLocalizations.localizationsDelegates,routerConfig: router),
    ));
    await tester.pumpAndSettle();

    final screens = <String, (Type, String?)>{
      Routes.scores: (ScoresScreen, 'Home FC'),
      Routes.competitions: (CompetitionsScreen, 'Cup 2026'),
      Routes.competition('cup-2026'): (CompetitionScreen, 'Standings'),
      Routes.teams: (TeamsScreen, 'Home FC'),
      Routes.team('team-1'): (TeamScreen, null),
      Routes.blogs: (BlogsScreen, 'Top scorers'),
      Routes.blog('top-scorers'): (BlogScreen, 'Top scorers'),
      Routes.match('match-1'): (MatchScreen, 'Timeline'),
      Routes.player('p1'): (PlayerScreen, 'Test Mbougain'),
      Routes.settings: (SettingsScreen, 'Favorite Teams'),
      Routes.favorites(FavoriteKind.team): (FavoritesScreen, 'Favorite Teams'),
      Routes.favorites(FavoriteKind.competition): (
        FavoritesScreen,
        'Favorite Competitions'
      ),
    };
    for (final MapEntry(key: path, value: (screen, text)) in screens.entries) {
      await open(tester, path);
      expect(find.byType(screen), findsOneWidget, reason: path);
      if (text != null) {
        expect(find.text(text), findsWidgets, reason: path);
      }
    }

    // Website links (App Links) open the matching screen.
    await open(tester, 'https://scoreboards.cm/matchs/match-1');
    expect(find.byType(MatchScreen), findsOneWidget);
    await open(tester, 'https://scoreboards.cm/leagues/cup-2026');
    expect(find.byType(CompetitionScreen), findsOneWidget);

    // Closes the screens (and their refresh timers), and lets the short
    // timers of images and caches run out.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
  });
}
