import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/features/teams/teams_repository.dart';
import 'package:scoreboards/shared/models/team.dart';

/// Every team, for the Teams tab.
final teamsProvider = FutureProvider.autoDispose<List<Team>>(
  (ref) => ref.watch(teamsRepositoryProvider).all(),
);

final teamProvider = FutureProvider.autoDispose.family<Team, String>(
  (ref, slug) => ref.watch(teamsRepositoryProvider).bySlug(slug),
);

/// The teams whose name contains [query], ignoring case.
List<Team> teamsMatching(List<Team> teams, String query) {
  final needle = query.toLowerCase();
  return teams.where((t) => t.name.toLowerCase().contains(needle)).toList();
}
