import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/match_statistics.dart';

typedef _Stat = int? Function(TeamMatchStats stats);

// In display order, like the website's statistics tab.
final List<(String, _Stat, bool)> _rows = [
  ('Possession', (s) => s.possession, true),
  ('Shots', (s) => s.shots, false),
  ('Shots on target', (s) => s.shotsOnTarget, false),
  ('Corners', (s) => s.corners, false),
  ('Fouls', (s) => s.fouls, false),
  ('Offsides', (s) => s.offsides, false),
  ('Saves', (s) => s.saves, false),
  ('Yellow cards', (s) => s.yellowCards, false),
  ('Red cards', (s) => s.redCards, false),
];

/// Both teams' statistics side by side, each with a bar comparing them.
/// A stat unknown for both teams is left out; one unknown for a single team
/// shows "–", never 0.
class MatchStatisticsTab extends StatelessWidget {
  final MatchStatistics statistics;
  final String homeName;
  final String awayName;

  const MatchStatisticsTab({
    super.key,
    required this.statistics,
    required this.homeName,
    required this.awayName,
  });

  @override
  Widget build(BuildContext context) {
    final teamStyle = GoogleFonts.hankenGrotesk(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w800,
      fontSize: 11,
      letterSpacing: 1.2,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(homeName.toUpperCase(),
                  overflow: TextOverflow.ellipsis, style: teamStyle),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(awayName.toUpperCase(),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: teamStyle),
            ),
          ],
        ),
        const SizedBox(height: 18),
        for (final (label, stat, percent) in _rows)
          if (stat(statistics.home) != null || stat(statistics.away) != null)
            _StatRow(
              label: label,
              home: stat(statistics.home),
              away: stat(statistics.away),
              percent: percent,
            ),
        if (statistics.sourceNote.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Source: ${statistics.sourceNote}',
            textAlign: TextAlign.center,
            style: GoogleFonts.hankenGrotesk(
                color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int? home;
  final int? away;
  final bool percent;

  const _StatRow({
    required this.label,
    required this.home,
    required this.away,
    required this.percent,
  });

  String _format(int? value) =>
      value == null ? '–' : (percent ? '$value%' : '$value');

  @override
  Widget build(BuildContext context) {
    final h = home ?? 0;
    final a = away ?? 0;
    final total = h + a;
    // Both bars stay empty at 0-0 rather than splitting an empty total.
    final homeShare = total == 0 ? 0.0 : h / total;
    final awayShare = total == 0 ? 0.0 : a / total;

    TextStyle valueStyle(bool leads) => GoogleFonts.archivo(
          color: leads ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

    return Semantics(
      label: '$label: ${_format(home)} to ${_format(away)}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text(_format(home), style: valueStyle(h > a)),
                ),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(_format(away),
                      textAlign: TextAlign.right, style: valueStyle(a > h)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child:
                        _Bar(share: homeShare, leads: h > a, fromRight: true)),
                const SizedBox(width: 4),
                Expanded(child: _Bar(share: awayShare, leads: a > h)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A track filled to [share] (0 to 1); the home bar fills from the centre
/// outwards, so the two bars meet in the middle.
class _Bar extends StatelessWidget {
  final double share;
  final bool leads;
  final bool fromRight;

  const _Bar(
      {required this.share, required this.leads, this.fromRight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: fromRight ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: share,
        child: Container(
          decoration: BoxDecoration(
            color: leads
                ? AppColors.coral
                : AppColors.textSecondary.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
