import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/favorite_item.dart';
import 'package:scoreboards/services/favorites_service.dart';

/// Manages everything the user has followed via the star icon on team
/// cards, edition cards, match cards, and detail headers. Reached from
/// Settings > Preferences > Favorite Teams / Favorite Competitions.
class FavoritesManagementScreen extends StatelessWidget {
  final FavoriteKind kind;

  const FavoritesManagementScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final bool isTeams = kind == FavoriteKind.team;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(
          isTeams ? 'Favorite Teams' : 'Favorite Competitions',
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: FavoritesService.instance,
        builder: (context, _) {
          final items = isTeams
              ? FavoritesService.instance.followedTeams
              : FavoritesService.instance.followedCompetitions;

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  isTeams
                      ? "You haven't followed any teams yet. Tap the star on a team's card or profile to follow it."
                      : "You haven't followed any competitions yet. Tap the star on a competition's card or page to follow it.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  onTap: () {
                    context.push(isTeams
                        ? '/teams/${item.slug}'
                        : '/championships/${item.slug}');
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: item.logo != null && item.logo!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.logo!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                isTeams ? Icons.shield_outlined : Icons.emoji_events,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : Icon(
                            isTeams ? Icons.shield_outlined : Icons.emoji_events,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                  ),
                  title: Text(
                    item.name,
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.star_rounded, color: AppColors.coral, size: 22),
                    tooltip: 'Unfollow',
                    onPressed: () => FavoritesService.instance.remove(item),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
