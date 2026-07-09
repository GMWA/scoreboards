import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/services/matchs.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/enums/matchs.dart';
import 'package:scoreboards/widgets/ui/match_card.dart';
import 'package:scoreboards/helpers/utils.dart';
import 'package:scoreboards/models/favorite_item.dart';
import 'package:scoreboards/services/favorites_service.dart';
import 'package:go_router/go_router.dart';

enum _ScoreFilter { all, live, upcoming, finished }

class MatchListScreen extends StatefulWidget {
  final Function? onViewAllTap;

  const MatchListScreen({super.key, this.onViewAllTap});

  @override
  MatchListScreenState createState() => MatchListScreenState();
}

class MatchListScreenState extends State<MatchListScreen> {
  DateTime selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  late List<DateTime> _dateRange;
  List<MatchBase> _matches = [];
  List<Map<String, dynamic>> _groupedMatches = [];
  bool isLoading = false;
  bool isLive = false;
  _ScoreFilter _filter = _ScoreFilter.all;

  @override
  void initState() {
    super.initState();
    _generateDateRange();
    _initToday();
  }

  void _generateDateRange() {
    final now = DateTime.now();
    _dateRange = List.generate(365, (index) {
      return now.subtract(Duration(days: 182 - index));
    });
  }

  void _initToday() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectDate(DateTime.now(), scrollTo: true);
    });
  }

  void _selectDate(DateTime date, {bool scrollTo = true}) {
    setState(() {
      selectedDate = date;
      isLive = false;
    });

    if (scrollTo) {
      final index = _dateRange.indexWhere((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day);
      if (index != -1) _centerDate(index);
    }

    _loadMatchesForDate(date);
  }

  void _loadMatchesForDate(DateTime date) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final matches = isLive
          ? await MatchService.getLiveMatches()
          : await MatchService.getMatchsByDay(date);

      if (!mounted) return;

      setState(() {
        _matches = matches;
        _applyFilter();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load matches.")),
      );
    }
  }

  void _applyFilter() {
    Iterable<MatchBase> filtered = _matches;
    switch (_filter) {
      case _ScoreFilter.live:
        filtered = _matches.where((m) => m.status == MatchStatus.inProgress);
        break;
      case _ScoreFilter.upcoming:
        filtered = _matches.where((m) => m.status == MatchStatus.planned);
        break;
      case _ScoreFilter.finished:
        filtered = _matches.where((m) =>
            m.status == MatchStatus.completed || m.status == MatchStatus.awarded);
        break;
      case _ScoreFilter.all:
        break;
    }

    // Live matches float to the top, regardless of scheduled kickoff order —
    // the thing people most want to see first on a day with mixed
    // live/upcoming/finished matches. Partitioned (not List.sort, which
    // isn't guaranteed stable) so relative order within each group is
    // otherwise preserved.
    final live = <MatchBase>[];
    final rest = <MatchBase>[];
    for (final m in filtered) {
      (m.status == MatchStatus.inProgress ? live : rest).add(m);
    }

    _groupedMatches = groupMatchesByEditionData([...live, ...rest]);
  }

  void _setFilter(_ScoreFilter filter) {
    setState(() {
      _filter = filter;
      _applyFilter();
    });
  }

  void _centerDate(int index) {
    if (!_scrollController.hasClients) return;

    const double itemWidth = 44.0;
    const double itemMargin = 4.0;
    const double totalItemWidth = itemWidth + (itemMargin * 2);

    final screenWidth = MediaQuery.of(context).size.width;

    final double offset = (index * totalItemWidth) -
        (screenWidth / 2) +
        (totalItemWidth / 2) +
        16;

    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _showLiveMatches() {
    final today = DateTime.now();

    setState(() {
      isLive = true;
      selectedDate = today;
    });

    final index = _dateRange.indexWhere((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);

    if (index != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _centerDate(index);
      });
    }

    _loadMatchesForDate(today);
  }

  void _openCalendar() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        isLive = false;

        _dateRange = List.generate(365, (index) {
          return picked.subtract(Duration(days: 182 - index));
        });
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final index = _dateRange.indexWhere((date) =>
            date.year == picked.year &&
            date.month == picked.month &&
            date.day == picked.day);

        if (index != -1) {
          _centerDate(index);
        }

        _loadMatchesForDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Scoreboards',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined,
                color: AppColors.textPrimary),
            onPressed: _openCalendar,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFollowingRow(),
          _buildDateSelector(),
          _buildFilterChips(),
          const SizedBox(height: 4),
          Expanded(child: _buildMatchList()),
        ],
      ),
    );
  }

  /// Personalization row shown above the date strip once the user has
  /// followed at least one team/competition — tapping a chip jumps straight
  /// to that team or competition. Hidden entirely until there's something to
  /// show, so it never costs a brand-new user any screen space.
  Widget _buildFollowingRow() {
    return AnimatedBuilder(
      animation: FavoritesService.instance,
      builder: (context, _) {
        final followed = FavoritesService.instance.allFollowed;
        if (followed.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 62,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: followed.length,
            itemBuilder: (context, index) {
              final item = followed[index];
              return GestureDetector(
                onTap: () {
                  context.push(item.kind == FavoriteKind.team
                      ? '/teams/${item.slug}'
                      : '/championships/${item.slug}');
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        alignment: Alignment.center,
                        child: item.logo != null && item.logo!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(
                                  item.logo!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    item.kind == FavoriteKind.team
                                        ? Icons.shield_outlined
                                        : Icons.emoji_events,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : Icon(
                                item.kind == FavoriteKind.team
                                    ? Icons.shield_outlined
                                    : Icons.emoji_events,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        item.name,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    Widget chip(String label, _ScoreFilter value) {
      final bool active = _filter == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => _setFilter(value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: active ? AppColors.surfaceAlt : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Row(
        children: [
          chip('All', _ScoreFilter.all),
          chip('● Live', _ScoreFilter.live),
          chip('Upcoming', _ScoreFilter.upcoming),
          chip('Finished', _ScoreFilter.finished),
        ],
      ),
    );
  }

  Widget _buildLiveButton() {
    return GestureDetector(
      onTap: _showLiveMatches,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isLive ? AppColors.coral : AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLive ? AppColors.coral : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isLive
              ? [
                  BoxShadow(
                      color: AppColors.coral.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1)
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLive ? Icons.sensors : Icons.sensors_off_outlined,
              color: isLive ? Colors.white : AppColors.textSecondary,
              size: 13,
            ),
            const SizedBox(height: 3),
            Text(
              'LIVE',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: isLive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _dateRange.length + 1,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildLiveButton();
          }

          final date = _dateRange[index - 1];
          final isSelected = !isLive && isSameDay(date, selectedDate);
          final isToday = isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => _selectDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.coral : AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.coral : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('dd').format(date),
                    style: GoogleFonts.archivo(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.coral,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildMatchList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.coral));
    }

    if (_groupedMatches.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: _groupedMatches.length,
      itemBuilder: (context, groupIndex) {
        final group = _groupedMatches[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                context.push('/championships/${group['slug']}');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: group['logo'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                group['logo'],
                                width: 18,
                                height: 18,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.emoji_events,
                                    size: 14,
                                    color: AppColors.textSecondary),
                              ),
                            )
                          : const Icon(Icons.emoji_events,
                              size: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        group['label'].toString(),
                        style: GoogleFonts.hankenGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: AppColors.coral, size: 12),
                  ],
                ),
              ),
            ),
            ...(group['matches'] as List<MatchBase>).map(
              (match) => MatchCard(match: match),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_soccer, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            'No matches in this view.',
            style: GoogleFonts.hankenGrotesk(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
