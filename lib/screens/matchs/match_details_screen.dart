import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/models/lineup.dart';
import 'package:scoreboards/widgets/matchs/match_timeline.dart';
import 'package:scoreboards/widgets/matchs/match_header.dart';
import 'package:scoreboards/widgets/matchs/motm_voting_tab.dart';
import 'package:scoreboards/services/matchs.dart';
import 'package:scoreboards/helpers/utils.dart';

class MatchDetailsScreen extends StatefulWidget {
  final String slug;
  const MatchDetailsScreen({super.key, required this.slug});

  @override
  MatchDetailsScreenState createState() => MatchDetailsScreenState();
}

class MatchDetailsScreenState extends State<MatchDetailsScreen> {
  Match? match;
  bool isLoading = true;
  String? errorMessage;
  Timer? _liveRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadMatch();
    _liveRefreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _refreshIfLive());
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    super.dispose();
  }

  /// Quietly reloads a live (or about-to-start) match so the score, events
  /// and lineups stay current; failures keep what's on screen.
  Future<void> _refreshIfLive() async {
    final current = match;
    final appVisible =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    if (current == null || !appVisible || !current.isLiveOrDue) return;

    try {
      final data = await MatchService.getMatchBySlug(widget.slug);
      if (mounted) setState(() => match = data);
    } catch (_) {
      // Keep showing the last good data; the next tick will retry.
    }
  }

  Future<void> _loadMatch() async {
    try {
      final data = await MatchService.getMatchBySlug(widget.slug);
      if (mounted) {
        setState(() {
          match = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Could not find match details.';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(
          match?.edition.label?.toUpperCase() ?? 'MATCH CENTER',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.coral));
    }

    if (match == null) {
      return Center(
        child: Text(
          errorMessage ?? 'Match not found',
          style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          MatchHeader(match: match!),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: TabBar(
              // Five tabs don't fit side by side on a ~360dp phone (labels
              // got clipped); scrollable tabs size to their labels, and
              // center when they do fit.
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              labelColor: AppColors.coral,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.coral,
              indicatorWeight: 2,
              labelStyle: GoogleFonts.hankenGrotesk(
                  fontSize: 13.5, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.hankenGrotesk(
                  fontSize: 13.5, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Timeline'),
                Tab(text: 'Lineups'),
                Tab(text: 'MOTM'),
                Tab(text: 'Stats'),
                Tab(text: 'H2H'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTimelineTab(),
                _LineupsTab(match: match!),
                MotmVotingTab(matchId: match!.id),
                const _NotAvailableTab(
                  message:
                      'Match statistics (possession, shots, fouls) aren\'t wired up to live data yet.',
                ),
                const _NotAvailableTab(
                  message: 'Head-to-head history isn\'t wired up to live data yet.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: MatchTimeline(events: buildTimelineEvents(match!)),
    );
  }
}

/// Safe "F. " initial prefix — some player records have an empty firstname,
/// and indexing into an empty string (`firstname[0]`) throws a RangeError
/// that used to crash this whole tab (and, since TabBarView builds all tabs
/// eagerly, the entire Match Center) for any match with published lineups.
String _initial(String firstname) {
  return firstname.isNotEmpty ? '${firstname[0]}. ' : '';
}

class _LineupsTab extends StatelessWidget {
  final Match match;
  const _LineupsTab({required this.match});

  @override
  Widget build(BuildContext context) {
    List<MatchLineup> players(int teamId, {required bool starting}) => match.lineups
        .where((l) => l.team.id == teamId && l.isStarting == starting)
        .toList();

    final home = players(match.homeTeam.id, starting: true);
    final away = players(match.awayTeam.id, starting: true);
    final homeSubs = players(match.homeTeam.id, starting: false);
    final awaySubs = players(match.awayTeam.id, starting: false);

    if (home.isEmpty && away.isEmpty && homeSubs.isEmpty && awaySubs.isEmpty) {
      return const _NotAvailableTab(message: 'Lineups have not been published yet.');
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                match.homeTeam.name,
                style: GoogleFonts.hankenGrotesk(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            Expanded(
              child: Text(
                match.awayTeam.name,
                textAlign: TextAlign.right,
                style: GoogleFonts.hankenGrotesk(
                    color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._pairedRows(home, away),
        if (homeSubs.isNotEmpty || awaySubs.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'SUBSTITUTES',
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          ..._pairedRows(homeSubs, awaySubs),
        ],
      ],
    );
  }

  List<Widget> _pairedRows(List<MatchLineup> home, List<MatchLineup> away) {
    final int rows = home.length > away.length ? home.length : away.length;
    return [
      for (int i = 0; i < rows; i++)
        _lineupRow(i < home.length ? home[i] : null, i < away.length ? away[i] : null),
    ];
  }

  Widget _lineupRow(MatchLineup? h, MatchLineup? a) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    h?.player.jerseyNumber?.toString() ?? '',
                    style: GoogleFonts.hankenGrotesk(
                        color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    h != null ? '${_initial(h.player.firstname)}${h.player.lastname}' : '',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    a != null ? '${_initial(a.player.firstname)}${a.player.lastname}' : '',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Text(
                    a?.player.jerseyNumber?.toString() ?? '',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.hankenGrotesk(
                        color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotAvailableTab extends StatelessWidget {
  final String message;
  const _NotAvailableTab({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}
