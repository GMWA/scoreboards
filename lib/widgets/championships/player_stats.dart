import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/player.dart';
import 'package:scoreboards/services/player.dart';

class PlayerStatsTable extends StatefulWidget {
  final int editionId;
  const PlayerStatsTable({super.key, required this.editionId});

  @override
  State<PlayerStatsTable> createState() => _PlayerStatsTableState();
}

class _PlayerStatsTableState extends State<PlayerStatsTable> {
  late Future<List<PlayerStats>> _statsFuture;
  bool _showAll = false;
  static const int _previewLimit = 5;

  @override
  void initState() {
    super.initState();
    _statsFuture = PlayerService.getPlayerStatsByEdition(widget.editionId);
  }

  @override
  Widget build(BuildContext context) {
    const Color brandRed = AppColors.coral;
    const Color surface = AppColors.surface;

    return FutureBuilder<List<PlayerStats>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: brandRed));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load stats',
                style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)),
          );
        }

        final stats = snapshot.data ?? [];
        if (stats.isEmpty) return const SizedBox.shrink();

        // Sort by goals descending
        stats.sort((a, b) => b.goals.compareTo(a.goals));

        final visibleStats =
            _showAll ? stats : stats.take(_previewLimit).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Section Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TOP GOAL SCORERS",
                    style: TextStyle(
                      fontFamily: 'Lexend',
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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    ...visibleStats.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildPlayerRow(context, index + 1, item, brandRed);
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
                      _showAll ? "SHOW LESS" : "VIEW FULL LIST",
                      style: const TextStyle(
                        fontFamily: 'Lexend',
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

  Widget _buildPlayerRow(BuildContext context, int rank, PlayerStats item, Color brandRed) {
    return InkWell(
      onTap: () => context.push('/players/${item.player.slug}'),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
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
                fontFamily: 'Lexend',
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
                    fontFamily: 'Lexend',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.playerTeam.name,
                  style: const TextStyle(
                    fontFamily: 'Lexend',
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
                fontFamily: 'Lexend',
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
