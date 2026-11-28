import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/shared/models/team.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/features/competitions/competitions_providers.dart';
import 'package:scoreboards/shared/widgets/async_view.dart';
import 'package:scoreboards/shared/widgets/team_card.dart';

class CompetitionTeams extends ConsumerWidget {
  final int editionId;

  const CompetitionTeams({super.key, required this.editionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'PARTICIPATING TEAMS',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        Expanded(
          child: AsyncView<List<Team>>(
            value: ref.watch(editionTeamsProvider(editionId)),
            error: () => Center(
                child: Text('Error loading teams',
                    style: GoogleFonts.hankenGrotesk(
                        color: AppColors.textSecondary))),
            data: (teams) {
              if (teams.isEmpty) {
                return Center(
                    child: Text('No teams found for this season.',
                        style: GoogleFonts.hankenGrotesk(
                            color: AppColors.textSecondary)));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  return TeamCard(team: teams[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
