import 'package:flutter/material.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/team.dart';
import 'package:scoreboards/services/teams.dart';
import 'package:scoreboards/widgets/ui/team_card.dart';

class TeamListScreen extends StatefulWidget {
  const TeamListScreen({super.key});

  @override
  TeamListScreenState createState() => TeamListScreenState();
}

class TeamListScreenState extends State<TeamListScreen> {
  late Future<List<Team>> _teamsFuture;
  List<Team> _allTeams = [];
  List<Team> _filteredTeams = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeams();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTeams() {
    setState(() {
      _teamsFuture = TeamService.getTeams().then((teams) {
        _allTeams = teams;
        _filteredTeams = teams;
        return teams;
      });
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTeams = _allTeams
          .where((team) => team.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _refreshTeams() async {
    _loadTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('Teams', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Search teams',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Team>>(
              future: _teamsFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.coral));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('An error occurred while loading!',
                            style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _refreshTeams,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredTeams.isEmpty) {
                  return const Center(
                      child: Text('No teams found.',
                          style: TextStyle(color: AppColors.textSecondary)));
                }

                return RefreshIndicator(
                  color: AppColors.coral,
                  backgroundColor: AppColors.surface,
                  onRefresh: _refreshTeams,
                  child: ListView.builder(
                    itemCount: _filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = _filteredTeams[index];
                      return TeamCard(team: team);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
