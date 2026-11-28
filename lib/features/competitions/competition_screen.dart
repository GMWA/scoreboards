import 'package:flutter/material.dart';
import 'package:scoreboards/core/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/features/competitions/widgets/standings_table.dart';
import 'package:scoreboards/features/competitions/widgets/competition_teams.dart';
import 'package:scoreboards/features/competitions/widgets/player_stats_table.dart';
import 'package:scoreboards/features/competitions/widgets/edition_matches.dart';
import 'package:scoreboards/shared/models/editions.dart';
import 'package:scoreboards/features/favorites/favorite_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/features/competitions/competitions_providers.dart';
import 'package:scoreboards/features/favorites/favorite_star.dart';

class CompetitionScreen extends ConsumerWidget {
  final String slug;

  const CompetitionScreen({super.key, required this.slug});

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: BackButton(color: AppColors.textPrimary),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.border, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.competitionLoadFailed,
                    style: GoogleFonts.hankenGrotesk(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(editionProvider(slug)),
                    child: Text(context.l10n.retry.toUpperCase(),
                        style: GoogleFonts.hankenGrotesk(
                            color: AppColors.coral,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Friendlies don't count, so their standings and player stats would be
  /// meaningless: they open on Matches and show only Matches and Teams.
  List<_EditionTab> _tabsOf(Edition edition) => edition.isFriendly
      ? const [_EditionTab.matches, _EditionTab.teams]
      : const [
          _EditionTab.standings,
          _EditionTab.teams,
          _EditionTab.matches,
          _EditionTab.playerStats,
        ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: switch (ref.watch(editionProvider(slug))) {
        AsyncData(value: final edition) => _buildEdition(context, edition),
        AsyncError() => _buildErrorState(context, ref),
        _ => const Center(
            child: CircularProgressIndicator(color: AppColors.coral)),
      },
    );
  }

  Widget _buildEdition(BuildContext context, Edition edition) {
    final tabs = _tabsOf(edition);
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  image: edition.championship.logo != null
                      ? DecorationImage(
                          image: NetworkImage(edition.championship.logo!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              AppColors.bg.withValues(alpha: 0.55),
                              BlendMode.darken),
                        )
                      : null,
                ),
              ),
              Container(
                height: 120,
                alignment: Alignment.center,
                child: Text(
                  edition.label ?? '',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: _HeaderIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => context.pop(),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: FavoriteStar(
                  item: FavoriteItem(
                    id: edition.id,
                    slug: edition.slug,
                    name: edition.label ?? edition.championship.name,
                    logo: edition.championship.logo,
                    kind: FavoriteKind.competition,
                  ),
                  size: 22,
                  inactiveColor: Colors.white70,
                ),
              ),
            ],
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: TabBar(
              labelColor: AppColors.coral,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.coral,
              indicatorWeight: 2,
              // Less side padding than the default, so "Classement" fits
              // a quarter of a ~360dp phone.
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              labelStyle: GoogleFonts.hankenGrotesk(
                  fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.hankenGrotesk(
                  fontWeight: FontWeight.w600, fontSize: 13),
              tabs: [for (final tab in tabs) Tab(text: tab.label(context.l10n))],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [for (final tab in tabs) tab.build(edition.id)],
            ),
          ),
        ],
      ),
    );
  }
}

enum _EditionTab {
  standings,
  teams,
  matches,
  playerStats;

  String label(AppLocalizations l10n) => switch (this) {
        standings => l10n.tabStandings,
        teams => l10n.tabTeams,
        matches => l10n.tabMatches,
        playerStats => l10n.tabPlayerStats,
      };

  Widget build(int editionId) => switch (this) {
        standings => StandingsTable(editionId: editionId),
        teams => CompetitionTeams(editionId: editionId),
        matches => EditionMatches(editionId: editionId),
        playerStats => PlayerStatsTable(editionId: editionId),
      };
}

/// Small circular tap target for icons placed over the header photo (back
/// arrow, favorite star). The translucent backdrop keeps the icon legible
/// regardless of what's underneath in the championship logo image.
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
