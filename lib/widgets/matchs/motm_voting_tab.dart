import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/motm.dart';
import 'package:scoreboards/services/device_service.dart';
import 'package:scoreboards/services/motm_service.dart';

/// Fan "Man of the Match" voting panel for a single match: candidate list
/// (sourced from match appearances), live tally, and the fan-voted result
/// once the voting window closes.
class MotmVotingTab extends StatefulWidget {
  final int matchId;
  const MotmVotingTab({super.key, required this.matchId});

  @override
  State<MotmVotingTab> createState() => _MotmVotingTabState();
}

class _MotmVotingTabState extends State<MotmVotingTab> {
  MotmSummary? summary;
  bool isLoading = true;
  String? errorMessage;
  int? pendingPlayerId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final deviceId = await DeviceService().getOrRegisterDevice();
      final data =
          await MotmService.getSummary(widget.matchId, deviceId: deviceId);
      if (mounted) {
        setState(() {
          summary = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Could not load Man of the Match voting.';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _onCandidateTap(MotmCandidate candidate) async {
    final current = summary;
    if (current == null || !current.window.isOpen || pendingPlayerId != null) {
      return;
    }

    final alreadySelected = current.yourVote?.player.id == candidate.player.id;
    setState(() => pendingPlayerId = candidate.player.id);

    try {
      final updated = alreadySelected
          ? await MotmService.retractVote(widget.matchId)
          : await MotmService.castVote(widget.matchId, candidate.player.id);
      if (mounted) {
        setState(() {
          summary = updated;
          pendingPlayerId = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => pendingPlayerId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is MotmVoteRejected ? e.message : 'Could not record your vote.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.coral));
    }

    final current = summary;
    if (current == null) {
      return _Message(
        text: errorMessage ?? 'Man of the Match voting is not available.',
      );
    }

    if (current.candidates.isEmpty) {
      return const _Message(
        text: 'Man of the Match voting opens once lineups are published.',
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
            onTap: () => _onCandidateTap(candidate),
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
        title = "It's a tie!";
        subtitle = '${result.totalVotes} votes cast';
      } else if (result.fanWinner != null) {
        title =
            '${result.fanWinner!.firstname} ${result.fanWinner!.lastname} won Man of the Match';
        subtitle = '${result.winnerVotes} of ${result.totalVotes} votes';
      } else {
        title = 'Voting has closed';
        subtitle = 'No votes were cast';
      }
    } else if (summary.window.isOpen) {
      title = 'Vote for Man of the Match';
      subtitle =
          'Voting closes ${DateFormat('MMM d, HH:mm').format(summary.window.closesAt)}';
    } else {
      title = 'Voting has closed';
      subtitle = 'Result is being finalized';
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
