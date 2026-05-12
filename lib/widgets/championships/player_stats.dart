import 'package:flutter/material.dart';
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
    const Color brandRed = Color(0xFFE64C52);
    const Color surface = Color(0xFF1A1A1A);

    return FutureBuilder<List<PlayerStats>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: brandRed));
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("Failed to load stats",
                style: TextStyle(color: Colors.white38, fontFamily: 'Lexend')),
          );
        }

        final stats = snapshot.data ?? [];
        if (stats.isEmpty) return const SizedBox.shrink();

        // Sort by goals descending
        stats.sort((a, b) => b.goals.compareTo(a.goals));

        final visibleStats =
            _showAll ? stats : stats.take(_previewLimit).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOP GOAL SCORERS",
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  // Icon(Icons.ball, color: brandRed.withOpacity(0.5), size: 16),
                ],
              ),
              const SizedBox(height: 16),

              // 2. The Stats List
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    ...visibleStats.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildPlayerRow(index + 1, item, brandRed);
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

  Widget _buildPlayerRow(int rank, PlayerStats item, Color brandRed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5),
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
                  style: TextStyle(
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
              color: brandRed.withOpacity(0.1),
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
    );
  }
}
