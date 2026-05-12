import 'package:flutter/material.dart';
import 'package:scoreboards/widgets/championships/standing_table.dart';
import 'package:scoreboards/widgets/championships/championship_team_list.dart';
import 'package:scoreboards/widgets/championships/player_stats.dart';
import 'package:scoreboards/widgets/championships/match_list.dart';
import 'package:scoreboards/models/editions.dart';
import 'package:scoreboards/services/championship.dart';

class ChampionshipDetails extends StatefulWidget {
  final String slug;
  final Function? onViewAllTap;

  const ChampionshipDetails(
      {super.key, required this.slug, this.onViewAllTap});

  @override
  ChampionshipDetailsState createState() => ChampionshipDetailsState();
}

class ChampionshipDetailsState extends State<ChampionshipDetails> {
  Edition? edition;

  @override
  void initState() {
    super.initState();
    loadEdition();
  }

  void loadEdition() async {
    // Replace this with your actual API call
    final edit = await ChampionshipService.getEditionBySlug(widget.slug);
    setState(() {
      edition = edit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: edition == null
          ? Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  // Edition Header
                  Stack(
                    children: [
                      // Background logo
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                NetworkImage(edition!.championship.logo ?? ""),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.2),
                                BlendMode.darken),
                          ),
                        ),
                      ),
                      // Edition name
                      Container(
                        height: 120,
                        alignment: Alignment.center,
                        child: Text(
                          edition!.label ?? "",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black45,
                                offset: Offset(1, 1),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Tab Bar
                  TabBar(
                    labelColor: Colors.blueAccent,
                    unselectedLabelColor: Colors.blueGrey[600],
                    indicatorColor: Colors.blueAccent,
                    tabs: const [
                      Tab(text: 'Standings'),
                      Tab(text: 'Teams'),
                      Tab(text: 'Matchs'),
                      Tab(text: 'P. Stats'),
                    ],
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Standings Tab
                        Column(
                          children: [
                            /*Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Standings",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ), */
                            Expanded(
                              child:
                                  StandingsTable(editionId: edition!.id),
                            ),
                          ],
                        ),

                        // Teams Tab
                        ChampionshipTeamList(editionId: edition!.id),

                        // Matches Tab
                        MatchList(editionId: edition!.id),

                        // Player Stats Tab
                        PlayerStatsTable(editionId: edition!.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
