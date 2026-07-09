import 'package:flutter/material.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/favorite_item.dart';
import 'package:scoreboards/services/favorites_service.dart';

/// A tap-to-follow star, meant to appear anywhere a team or competition
/// name/badge is shown (team card, edition card, detail headers, match
/// card). Reflects and toggles the shared FavoritesService state.
class FavoriteStar extends StatelessWidget {
  final FavoriteItem item;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteStar({
    super.key,
    required this.item,
    this.size = 20,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoritesService.instance,
      builder: (context, _) {
        final bool active = FavoritesService.instance.isFollowed(item);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FavoritesService.instance.toggle(item),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              active ? Icons.star_rounded : Icons.star_border_rounded,
              size: size,
              color: active
                  ? (activeColor ?? AppColors.coral)
                  : (inactiveColor ?? AppColors.textSecondary),
            ),
          ),
        );
      },
    );
  }
}
