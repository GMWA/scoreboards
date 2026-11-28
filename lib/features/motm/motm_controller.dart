import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/features/motm/motm_models.dart';
import 'package:scoreboards/features/motm/motm_repository.dart';

/// A match's Man of the Match voting, as this device sees it.
final motmProvider = AsyncNotifierProvider.autoDispose
    .family<MotmController, MotmSummary, int>(MotmController.new);

class MotmController extends AsyncNotifier<MotmSummary> {
  MotmController(this.matchId);

  final int matchId;

  MotmRepository get _repo => ref.read(motmRepositoryProvider);

  @override
  Future<MotmSummary> build() => _repo.summary(matchId);

  /// Votes for [candidate], or takes the vote back when it already has it.
  /// Throws when the backend refuses; the summary is then unchanged.
  Future<void> toggleVote(MotmCandidate candidate) async {
    final current = state.value;
    if (current == null) return;
    final alreadySelected = current.yourVote?.player.id == candidate.player.id;
    final updated = alreadySelected
        ? await _repo.retract(matchId)
        : await _repo.vote(matchId, candidate.player.id);
    if (ref.mounted) state = AsyncData(updated);
  }
}
