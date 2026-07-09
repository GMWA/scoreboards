import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/services/matchs.dart';
import 'package:scoreboards/widgets/ui/match_card.dart';

class MatchList extends StatelessWidget {
  final int editionId;
  final String status; // Optional: "scheduled", "played", etc.

  const MatchList({
    super.key,
    required this.editionId,
    this.status = "",
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MatchBase>>(
      future: MatchService.getMatchsByEdition(
          editionId,
          status: status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.coral));
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading matches',
                  style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)));
        }

        final matches = snapshot.data ?? [];

        if (matches.isEmpty) {
          return Center(
              child: Text('No matches available',
                  style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return MatchCard(match: match);
          },
        );
      },
    );
  }
}
