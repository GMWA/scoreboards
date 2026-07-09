import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/player.dart';
import 'package:scoreboards/services/player.dart';

class _ProfileData {
  final Player player;
  final PlayerTeamHistory? currentClub;
  final PlayerStats? currentSeasonStats;

  _ProfileData({required this.player, this.currentClub, this.currentSeasonStats});
}

/// Player Profile screen ("Pro" tab detail) — net-new UI, matching the
/// design's bio card / stat grid / match-log layout. Backed by
/// [PlayerService], which doesn't expose a per-match log endpoint yet, so
/// that section is scoped down to what the API actually returns today.
class PlayerScreen extends StatefulWidget {
  final String slug;
  const PlayerScreen({super.key, required this.slug});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late Future<_ProfileData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProfileData> _load() async {
    final player = await PlayerService.getPlayerBySlug(widget.slug);

    PlayerTeamHistory? currentClub;
    PlayerStats? currentSeasonStats;
    try {
      final history = await PlayerService.getPlayerTeamsHistory(player.id);
      if (history.isNotEmpty) {
        currentClub = history.firstWhere(
          (h) => h.endDate == null,
          orElse: () => history.last,
        );
      }
      if (currentClub != null) {
        final teamStats =
            await PlayerService.getPlayerStatsByTeam(currentClub.team.id);
        currentSeasonStats = teamStats.cast<PlayerStats?>().firstWhere(
              (s) => s?.player.id == player.id,
              orElse: () => null,
            );
      }
    } catch (_) {
      // Team history / stats are best-effort — the profile still renders
      // with just the core player record if these calls fail.
    }

    return _ProfileData(
        player: player, currentClub: currentClub, currentSeasonStats: currentSeasonStats);
  }

  String _initials(Player p) {
    final f = p.firstname.isNotEmpty ? p.firstname[0] : '';
    final l = p.lastname.isNotEmpty ? p.lastname[0] : '';
    return ('$f$l').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FutureBuilder<_ProfileData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.coral));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _buildError(context);
            }
            return _buildProfile(context, snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Column(
      children: [
        _header(context, title: 'Player Profile'),
        Expanded(
          child: Center(
            child: Text('Could not load this player.',
                style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, {required String title}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.canPop() ? context.pop() : context.go('/home'),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.chevron_left, color: AppColors.coral),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _buildProfile(BuildContext context, _ProfileData data) {
    final p = data.player;
    final age = DateTime.now().year - p.dateOfBirth.year;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, title: 'Player Profile'),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bio card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: const Border(
                      left: BorderSide(color: AppColors.mint, width: 3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2A3138), Color(0xFF161A1E)],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials(p),
                          style: GoogleFonts.spaceGrotesk(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${p.firstname} ${p.lastname}',
                              style: GoogleFonts.spaceGrotesk(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${p.position} • No. ${p.jerseyNumber} • Age $age',
                              style: GoogleFonts.hankenGrotesk(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 7,
                              runSpacing: 6,
                              children: [
                                _pill(p.nationality),
                                if (data.currentClub != null)
                                  _pill(data.currentClub!.team.name),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stat grid
                if (data.currentSeasonStats != null) ...[
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.85,
                    children: [
                      _statTile('Goals', data.currentSeasonStats!.goals.toString()),
                      _statTile('Assists', data.currentSeasonStats!.assists.toString()),
                      _statTile('Yellow Cards',
                          data.currentSeasonStats!.yellowCards.toString()),
                      _statTile('Red Cards',
                          data.currentSeasonStats!.redCards.toString(),
                          highlight: data.currentSeasonStats!.redCards > 0),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'No season stats available for this player yet.',
                      style: GoogleFonts.hankenGrotesk(
                          color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ),

                // Club history
                if (data.currentClub != null)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Club',
                                style: GoogleFonts.hankenGrotesk(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.currentClub!.team.name,
                                style: GoogleFonts.hankenGrotesk(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Since ${DateFormat('MMM yyyy').format(data.currentClub!.startDate)}',
                          style: GoogleFonts.hankenGrotesk(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: GoogleFonts.hankenGrotesk(color: AppColors.textPrimary, fontSize: 11),
      ),
    );
  }

  Widget _statTile(String label, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.archivo(
              color: highlight ? AppColors.coral : AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
