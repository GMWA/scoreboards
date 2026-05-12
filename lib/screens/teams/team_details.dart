import 'package:flutter/material.dart';
import 'package:scoreboards/models/team.dart';
import 'package:scoreboards/services/teams.dart';

class TeamDetailsScreen extends StatefulWidget {
  final String slug;
  const TeamDetailsScreen({super.key, required this.slug});

  @override
  TeamDetailsScreenState createState() => TeamDetailsScreenState();
}

class TeamDetailsScreenState extends State<TeamDetailsScreen> {
  Team? team;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    try {
      final data = await TeamService.getTeamBySlug(widget.slug);
      if (mounted) {
        setState(() {
          team = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Team not found.";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0A0A0A);
    const Color brandRed = Color(0xFFE64C52);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: darkBg,
        body: Center(child: CircularProgressIndicator(color: brandRed)),
      );
    }

    if (team == null) {
      return Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
            child: Text(errorMessage ?? "Error",
                style: const TextStyle(color: Colors.white))),
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
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                team!.name.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Lexend',
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
                        colors: [brandRed.withOpacity(0.2), darkBg],
                      ),
                    ),
                  ),
                  Center(
                    child: Opacity(
                      opacity: 0.6,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Image.network(
                          team!.logo ?? "",
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

                  _buildInfoRow(
                      Icons.category_outlined, "Team Type", team!.teamType),
                  if (team!.stadium != null)
                    _buildInfoRow(Icons.stadium_outlined, "Home Stadium",
                        team!.stadium!.name),

                  const SizedBox(height: 32),

                  _buildSectionHeader("RECENT FORM"),
                  const SizedBox(height: 16),
                  const Text(
                    "Form data coming soon...",
                    style:
                        TextStyle(color: Colors.white24, fontFamily: 'Lexend'),
                  ),
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
            fontFamily: 'Lexend',
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
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
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFE64C52), size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontFamily: 'Lexend')),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend')),
            ],
          ),
        ],
      ),
    );
  }
}
