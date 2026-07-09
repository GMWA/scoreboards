import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/editions.dart';
import 'package:scoreboards/models/player.dart';
import 'package:scoreboards/services/championship.dart';
import 'package:scoreboards/services/player.dart';
import 'package:scoreboards/widgets/ui/player_card.dart';

/// The "Pro" tab landing screen — a searchable goal-scorer leaderboard for
/// the current edition. Tapping a player opens the full Player Profile.
class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  late Future<List<PlayerStats>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<PlayerStats>> _load() async {
    final editions = await ChampionshipService.getActiveEditions();
    if (editions.isEmpty) return [];
    final Edition current = editions.firstWhere(
      (e) => e.isCurrent,
      orElse: () => editions.first,
    );
    final stats = await PlayerService.getPlayerStatsByEdition(current.id);
    stats.sort((a, b) => b.goals.compareTo(a.goals));
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Players',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
                        style: GoogleFonts.hankenGrotesk(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Search players, teams...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: AppColors.coral, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Top Scorers',
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<PlayerStats>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: AppColors.coral));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Failed to load players.',
                            style: GoogleFonts.hankenGrotesk(
                                color: AppColors.textSecondary)),
                      );
                    }
                    var stats = snapshot.data ?? [];
                    if (_search.isNotEmpty) {
                      stats = stats.where((s) {
                        final name =
                            '${s.player.firstname} ${s.player.lastname} ${s.playerTeam.name}'
                                .toLowerCase();
                        return name.contains(_search);
                      }).toList();
                    }
                    if (stats.isEmpty) {
                      return Center(
                        child: Text(
                          _search.isNotEmpty
                              ? "No players found for '$_search'."
                              : 'No player stats available yet.',
                          style: GoogleFonts.hankenGrotesk(
                              color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: stats.length,
                      itemBuilder: (context, index) => PlayerCard(
                        stats: stats[index],
                        rank: index + 1,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
