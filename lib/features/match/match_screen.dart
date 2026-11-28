import 'dart:async';
import 'package:scoreboards/core/l10n.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/core/config.dart';
import 'package:scoreboards/shared/models/match.dart';
import 'package:scoreboards/shared/models/lineup.dart';
import 'package:scoreboards/features/match/widgets/match_timeline.dart';
import 'package:scoreboards/features/match/widgets/match_header.dart';
import 'package:scoreboards/features/match/widgets/match_statistics_tab.dart';
import 'package:scoreboards/features/motm/motm_voting_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/core/links.dart';
import 'package:scoreboards/core/router.dart';
import 'package:scoreboards/features/match/match_providers.dart';
import 'package:scoreboards/features/match/timeline.dart';
import 'package:share_plus/share_plus.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final String slug;
  const MatchScreen({super.key, required this.slug});

  @override
  MatchScreenState createState() => MatchScreenState();
}

class MatchScreenState extends ConsumerState<MatchScreen> {
  Timer? _liveRefreshTimer;
  final ScrollController _outerScroll = ScrollController();
  final GlobalKey _headerKey = GlobalKey();
  bool _headerCollapsed = false;

  /// Top colour of MatchHeader's gradient, so the pinned bar blends into it.
  static final Color _headerTopColor =
      Color.alphaBlend(AppColors.coral.withValues(alpha: 0.15), AppColors.bg);

  @override
  void initState() {
    super.initState();
    _outerScroll.addListener(_updateHeaderCollapsed);
    _liveRefreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _refreshIfLive());
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    _outerScroll.dispose();
    super.dispose();
  }

  /// Shows the compact score once most of the full header has scrolled away.
  void _updateHeaderCollapsed() {
    final headerHeight = _headerKey.currentContext?.size?.height;
    if (headerHeight == null) return;
    final collapsed = _outerScroll.offset > headerHeight - 40;
    if (collapsed != _headerCollapsed) {
      setState(() => _headerCollapsed = collapsed);
    }
  }

  /// Quietly reloads a live (or about-to-start) match so the score, events
  /// and lineups stay current; a failure keeps what's on screen.
  void _refreshIfLive() {
    final current = ref.read(matchProvider(widget.slug)).value;
    final appVisible =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    if (current == null || !appVisible || !current.isLiveOrDue) return;
    ref.invalidate(matchProvider(widget.slug));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchProvider(widget.slug));
    final current = state.value;
    if (current == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          elevation: 0,
          leading: _backButton(context),
        ),
        body: !state.hasError
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.coral))
            : Center(
                child: Text(
                  context.l10n.matchNotFound,
                  style:
                      GoogleFonts.hankenGrotesk(color: AppColors.textSecondary),
                ),
              ),
      );
    }

    // The Stats tab only appears when the match has statistics, like on the
    // website; a live refresh can add it.
    final statistics = current.statistics;
    final tabs = <(String, Widget)>[
      (context.l10n.tabTimeline, _buildTimelineTab(current)),
      if (statistics != null)
        (
          context.l10n.tabStats,
          MatchStatisticsTab(
            statistics: statistics,
            homeName: current.homeTeam.name,
            awayName: current.awayTeam.name,
          ),
        ),
      (context.l10n.tabLineups, _LineupsTab(match: current)),
      (context.l10n.tabMotm, MotmVotingTab(matchId: current.id)),
    ];

    // Full header on open; scrolling any tab scrolls it away while the top
    // bar (with a compact score) and the tab bar stay pinned, so the tab
    // content gets most of the screen.
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: NestedScrollView(
          controller: _outerScroll,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              backgroundColor: _headerTopColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: _backButton(context),
              titleSpacing: 0,
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _headerCollapsed
                    ? MatchScoreBar(
                        key: const ValueKey('score'), match: current)
                    : Text(
                        current.edition.label?.toUpperCase() ?? context.l10n.matchCenter,
                        key: const ValueKey('title'),
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textSecondary,
                        ),
                      ),
              ),
              // As wide as the back button, so the compact score stays
              // centred.
              actions: [
                Builder(
                  builder: (buttonContext) => IconButton(
                    tooltip: context.l10n.shareMatch,
                    icon: const Icon(Icons.share_outlined,
                        color: AppColors.textPrimary),
                    onPressed: () => _share(buttonContext, current),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: KeyedSubtree(
                  key: _headerKey, child: MatchHeader(match: current)),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate:
                  _TabBarHeader(_buildTabBar([for (final t in tabs) t.$1])),
            ),
          ],
          body: TabBarView(children: [for (final t in tabs) t.$2]),
        ),
      ),
    );
  }

  // A match opened from a website link has no screen under it: back then
  // goes to the scores.
  Widget _backButton(BuildContext context) => BackButton(
        color: AppColors.textPrimary,
        onPressed: () => popOrGoHome(context),
      );

  // Shares the website link, like an article: the receiving app builds the
  // preview card from the match page's title and image.
  Future<void> _share(BuildContext buttonContext, Match m) async {
    // iPad anchors the share sheet to the button.
    final box = buttonContext.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(ShareParams(
      uri: matchWebLink(AppConfig.website, widget.slug),
      subject: '${m.homeTeam.name} vs ${m.awayTeam.name}',
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ));
  }

  TabBar _buildTabBar(List<String> labels) {
    return TabBar(
      // Five tabs don't fit side by side on a ~360dp phone (labels got
      // clipped); scrollable tabs size to their labels, and center when
      // they do fit.
      isScrollable: true,
      tabAlignment: TabAlignment.center,
      labelColor: AppColors.coral,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.coral,
      indicatorWeight: 2,
      dividerColor: AppColors.divider,
      labelStyle: GoogleFonts.hankenGrotesk(
          fontSize: 13.5, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.hankenGrotesk(
          fontSize: 13.5, fontWeight: FontWeight.w600),
      tabs: [for (final label in labels) Tab(text: label)],
    );
  }

  Widget _buildTimelineTab(Match match) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: MatchTimeline(events: buildTimelineEvents(match, context.l10n)),
    );
  }
}

class _TabBarHeader extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarHeader(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(color: AppColors.bg, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarHeader oldDelegate) => tabBar != oldDelegate.tabBar;
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
    List<MatchLineup> players(int teamId, {required bool starting}) =>
        match.lineups
            .where((l) => l.team.id == teamId && l.isStarting == starting)
            .toList();

    final home = players(match.homeTeam.id, starting: true);
    final away = players(match.awayTeam.id, starting: true);
    final homeSubs = players(match.homeTeam.id, starting: false);
    final awaySubs = players(match.awayTeam.id, starting: false);

    if (home.isEmpty && away.isEmpty && homeSubs.isEmpty && awaySubs.isEmpty) {
      return _NotAvailableTab(
          message: context.l10n.lineupsNotPublished);
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
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
            Expanded(
              child: Text(
                match.awayTeam.name,
                textAlign: TextAlign.right,
                style: GoogleFonts.hankenGrotesk(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._pairedRows(home, away),
        if (homeSubs.isNotEmpty || awaySubs.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            context.l10n.substitutes,
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
        _lineupRow(
            i < home.length ? home[i] : null, i < away.length ? away[i] : null),
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
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    h != null
                        ? '${_initial(h.player.firstname)}${h.player.lastname}'
                        : '',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                        color: AppColors.textPrimary, fontSize: 13),
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
                    a != null
                        ? '${_initial(a.player.firstname)}${a.player.lastname}'
                        : '',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                        color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Text(
                    a?.player.jerseyNumber?.toString() ?? '',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.hankenGrotesk(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
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
          style: GoogleFonts.hankenGrotesk(
              color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}
