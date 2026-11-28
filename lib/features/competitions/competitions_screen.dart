import 'package:flutter/material.dart';
import 'package:scoreboards/core/l10n.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/shared/models/editions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/core/router.dart';
import 'package:scoreboards/features/competitions/competitions_providers.dart';
import 'package:scoreboards/features/competitions/widgets/edition_card.dart';
import 'package:go_router/go_router.dart';

class CompetitionsScreen extends ConsumerWidget {
  const CompetitionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> refresh() => ref
        .refresh(activeEditionsProvider.future)
        .catchError((Object _) => <Edition>[]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Text(
            context.l10n.competitionsTitle,
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: switch (ref.watch(activeEditionsProvider)) {
            AsyncData(value: final editions) =>
              _buildEditions(context, editions, refresh),
            AsyncError() => _buildErrorState(context, refresh),
            _ => const Center(
                child: CircularProgressIndicator(color: AppColors.coral)),
          },
        ),
      ],
    );
  }

  Widget _buildEditions(BuildContext context, List<Edition> editions,
      Future<void> Function() refresh) {
    if (editions.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noCompetitions,
          style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary),
        ),
      );
    }

    final active = editions.where((e) => e.isCurrent).toList();
    final archived = editions.where((e) => !e.isCurrent).toList()
      ..sort((a, b) {
        final aDate = a.startDate;
        final bDate = b.startDate;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

    return RefreshIndicator(
      backgroundColor: AppColors.surface,
      color: AppColors.coral,
      onRefresh: refresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        children: [
          if (active.isNotEmpty) ...[
            _buildSectionHeader(context.l10n.liveCompetitions),
            const SizedBox(height: 10),
            ...active.map((e) => _buildEditionCard(context, e)),
            const SizedBox(height: 8),
          ],
          if (archived.isNotEmpty) ...[
            _buildSectionHeader(context.l10n.archive),
            const SizedBox(height: 10),
            ...archived.map((e) => _buildEditionCard(context, e)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 2),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.hankenGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEditionCard(BuildContext context, Edition edition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: EditionCard(
        edition: edition,
        onTap: () {
          context.push(Routes.competition(edition.slug));
        },
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, Future<void> Function() retry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.border, size: 48),
          const SizedBox(height: 16),
          Text(
            context.l10n.connectionError,
            style: GoogleFonts.hankenGrotesk(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          TextButton(
            onPressed: retry,
            child: Text(context.l10n.retry.toUpperCase(),
                style: GoogleFonts.hankenGrotesk(
                    color: AppColors.coral, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
