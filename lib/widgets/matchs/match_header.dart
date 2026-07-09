import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/enums/matchs.dart';
import 'package:scoreboards/widgets/teams/team_logo_name.dart';

class MatchHeader extends StatelessWidget {
  final MatchBase match;

  const MatchHeader({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final bool isLive = match.status == MatchStatus.inProgress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.coral.withValues(alpha: 0.15),
            AppColors.bg,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          _StatusBadge(status: match.status),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: TeamLogoName(isHome: true, team: match.homeTeam, showFollow: true)),
              SizedBox(
                width: 120,
                child: Column(
                  children: [
                    Text(
                      match.status == MatchStatus.planned
                          ? 'VS'
                          : '${match.scoreFinalHome} - ${match.scoreFinalAway}',
                      style: GoogleFonts.archivo(
                        fontSize: 40,
                        color: isLive ? AppColors.coral : AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    if (match.wentToPenalties && match.scorePsoHome != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '(${match.scorePsoHome} - ${match.scorePsoAway} PEN)',
                          style: GoogleFonts.hankenGrotesk(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(child: TeamLogoName(isHome: false, team: match.awayTeam, showFollow: true)),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(
                  match.round.toUpperCase(),
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.coral, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      match.location.toUpperCase(),
                      style: GoogleFonts.hankenGrotesk(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MatchStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isLive = status == MatchStatus.inProgress;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isLive ? AppColors.coral : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLive ? AppColors.coral : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            const Icon(Icons.sensors, color: Colors.white, size: 12),
            const SizedBox(width: 6),
          ],
          Text(
            _getStatusText().toUpperCase(),
            style: GoogleFonts.hankenGrotesk(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (status) {
      case MatchStatus.inProgress:
        return 'Live';
      case MatchStatus.completed:
        return 'Full Time';
      case MatchStatus.planned:
        return 'Scheduled';
      default:
        return status.value;
    }
  }
}
