import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/models/match_team.dart';
import 'package:scoreboards/models/favorite_item.dart';
import 'package:scoreboards/enums/matchs.dart';
import 'package:scoreboards/services/favorites_service.dart';

class MatchCard extends StatelessWidget {
  final MatchBase match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final bool isLive = match.status == MatchStatus.inProgress;
    final bool isFinished = match.status == MatchStatus.completed;
    final bool isPlanned = match.status == MatchStatus.planned;
    final String matchTime = DateFormat('HH:mm').format(match.date);

    final String statusLabel = isLive
        ? 'LIVE'
        : isFinished
            ? 'FT'
            : isPlanned
                ? matchTime
                : match.status.value.toUpperCase();
    final Color statusColor = isLive ? AppColors.coral : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isLive ? AppColors.coral : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/matchs/details/${match.slug}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isLive) ...[
                        const _PulsingDot(),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        statusLabel,
                        style: GoogleFonts.hankenGrotesk(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        match.round.isNotEmpty
                            ? match.round.toUpperCase()
                            : DateFormat('MMM d').format(match.date),
                        style: GoogleFonts.hankenGrotesk(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _FollowMenu(homeTeam: match.homeTeam, awayTeam: match.awayTeam),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _teamRow(match.homeTeam.name, match.homeTeam.logo),
                  ),
                  if (!isPlanned)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: '${match.scoreFinalHome}',
                            style: GoogleFonts.archivo(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: ' - ',
                            style: GoogleFonts.archivo(
                              color: AppColors.scoreDivider,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: '${match.scoreFinalAway}',
                            style: GoogleFonts.archivo(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ]),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        matchTime,
                        style: GoogleFonts.hankenGrotesk(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  Expanded(
                    child: _teamRow(match.awayTeam.name, match.awayTeam.logo,
                        reversed: true),
                  ),
                ],
              ),
              if (match.wentToPenalties)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '(${match.scorePsoHome}-${match.scorePsoAway} PEN)',
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamRow(String name, String? logo, {bool reversed = false}) {
    final badge = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.badgeBg,
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: logo != null && logo.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.network(
                logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _codeText(name),
              ),
            )
          : _codeText(name),
    );

    final label = Expanded(
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: reversed ? TextAlign.right : TextAlign.left,
        style: GoogleFonts.hankenGrotesk(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          height: 1.15,
        ),
      ),
    );

    final children = reversed ? [label, const SizedBox(width: 8), badge] : [badge, const SizedBox(width: 8), label];

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: children,
    );
  }

  Widget _codeText(String name) {
    final code = name.length >= 3 ? name.substring(0, 3).toUpperCase() : name.toUpperCase();
    return Text(
      code,
      style: GoogleFonts.hankenGrotesk(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 9.5,
      ),
    );
  }
}

/// Compact follow control for a match card — tapping the star opens a
/// two-row menu ("Follow" home team / "Follow" away team) rather than
/// committing to one team, since a single star icon can't unambiguously
/// represent two teams on the same card. The star itself fills in if
/// either team is already followed.
class _FollowMenu extends StatelessWidget {
  final MatchTeam homeTeam;
  final MatchTeam awayTeam;

  const _FollowMenu({required this.homeTeam, required this.awayTeam});

  FavoriteItem _itemFor(MatchTeam team) => FavoriteItem(
        id: team.id,
        slug: team.slug,
        name: team.name,
        logo: team.logo,
        kind: FavoriteKind.team,
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoritesService.instance,
      builder: (context, _) {
        final bool active = FavoritesService.instance.isTeamFollowed(homeTeam.id) ||
            FavoritesService.instance.isTeamFollowed(awayTeam.id);

        return PopupMenuButton<int>(
          padding: EdgeInsets.zero,
          tooltip: 'Follow a team',
          color: AppColors.surfaceAlt,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          icon: Icon(
            active ? Icons.star_rounded : Icons.star_border_rounded,
            size: 15,
            color: active ? AppColors.coral : AppColors.textSecondary,
          ),
          itemBuilder: (context) => [
            _menuItem(0, homeTeam),
            _menuItem(1, awayTeam),
          ],
          onSelected: (index) {
            FavoritesService.instance.toggle(_itemFor(index == 0 ? homeTeam : awayTeam));
          },
        );
      },
    );
  }

  PopupMenuItem<int> _menuItem(int index, MatchTeam team) {
    final bool followed = FavoritesService.instance.isTeamFollowed(team.id);
    return PopupMenuItem<int>(
      value: index,
      height: 38,
      child: Row(
        children: [
          Icon(
            followed ? Icons.star_rounded : Icons.star_border_rounded,
            size: 16,
            color: followed ? AppColors.coral : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            team.name,
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.35).animate(_controller),
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.82).animate(_controller),
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
