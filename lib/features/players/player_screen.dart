import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/shared/utils.dart';
import 'package:scoreboards/shared/models/player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/core/router.dart';
import 'package:scoreboards/features/players/player_profile.dart';
import 'package:scoreboards/shared/widgets/async_view.dart';

/// Player Profile screen ("Pro" tab detail) — net-new UI, matching the
/// design's bio card / stat grid / match-log layout. Backed by
/// [playerProfileProvider]; the API doesn't expose a per-match log endpoint yet, so
/// that section is scoped down to what the API actually returns today.
class PlayerScreen extends ConsumerWidget {
  final String slug;
  const PlayerScreen({super.key, required this.slug});

  int _ageOn(DateTime today, DateTime birth) {
    final hadBirthdayThisYear = today.month > birth.month ||
        (today.month == birth.month && today.day >= birth.day);
    return today.year - birth.year - (hadBirthdayThisYear ? 0 : 1);
  }

  String _initials(Player p) {
    final f = p.firstname.isNotEmpty ? p.firstname[0] : '';
    final l = p.lastname.isNotEmpty ? p.lastname[0] : '';
    return ('$f$l').toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // bottom: false — AppShell's bottom nav bar already reserves the
      // device's bottom safe inset.
      body: SafeArea(
        bottom: false,
        child: AsyncView<PlayerProfile>(
          value: ref.watch(playerProfileProvider(slug)),
          error: () => _buildError(context),
          data: (profile) => _buildProfile(context, profile),
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
                style:
                    GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)),
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
            onTap: () => popOrGoHome(context),
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

  Widget _buildProfile(BuildContext context, PlayerProfile data) {
    final p = data.player;
    final int? age =
        p.dateOfBirth == null ? null : _ageOn(DateTime.now(), p.dateOfBirth!);
    final subtitle = [
      capitalize(p.position),
      if (p.jerseyNumber != null) 'No. ${p.jerseyNumber}',
      if (age != null) 'Age $age',
    ].join(' • ');

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
                              subtitle,
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
                                if (p.nationality != null &&
                                    p.nationality!.isNotEmpty)
                                  _pill(p.nationality!),
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
                      _statTile(
                          'Goals', data.currentSeasonStats!.goals.toString()),
                      _statTile('Assists',
                          data.currentSeasonStats!.assists.toString()),
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
        style: GoogleFonts.hankenGrotesk(
            color: AppColors.textPrimary, fontSize: 11),
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
            style: GoogleFonts.hankenGrotesk(
                color: AppColors.textSecondary, fontSize: 12.5),
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
