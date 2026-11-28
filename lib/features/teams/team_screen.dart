import 'package:flutter/material.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/shared/utils.dart';
import 'package:scoreboards/shared/models/team.dart';
import 'package:scoreboards/features/favorites/favorite_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/features/teams/teams_providers.dart';
import 'package:scoreboards/features/favorites/favorite_star.dart';

class TeamScreen extends ConsumerWidget {
  final String slug;
  const TeamScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color darkBg = AppColors.bg;
    const Color brandRed = AppColors.coral;

    final Team team;
    switch (ref.watch(teamProvider(slug))) {
      case AsyncValue(hasValue: true, :final value):
        team = value!;
      case AsyncError():
        return Scaffold(
          backgroundColor: darkBg,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: const Center(
              child: Text("Team not found.",
                  style: TextStyle(color: Colors.white))),
        );
      default:
        return const Scaffold(
          backgroundColor: darkBg,
          body: Center(child: CircularProgressIndicator(color: brandRed)),
        );
    }

    return Scaffold(
      backgroundColor: darkBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: darkBg,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FavoriteStar(
                  item: FavoriteItem(
                    id: team.id,
                    slug: team.slug,
                    name: team.name,
                    logo: team.logo,
                    kind: FavoriteKind.team,
                  ),
                  size: 22,
                  inactiveColor: Colors.white70,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                team.name.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [brandRed.withValues(alpha: 0.2), darkBg],
                      ),
                    ),
                  ),
                  Center(
                    child: Opacity(
                      opacity: 0.6,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Image.network(
                          team.logo ?? "",
                          height: 120,
                          errorBuilder: (c, e, s) => const Icon(Icons.shield,
                              size: 80, color: Colors.white10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("OVERVIEW"),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.category_outlined, "Team Type",
                      capitalize(team.teamType)),
                  if (team.stadium != null)
                    _buildInfoRow(Icons.stadium_outlined, "Home Stadium",
                        team.stadium!.name),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.coral, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
