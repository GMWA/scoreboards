import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/features/competitions/competitions_repository.dart';
import 'package:scoreboards/features/competitions/standing.dart';
import 'package:scoreboards/features/players/players_repository.dart';
import 'package:scoreboards/features/teams/teams_repository.dart';
import 'package:scoreboards/shared/models/editions.dart';
import 'package:scoreboards/shared/models/player.dart';
import 'package:scoreboards/shared/models/team.dart';

/// The editions on the Leagues tab.
final activeEditionsProvider = FutureProvider.autoDispose<List<Edition>>(
  (ref) => ref.watch(competitionsRepositoryProvider).activeEditions(),
);

final editionProvider = FutureProvider.autoDispose.family<Edition, String>(
  (ref, slug) => ref.watch(competitionsRepositoryProvider).editionBySlug(slug),
);

/// An edition's standings with the rules that colour them. The rules only
/// colour the table, so the standings still show without them.
final standingsProvider = FutureProvider.autoDispose
    .family<(List<Standing>, List<EditionStandingRule>), int>(
        (ref, editionId) async {
  final repo = ref.watch(competitionsRepositoryProvider);
  final rules = repo
      .standingRules(editionId)
      .catchError((Object _) => <EditionStandingRule>[]);
  return (await repo.standings(editionId), await rules);
});

final editionTeamsProvider = FutureProvider.autoDispose.family<List<Team>, int>(
  (ref, editionId) => ref.watch(teamsRepositoryProvider).byEdition(editionId),
);

final editionPlayerStatsProvider =
    FutureProvider.autoDispose.family<List<PlayerStats>, int>(
  (ref, editionId) =>
      ref.watch(playersRepositoryProvider).statsByEdition(editionId),
);
