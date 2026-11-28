import 'package:flutter/material.dart';
import 'package:scoreboards/core/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/features/favorites/favorite_item.dart';
import 'package:scoreboards/features/favorites/favorites_controller.dart';
import 'package:scoreboards/core/notifications/push_service.dart';

/// A tap-to-follow star, meant to appear anywhere a team or competition
/// name/badge is shown (team card, edition card, detail headers, match
/// card). Reflects and toggles [favoritesProvider]. The first
/// follow also offers notifications, if the user was never asked.
class FavoriteStar extends ConsumerWidget {
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

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    await ref.read(favoritesProvider.notifier).toggle(item);
    if (!ref.read(favoritesProvider).isFollowed(item)) return;

    if (await ref.read(pushServiceProvider).offerAfterFollow() &&
        context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content: Text(
            context.l10n.followingNotice(item.name)),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool active =
        ref.watch(favoritesProvider.select((f) => f.isFollowed(item)));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggle(context, ref),
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
  }
}
