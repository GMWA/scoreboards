import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/team.dart';
import 'package:scoreboards/models/favorite_item.dart';
import 'package:scoreboards/widgets/ui/favorite_star.dart';

class TeamCard extends StatelessWidget {
  final Team team;

  const TeamCard({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: () {
          context.push('/teams/${team.slug}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: team.logo != null && team.logo!.isNotEmpty
                    ? Image.network(
                        team.logo!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildFallback(),
                      )
                    : _buildFallback(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (team.stadium != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: AppColors.coral, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              team.stadium!.name,
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              FavoriteStar(
                item: FavoriteItem(
                  id: team.id,
                  slug: team.slug,
                  name: team.name,
                  logo: team.logo,
                  kind: FavoriteKind.team,
                ),
                size: 19,
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return const Icon(
      Icons.shield_outlined,
      size: 32,
      color: AppColors.textSecondary,
    );
  }
}
