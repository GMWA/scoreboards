import 'package:flutter/material.dart';
import 'package:scoreboards/core/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/shared/models/player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/core/router.dart';
import 'package:scoreboards/features/competitions/competitions_providers.dart';
import 'package:scoreboards/shared/widgets/async_view.dart';

class PlayerStatsTable extends ConsumerStatefulWidget {
  final int editionId;
  const PlayerStatsTable({super.key, required this.editionId});

  @override
  ConsumerState<PlayerStatsTable> createState() => _PlayerStatsTableState();
}

class _PlayerStatsTableState extends ConsumerState<PlayerStatsTable> {
  bool _showAll = false;
  static const int _previewLimit = 5;

  @override
  Widget build(BuildContext context) {
    const Color brandRed = AppColors.coral;
    const Color surface = AppColors.surface;

    return AsyncView<List<PlayerStats>>(
      value: ref.watch(editionPlayerStatsProvider(widget.editionId)),
      error: () => Center(
        child: Text(context.l10n.statsLoadFailed,
            style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)),
      ),
      data: (all) {
        if (all.isEmpty) return const SizedBox.shrink();

        // Sort by goals descending
        final stats = [...all]..sort((a, b) => b.goals.compareTo(a.goals));

        final visibleStats =
            _showAll ? stats : stats.take(_previewLimit).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.topScorers,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  // Icon(Icons.ball, color: brandRed.withValues(alpha: 0.5), size: 16),
                ],
              ),
              const SizedBox(height: 16),

              // 2. The Stats List
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    ...visibleStats.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildPlayerRow(
                          context, index + 1, item, brandRed);
                    }),
                  ],
                ),
              ),

              // 3. Toggle Button
              if (stats.length > _previewLimit)
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _showAll = !_showAll),
                    child: Text(
                      _showAll ? context.l10n.showLess : context.l10n.viewFullList,
                      style: const TextStyle(
                        color: brandRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerRow(
      BuildContext context, int rank, PlayerStats item, Color brandRed) {
    return InkWell(
      onTap: () => context.push(Routes.player(item.player.slug)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.05), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 24,
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: rank == 1 ? brandRed : Colors.white24,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),

            // Player & Team
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${item.player.firstname} ${item.player.lastname}"
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item.playerTeam.name,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Goal Count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: brandRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.goals.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
