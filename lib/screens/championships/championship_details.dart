import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/widgets/championships/standing_table.dart';
import 'package:scoreboards/widgets/championships/championship_team_list.dart';
import 'package:scoreboards/widgets/championships/player_stats.dart';
import 'package:scoreboards/widgets/championships/match_list.dart';
import 'package:scoreboards/models/editions.dart';
import 'package:scoreboards/models/favorite_item.dart';
import 'package:scoreboards/services/championship.dart';
import 'package:scoreboards/widgets/ui/favorite_star.dart';

class ChampionshipDetails extends StatefulWidget {
  final String slug;
  final Function? onViewAllTap;

  const ChampionshipDetails(
      {super.key, required this.slug, this.onViewAllTap});

  @override
  ChampionshipDetailsState createState() => ChampionshipDetailsState();
}

class ChampionshipDetailsState extends State<ChampionshipDetails> {
  Edition? edition;

  @override
  void initState() {
    super.initState();
    loadEdition();
  }

  void loadEdition() async {
    final edit = await ChampionshipService.getEditionBySlug(widget.slug);
    if(!mounted) return;
    setState(() {
      edition = edit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: edition == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.coral))
          : DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          image: edition!.championship.logo != null
                              ? DecorationImage(
                                  image: NetworkImage(edition!.championship.logo!),
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
                          edition!.label ?? '',
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
                            id: edition!.id,
                            slug: edition!.slug,
                            name: edition!.label ?? edition!.championship.name,
                            logo: edition!.championship.logo,
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
                      labelStyle:
                          GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 13),
                      unselectedLabelStyle:
                          GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Standings'),
                        Tab(text: 'Teams'),
                        Tab(text: 'Matches'),
                        Tab(text: 'P. Stats'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        StandingsTable(editionId: edition!.id),
                        ChampionshipTeamList(editionId: edition!.id),
                        MatchList(editionId: edition!.id),
                        PlayerStatsTable(editionId: edition!.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
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
