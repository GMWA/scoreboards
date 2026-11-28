import 'package:flutter/material.dart';
import 'package:scoreboards/core/l10n.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/features/motm/motm_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/features/motm/motm_controller.dart';

/// Fan "Man of the Match" voting panel for a single match: candidate list
/// (sourced from match appearances), live tally, and the fan-voted result
/// once the voting window closes.
class MotmVotingTab extends ConsumerStatefulWidget {
  final int matchId;
  const MotmVotingTab({super.key, required this.matchId});

  @override
  ConsumerState<MotmVotingTab> createState() => _MotmVotingTabState();
}

class _MotmVotingTabState extends ConsumerState<MotmVotingTab> {
  int? pendingPlayerId;

  Future<void> _onCandidateTap(MotmSummary current, MotmCandidate candidate) async {
    if (!current.window.isOpen || pendingPlayerId != null) return;

    setState(() => pendingPlayerId = candidate.player.id);
    try {
      await ref.read(motmProvider(widget.matchId).notifier).toggleVote(candidate);
    } catch (e) {
      if (!mounted) return;
      final refusal = e is ApiException ? e.message : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(refusal ?? context.l10n.motmVoteFailed)),
      );
    } finally {
      if (mounted) setState(() => pendingPlayerId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (ref.watch(motmProvider(widget.matchId))) {
      AsyncData(value: final current) => _buildSummary(current),
      AsyncError() =>
        _Message(text: context.l10n.motmLoadFailed),
      _ => const Center(child: CircularProgressIndicator(color: AppColors.coral)),
    };
  }

  Widget _buildSummary(MotmSummary current) {
    if (current.candidates.isEmpty) {
      return _Message(
        text: context.l10n.motmOpensWithLineups,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _WindowBanner(summary: current),
        const SizedBox(height: 16),
        for (final candidate in current.candidates)
          _CandidateRow(
            candidate: candidate,
            votes: current.votesFor(candidate.player.id),
            totalVotes: current.totalVotes,
            isSelected: current.yourVote?.player.id == candidate.player.id,
            isPending: pendingPlayerId == candidate.player.id,
            canVote: current.window.isOpen,
            onTap: () => _onCandidateTap(current, candidate),
          ),
      ],
    );
  }
}

class _WindowBanner extends StatelessWidget {
  final MotmSummary summary;
  const _WindowBanner({required this.summary});

  @override
  Widget build(BuildContext context) {
    final result = summary.result;

    String title;
    String subtitle;
    if (result != null) {
      if (result.isTie) {
        title = context.l10n.motmTie;
        subtitle = context.l10n.motmVotesCast(result.totalVotes);
      } else if (result.fanWinner != null) {
        title =
            context.l10n.motmWinner('${result.fanWinner!.firstname} ${result.fanWinner!.lastname}');
        subtitle = context.l10n.motmWinnerVotes(result.winnerVotes, result.totalVotes);
      } else {
        title = context.l10n.motmVotingClosed;
        subtitle = context.l10n.motmNoVotes;
      }
    } else if (summary.window.isOpen) {
      title = context.l10n.motmVoteTitle;
      subtitle =
          context.l10n.motmVotingCloses(DateFormat.MMMd().add_Hm().format(summary.window.closesAt));
    } else {
      title = context.l10n.motmVotingClosed;
      subtitle = context.l10n.motmFinalizing;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: result != null && !result.isTie && result.fanWinner != null
            ? AppColors.mintTint
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final MotmCandidate candidate;
  final int votes;
  final int totalVotes;
  final bool isSelected;
  final bool isPending;
  final bool canVote;
  final VoidCallback onTap;

  const _CandidateRow({
    required this.candidate,
    required this.votes,
    required this.totalVotes,
    required this.isSelected,
    required this.isPending,
    required this.canVote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double share = totalVotes > 0 ? votes / totalVotes : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: canVote ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.coral : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      candidate.player.jerseyNumber?.toString() ?? '',
                      style: GoogleFonts.hankenGrotesk(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${candidate.player.firstname} ${candidate.player.lastname}',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.hankenGrotesk(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (isPending)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.coral,
                      ),
                    )
                  else if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.coral, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    '$votes',
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 4,
                  backgroundColor: AppColors.surfaceAlt,
                  color: isSelected ? AppColors.coral : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}
