import 'package:flutter/material.dart';
import 'package:scoreboards/core/l10n.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/shared/models/editions.dart';
import 'package:scoreboards/features/competitions/standing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/features/competitions/competitions_providers.dart';
import 'package:scoreboards/shared/widgets/async_view.dart';

/// Standings for an edition: one table per group for group-stage
/// competitions (cups), a single table otherwise. Positions are coloured by
/// the edition's qualification rules, with a legend underneath.
class StandingsTable extends ConsumerStatefulWidget {
  final int editionId;

  const StandingsTable({super.key, required this.editionId});

  @override
  ConsumerState<StandingsTable> createState() => _StandingsTableState();
}

class _StandingsTableState extends ConsumerState<StandingsTable> {
  static const double _teamNameWidth = 112;

  @override
  Widget build(BuildContext context) {
    return AsyncView<(List<Standing>, List<EditionStandingRule>)>(
      value: ref.watch(standingsProvider(widget.editionId)),
      error: () => Center(
        child: Text(context.l10n.standingsLoadFailed,
            style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)),
      ),
      data: (data) {
        final (standings, rules) = data;

        if (standings.isEmpty) {
          return Center(
            child: Text(context.l10n.noStandings,
                style:
                    GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)),
          );
        }

        final groups = standings
            .map((s) => s.participation.group)
            .whereType<String>()
            .where((g) => g.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: AppColors.divider,
            unselectedWidgetColor: AppColors.textSecondary,
          ),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (groups.isEmpty)
                _buildTable(standings, rules)
              else
                for (final group in groups) ...[
                  _buildGroupHeader(group),
                  _buildTable(
                    standings
                        .where((s) => s.participation.group == group)
                        .toList(),
                    rules,
                  ),
                ],
              if (rules.isNotEmpty) _buildLegend(rules),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupHeader(String group) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.border, height: 1)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.coralTint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              group.toUpperCase(),
              style: GoogleFonts.hankenGrotesk(
                color: AppColors.coral,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.border, height: 1)),
        ],
      ),
    );
  }

  Widget _buildTable(List<Standing> rows, List<EditionStandingRule> rules) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.surface),
            // Tight enough that all eight columns fit a ~360dp phone.
            columnSpacing: 8.0,
            horizontalMargin: 12,
            headingRowHeight: 45,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 54,
            columns: [
              _buildHeader('#', color: AppColors.textSecondary),
              _buildHeader(context.l10n.standingsTeam, color: AppColors.textSecondary),
              _buildHeader(context.l10n.standingsPoints, color: AppColors.coral),
              _buildHeader(context.l10n.standingsPlayed, color: AppColors.textSecondary),
              _buildHeader(context.l10n.standingsWon, color: AppColors.textSecondary),
              _buildHeader(context.l10n.standingsDrawn, color: AppColors.textSecondary),
              _buildHeader(context.l10n.standingsLost, color: AppColors.textSecondary),
              _buildHeader(context.l10n.standingsGoalDifference, color: AppColors.textSecondary),
            ],
            rows: List<DataRow>.generate(rows.length, (index) {
              final item = rows[index];
              final rule = _ruleFor(index + 1, rules);
              final Color? zoneColor =
                  rule == null ? null : ruleColor(rule.color);

              return DataRow(
                cells: [
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 3,
                        height: 22,
                        decoration: BoxDecoration(
                          color: zoneColor ?? Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (index + 1).toString(),
                        style: GoogleFonts.hankenGrotesk(
                          color: zoneColor ?? AppColors.textSecondary,
                          fontWeight: zoneColor != null
                              ? FontWeight.w800
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSmallLogo(item.participation.team.logo),
                      const SizedBox(width: 10),
                      // Fixed width so every group's table lines up the same.
                      SizedBox(
                        width: _teamNameWidth,
                        child: Text(
                          item.participation.team.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.hankenGrotesk(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )),
                  DataCell(Text(
                    item.points.toString(),
                    style: GoogleFonts.archivo(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  )),
                  _buildDataCell(item.played.toString()),
                  _buildDataCell(item.wins.toString()),
                  _buildDataCell(item.drawn.toString()),
                  _buildDataCell(item.losses.toString()),
                  _buildDataCell(
                    item.goalsDifference > 0
                        ? '+${item.goalsDifference}'
                        : item.goalsDifference.toString(),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(List<EditionStandingRule> rules) {
    final sorted = [...rules]..sort((a, b) {
        final byPriority = a.priority.compareTo(b.priority);
        return byPriority != 0
            ? byPriority
            : a.fromPosition.compareTo(b.fromPosition);
      });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Wrap(
        spacing: 18,
        runSpacing: 10,
        children: [
          for (final rule in sorted)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ruleColor(rule.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  rule.outcome,
                  style: GoogleFonts.hankenGrotesk(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  DataColumn _buildHeader(String label, {required Color color}) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  DataCell _buildDataCell(String value) {
    return DataCell(Text(
      value,
      style: GoogleFonts.hankenGrotesk(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ));
  }

  Widget _buildSmallLogo(String? url) {
    return Container(
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(4),
      ),
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield,
                  size: 14, color: AppColors.textSecondary),
            )
          : const Icon(Icons.shield, size: 14, color: AppColors.textSecondary),
    );
  }
}

/// The rule covering [position] (1-based, within its group); a rule with no
/// `toPosition` covers everything from `fromPosition` down.
EditionStandingRule? _ruleFor(int position, List<EditionStandingRule> rules) {
  for (final rule in rules) {
    final to = rule.toPosition;
    if (position >= rule.fromPosition && (to == null || position <= to)) {
      return rule;
    }
  }
  return null;
}

/// Maps a rule's colour (a CSS-style name like "green", or a hex value) to
/// the app palette.
@visibleForTesting
Color ruleColor(String value) {
  switch (value.trim().toLowerCase()) {
    case 'green':
      return AppColors.mint;
    case 'red':
      return AppColors.coral;
    case 'blue':
      return const Color(0xFF5B9DFF);
    case 'orange':
      return const Color(0xFFFFA24C);
    case 'yellow':
      return AppColors.yellowCard;
  }
  final hex = value.trim().replaceFirst('#', '');
  final parsed = hex.length == 6 ? int.tryParse(hex, radix: 16) : null;
  return parsed != null ? Color(0xFF000000 | parsed) : AppColors.textSecondary;
}
