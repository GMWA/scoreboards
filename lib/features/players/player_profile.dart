import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/features/players/players_repository.dart';
import 'package:scoreboards/shared/models/player.dart';

/// What the Player Profile screen shows.
class PlayerProfile {
  PlayerProfile(
      {required this.player, this.currentClub, this.currentSeasonStats});

  final Player player;
  final PlayerTeamHistory? currentClub;
  final PlayerStats? currentSeasonStats;
}

/// The player, with their current club and their statistics there. The
/// club and statistics are best effort: the profile still shows with just
/// the player if those requests fail.
final playerProfileProvider =
    FutureProvider.autoDispose.family<PlayerProfile, String>((ref, slug) async {
  final repo = ref.watch(playersRepositoryProvider);
  final player = await repo.bySlug(slug);

  PlayerTeamHistory? currentClub;
  PlayerStats? currentSeasonStats;
  try {
    final history = await repo.teamsHistory(player.id);
    if (history.isNotEmpty) {
      currentClub = history.firstWhere(
        (h) => h.endDate == null,
        orElse: () => history.last,
      );
    }
    if (currentClub != null) {
      final teamStats = await repo.statsByTeam(currentClub.team.id);
      currentSeasonStats = teamStats
          .cast<PlayerStats?>()
          .firstWhere((s) => s?.player.id == player.id, orElse: () => null);
    }
  } catch (_) {
    // Best effort, see above.
  }

  return PlayerProfile(
    player: player,
    currentClub: currentClub,
    currentSeasonStats: currentSeasonStats,
  );
});
