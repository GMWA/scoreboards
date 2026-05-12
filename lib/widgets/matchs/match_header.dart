import 'package:flutter/material.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/enums/matchs.dart';
// Note: I'm assuming TeamLogoName exists, but I'll style the wrapper here
import 'package:scoreboards/widgets/teams/team_logo_name.dart';

class MatchHeader extends StatelessWidget {
  final MatchBase match;

  const MatchHeader({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    const Color brandRed = Color(0xFFE64C52);
    const Color darkBg = Color(0xFF0A0A0A);
    final bool isLive = match.status == MatchStatus.inProgress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            brandRed.withOpacity(0.15),
            darkBg,
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
              // Home Team
              Expanded(
                child: TeamLogoName(
                  isHome: true,
                  team: match.homeTeam,
                ),
              ),

              Container(
                width: 120,
                child: Column(
                  children: [
                    Text(
                      match.status == MatchStatus.planned
                          ? "VS"
                          : "${match.scoreFinalHome} - ${match.scoreFinalAway}",
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 48,
                        color: isLive ? brandRed : Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                      ),
                    ),
                    if (match.wentToPenalties && match.scorePsoHome != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "(${match.scorePsoHome} - ${match.scorePsoAway} PEN)",
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: TeamLogoName(
                  isHome: false,
                  team: match.awayTeam,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Text(
                  match.round.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: brandRed, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      match.location.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        color: Colors.white38,
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
    const Color brandRed = Color(0xFFE64C52);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isLive ? brandRed : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLive ? brandRed : Colors.white10,
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
            style: const TextStyle(
              fontFamily: 'Lexend',
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
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
        return "Live";
      case MatchStatus.completed:
        return "Full Time";
      case MatchStatus.planned:
        return "Scheduled";
      default:
        return status.value;
    }
  }
}
