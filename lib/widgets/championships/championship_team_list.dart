import 'package:flutter/material.dart';
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
    const Color brandRed = AppColors.brand;
    const Color surface = AppColors.surface;

    return Column(
      children: [
        // 1. Premium Edition Selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "PARTICIPATING TEAMS",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white38,
                  letterSpacing: 1.2,
                ),
              ),
              _buildModernDropdown(surface, brandRed),
            ],
          ),
        ),

        // 2. The Team List
        Expanded(
          child: FutureBuilder<List<Team>>(
            future: _teamsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: brandRed));
              }

              if (snapshot.hasError) {
                return const Center(
                    child: Text("Error loading teams",
                        style: TextStyle(
                            color: Colors.white38, fontFamily: 'Lexend')));
              }

              final teams = snapshot.data ?? [];

              if (teams.isEmpty) {
                return const Center(
                    child: Text("No teams found for this season.",
                        style: TextStyle(
                            color: Colors.white24, fontFamily: 'Lexend')));
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

  Widget _buildModernDropdown(Color surface, Color brandRed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedEdition,
          dropdownColor: surface,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.brand, size: 18),
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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
