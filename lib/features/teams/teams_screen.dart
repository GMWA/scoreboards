import 'package:flutter/material.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/shared/models/team.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/features/teams/teams_providers.dart';
import 'package:scoreboards/shared/widgets/async_view.dart';
import 'package:scoreboards/shared/widgets/team_card.dart';

class TeamsScreen extends ConsumerStatefulWidget {
  const TeamsScreen({super.key});

  @override
  ConsumerState<TeamsScreen> createState() => TeamsScreenState();
}

class TeamsScreenState extends ConsumerState<TeamsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshTeams() =>
      ref.refresh(teamsProvider.future).catchError((Object _) => <Team>[]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title:
            const Text('Teams', style: TextStyle(color: AppColors.textPrimary)),
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
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textSecondary),
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
            child: AsyncView<List<Team>>(
              value: ref.watch(teamsProvider),
              error: () => Center(
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
              ),
              data: (teams) {
                final filteredTeams =
                    teamsMatching(teams, _searchController.text);
                if (filteredTeams.isEmpty) {
                  return const Center(
                      child: Text('No teams found.',
                          style: TextStyle(color: AppColors.textSecondary)));
                }

                return RefreshIndicator(
                  color: AppColors.coral,
                  backgroundColor: AppColors.surface,
                  onRefresh: _refreshTeams,
                  child: ListView.builder(
                    itemCount: filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = filteredTeams[index];
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
