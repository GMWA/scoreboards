import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scoreboards/layouts/app_layout.dart';
import 'package:scoreboards/screens/settings/settings_screen.dart';
import 'package:scoreboards/screens/matchs/match_screen.dart';
import 'package:scoreboards/screens/matchs/match_details_screen.dart';
import 'package:scoreboards/screens/championships/championship_screen.dart';
import 'package:scoreboards/screens/championships/championship_details.dart';
import 'package:scoreboards/screens/teams/team_screen.dart';
import 'package:scoreboards/screens/teams/team_details.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppLayout(body: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const MatchListScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/teams',
          builder: (context, state) => const TeamListScreen(),
          routes: [
            GoRoute(
              path: ':slug',
              builder: (context, state) {
                final slug = state.pathParameters['slug']!;
                return TeamDetailsScreen(slug: slug);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/championships',
          builder: (context, state) => const ChampionshipListScreen(),
          routes: [
            GoRoute(
              path: ':slug',
              builder: (context, state) {
                final slug = state.pathParameters['slug']!;
                return ChampionshipDetails(slug: slug);
              },
            ),
          ],
        ),
        GoRoute(
            path: '/matchs/details/:slug',
            builder: (context, state) {
              final slug = state.pathParameters['slug']!;
              return MatchDetailsScreen(slug: slug);
            }),
      ],
    ),
  ],
);
