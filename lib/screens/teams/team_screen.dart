import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text("Teams")),
      body: Column(
        children: [
          // 🔍 Search Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search teams',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // 🧾 Team List
          Expanded(
            child: FutureBuilder<List<Team>>(
              future: _teamsFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("An error occurred while loading!"),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _refreshTeams,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredTeams.isEmpty) {
                  return const Center(child: Text("No teams found."));
                }

                return RefreshIndicator(
                  onRefresh: _refreshTeams,
                  child: ListView.builder(
                    itemCount: _filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = _filteredTeams[index];
                      return InkWell(
                        onTap: () {
                          // Navigate to team details if needed
                        },
                        child: TeamCard(team: team),
                      );
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
