import 'package:flutter/material.dart';
import 'package:scoreboards/core/l10n.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/shared/utils.dart';
import 'package:scoreboards/shared/models/match.dart';
import 'package:scoreboards/shared/models/match_team.dart';
import 'package:scoreboards/shared/models/match_enums.dart';
import 'package:scoreboards/shared/widgets/team_logo_name.dart';

/// The score as shown in the header and the score bar: "VS" before kick-off,
/// "? - ?" when the match was played but its result isn't known.
String _scoreText(MatchBase match) {
  if (match.status == MatchStatus.resultUnknown) return '? - ?';
  if (!match.status.hasScore) return 'VS';
  return '${match.scoreFinalHome} - ${match.scoreFinalAway}';
}

class MatchHeader extends StatelessWidget {
  final MatchBase match;

  const MatchHeader({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final bool isLive = match.status == MatchStatus.ongoing;
    final bool isResultUnknown = match.status == MatchStatus.resultUnknown;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
              Expanded(
                  child: TeamLogoName(
                      isHome: true, team: match.homeTeam, showFollow: true)),
              SizedBox(
                width: 120,
                child: Column(
                  children: [
                    Text(
                      _scoreText(match),
                      style: GoogleFonts.archivo(
                        fontSize: 40,
                        color: isLive
                            ? AppColors.coral
                            : isResultUnknown
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    if (isResultUnknown)
                      Text(
                        context.l10n.resultUnknown,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.hankenGrotesk(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    if (match.wentToPenalties && match.scorePsoHome != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          context.l10n.penaltiesScore('${match.scorePsoHome}', '${match.scorePsoAway}'),
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
              Expanded(
                  child: TeamLogoName(
                      isHome: false, team: match.awayTeam, showFollow: true)),
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
                  roundLabel(context.l10n, match.round).toUpperCase(),
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
                    Flexible(
                      child: Text(
                        match.location.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.hankenGrotesk(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
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
    final bool isLive = status == MatchStatus.ongoing;

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
            _getStatusText(context.l10n).toUpperCase(),
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

  String _getStatusText(AppLocalizations l10n) => switch (status) {
        MatchStatus.ongoing => l10n.statusLive,
        MatchStatus.completed || MatchStatus.resultUnknown => l10n.statusFullTime,
        MatchStatus.planned || MatchStatus.scheduled => l10n.statusScheduled,
        MatchStatus.postponed => l10n.statusPostponed,
        MatchStatus.cancelled => l10n.statusCancelled,
        MatchStatus.abandoned => l10n.statusAbandoned,
        MatchStatus.awarded => l10n.statusAwarded,
      };
}

/// One-line score shown in the match screen's top bar once the full header
/// has scrolled away: home logo and name, score, away name and logo.
class MatchScoreBar extends StatelessWidget {
  final MatchBase match;

  const MatchScoreBar({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    // One fixed-height line: cap text growth so it can't overflow.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: _buildRow(context),
    );
  }

  Widget _buildRow(BuildContext context) {
    final bool isLive = match.status == MatchStatus.ongoing;
    final bool hasPens = match.wentToPenalties && match.scorePsoHome != null;

    return Row(
      children: [
        Expanded(child: _team(match.homeTeam, alignEnd: true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _scoreText(match),
                style: GoogleFonts.archivo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isLive
                      ? AppColors.coral
                      : match.status == MatchStatus.resultUnknown
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                ),
              ),
              if (hasPens)
                Text(
                  context.l10n.penaltiesScore('${match.scorePsoHome}', '${match.scorePsoAway}'),
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _team(match.awayTeam, alignEnd: false)),
      ],
    );
  }

  Widget _team(MatchTeam team, {required bool alignEnd}) {
    final logo = Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      child: team.logo != null && team.logo!.isNotEmpty
          ? Image.network(
              team.logo!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield_outlined,
                  size: 18, color: AppColors.textSecondary),
            )
          : const Icon(Icons.shield_outlined,
              size: 18, color: AppColors.textSecondary),
    );
    final name = Flexible(
      child: Text(
        team.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );

    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [name, const SizedBox(width: 8), logo]
          : [logo, const SizedBox(width: 8), name],
    );
  }
}
