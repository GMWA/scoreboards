import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/editions.dart';
import 'package:scoreboards/models/favorite_item.dart';
import 'package:scoreboards/widgets/ui/favorite_star.dart';

class EditionCard extends StatelessWidget {
  final Edition edition;
  final VoidCallback? onTap;

  const EditionCard({
    super.key,
    required this.edition,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: edition.championship.logo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          edition.championship.logo!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.emoji_events,
                              size: 18,
                              color: AppColors.textSecondary),
                        ),
                      )
                    : const Icon(Icons.emoji_events,
                        size: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      edition.label ?? '',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      edition.championship.country,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (edition.isCurrent) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.coralTint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.coral,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: AppColors.coral,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              FavoriteStar(
                item: FavoriteItem(
                  id: edition.id,
                  slug: edition.slug,
                  name: edition.label ?? edition.championship.name,
                  logo: edition.championship.logo,
                  kind: FavoriteKind.competition,
                ),
                size: 18,
              ),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.coral),
            ],
          ),
        ),
      ),
    );
  }
}
