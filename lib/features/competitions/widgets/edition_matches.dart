import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/features/competitions/edition_matches_controller.dart';
import 'package:scoreboards/shared/widgets/match_card.dart';

/// An edition's matches, loaded a page at a time as the user scrolls.
class EditionMatches extends ConsumerWidget {
  final int editionId;

  const EditionMatches({super.key, required this.editionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editionMatchesProvider(editionId));
    final controller = ref.read(editionMatchesProvider(editionId).notifier);
    final matches = state.matches;

    if (matches.isEmpty) {
      if (state.isLoading) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.coral));
      }
      if (state.failed) {
        return Center(child: _retryButton('Error loading matches', controller));
      }
      return Center(
          child: Text('No matches available',
              style:
                  GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)));
    }

    final bool showFooter = state.hasMore || state.failed;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 600) controller.loadNextPage();
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: matches.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < matches.length) return MatchCard(match: matches[index]);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: state.failed
                  ? _retryButton('Could not load more matches', controller)
                  : const CircularProgressIndicator(color: AppColors.coral),
            ),
          );
        },
      ),
    );
  }

  Widget _retryButton(String message, EditionMatchesController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message,
            style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)),
        TextButton(
          onPressed: controller.loadNextPage,
          child: Text('RETRY',
              style: GoogleFonts.hankenGrotesk(
                  color: AppColors.coral, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
