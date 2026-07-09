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
  int _selectedEdition = 2026;
  late Future<List<Team>> _teamsFuture;

  final List<int> _editions = [2024, 2025, 2026];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  void _loadTeams() {
    setState(() {
      _teamsFuture = TeamService.getTeamsByEdition(widget.editionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PARTICIPATING TEAMS',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              _buildModernDropdown(),
            ],
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

  Widget _buildModernDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedEdition,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.coral, size: 18),
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          items: _editions
              .map((edition) => DropdownMenuItem(
                    value: edition,
                    child: Text(edition.toString()),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedEdition = value);
              _loadTeams();
            }
          },
        ),
      ),
    );
  }
}
