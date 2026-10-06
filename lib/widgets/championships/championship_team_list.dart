import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/team.dart';
import 'package:scoreboards/services/teams.dart';
import 'package:scoreboards/widgets/ui/team_card.dart';

class ChampionshipTeamList extends StatefulWidget {
  final int editionId;

  const ChampionshipTeamList({super.key, required this.editionId});

  @override
  State<ChampionshipTeamList> createState() => _TeamsTableState();
}

class _TeamsTableState extends State<ChampionshipTeamList> {
  late final Future<List<Team>> _teamsFuture;

  @override
  void initState() {
    super.initState();
    _teamsFuture = TeamService.getTeamsByEdition(widget.editionId);
  }

  @override
  Widget build(BuildContext context) {
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
          child: FutureBuilder<List<Team>>(
            future: _teamsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.coral));
              }

              if (snapshot.hasError) {
                return Center(
                    child: Text('Error loading teams',
                        style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)));
              }

              final teams = snapshot.data ?? [];

              if (teams.isEmpty) {
                return Center(
                    child: Text('No teams found for this season.',
                        style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)));
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
