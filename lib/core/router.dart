import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:scoreboards/core/app_shell.dart';
import 'package:scoreboards/core/config.dart';
import 'package:scoreboards/core/links.dart';
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

/// Every screen's path. Screens navigate with these rather than writing
/// paths themselves. The paths are public: website links (App Links) and
/// push notifications open them, so changing one breaks those.
class Routes {
  const Routes._();

  // Bottom navigation tabs.
  static const scores = '/home';
  static const competitions = '/championships';
  static const teams = '/teams';
  static const blogs = '/blogs';
  static const settings = '/settings';

  static String competition(String slug) => '$competitions/$slug';
  static String team(String slug) => '$teams/$slug';
  static String blog(String slug) => '$blogs/$slug';
  static String match(String slug) => '/matchs/details/$slug';
  static String player(String slug) => '/players/$slug';

  static String favorites(FavoriteKind kind) => kind == FavoriteKind.team
      ? '$settings/favorites/teams'
      : '$settings/favorites/competitions';

  /// The screen for a followed team or competition.
  static String favorite(FavoriteItem item) => item.kind == FavoriteKind.team
      ? team(item.slug)
      : competition(item.slug);
}

/// Goes back, or to the scores when the screen was opened from a link or a
/// notification (nothing under it).
void popOrGoHome(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(Routes.scores);

Widget _slugScreen(
  GoRouterState state,
  Widget Function(String slug) build,
) =>
    build(state.pathParameters['slug']!);

/// Bottom-nav destinations: Scores (home) / Leagues / Teams / Blogs /
/// Settings. Match Center and Player Profile are detail screens reached by
/// tapping through from a match card or a player row; they are not nav
/// destinations.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.scores,
    // Records screen changes as breadcrumbs on crash reports (no-op when
    // Sentry isn't configured).
    observers: [SentryNavigatorObserver()],
    // A website link that opened the app arrives with the website's path.
    redirect: (context, state) =>
        appRouteForIncomingLink(state.uri, AppConfig.website),
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(body: child),
        routes: [
          GoRoute(
            path: Routes.scores,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ScoresScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity:
                      CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (context, state) => const SettingsScreen(),
            routes: [
              for (final kind in FavoriteKind.values)
                GoRoute(
                  path: Routes.favorites(kind)
                      .substring(Routes.settings.length + 1),
                  builder: (context, state) => FavoritesScreen(kind: kind),
                ),
            ],
          ),
          GoRoute(
            path: Routes.teams,
            builder: (context, state) => const TeamsScreen(),
            routes: [
              GoRoute(
                path: ':slug',
                builder: (context, state) =>
                    _slugScreen(state, (slug) => TeamScreen(slug: slug)),
              ),
            ],
          ),
          GoRoute(
            path: Routes.blogs,
            builder: (context, state) => const BlogsScreen(),
            routes: [
              GoRoute(
                path: ':slug',
                builder: (context, state) =>
                    _slugScreen(state, (slug) => BlogScreen(slug: slug)),
              ),
            ],
          ),
          GoRoute(
            path: Routes.competitions,
            builder: (context, state) => const CompetitionsScreen(),
            routes: [
              GoRoute(
                path: ':slug',
                builder: (context, state) => _slugScreen(
                    state, (slug) => CompetitionScreen(slug: slug)),
              ),
            ],
          ),
          GoRoute(
            path: Routes.match(':slug'),
            builder: (context, state) =>
                _slugScreen(state, (slug) => MatchScreen(slug: slug)),
          ),
          GoRoute(
            path: Routes.player(':slug'),
            builder: (context, state) =>
                _slugScreen(state, (slug) => PlayerScreen(slug: slug)),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
