import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoreboards/services/matchs.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/widgets/ui/match_card.dart';
import 'package:scoreboards/helpers/utils.dart';
import 'package:go_router/go_router.dart';

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

  // Constants for sizing
  final double itemWidth = 50.0;
  final double itemMargin = 2.0;

  @override
  void initState() {
    super.initState();
    _generateDateRange();
    _initToday();
  }

  void _generateDateRange() {
    final now = DateTime.now();
    // Generate 180 days before and 180 days after today
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
        _groupedMatches = groupMatchesByEditionData(matches);
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

  void _centerDate(int index) {
    if (!_scrollController.hasClients) return;

    const double itemWidth = 55.0;
    const double itemMargin = 5.0;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
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
    const Color darkBg = Color(0xFF0A0A0A);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "SCOREBOARDS",
          style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.calendar_month_outlined, color: Colors.white),
            onPressed: _openCalendar,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: 8),
          Expanded(child: _buildMatchList()),
        ],
      ),
    );
  }

  Widget _buildLiveButton(Color brandRed, Color surface) {
    return GestureDetector(
      onTap: _showLiveMatches,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 65,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isLive ? brandRed : surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLive ? brandRed : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: isLive
              ? [
                  BoxShadow(
                      color: brandRed.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1)
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLive ? Icons.sensors : Icons.sensors_off_outlined,
              color: isLive ? Colors.white : Colors.grey.shade600,
              size: 16,
            ),
            const SizedBox(height: 4),
            Text(
              "LIVE",
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isLive ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    const Color brandRed = Color(0xFFE64C52);
    const Color surface = Color(0xFF1A1A1A);

    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(
          bottom: BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _dateRange.length + 1,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildLiveButton(brandRed, surface);
          }

          final date = _dateRange[index - 1];
          final isSelected = !isLive && isSameDay(date, selectedDate);
          final isToday = isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => _selectDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? brandRed : surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? brandRed : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : brandRed,
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
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFE64C52)));
    }

    if (_matches.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      itemCount: _groupedMatches.length,
      itemBuilder: (context, groupIndex) {
        final group = _groupedMatches[groupIndex];
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                context.push('/championships/${group['slug']}');
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Row(
                  children: [
                    if (group['logo'] != null)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          group['logo'],
                          width: 24,
                          height: 24,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.emoji_events,
                              size: 20,
                              color: Colors.white24),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        group['label'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFFE64C52),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
            ...(group['matches'] as List<MatchBase>)
                .map((match) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MatchCard(match: match),
                    ))
                .toList(),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_soccer, size: 80, color: Colors.white10),
            const SizedBox(height: 16),
            Text(
              isLive ? "NO LIVE MATCHES" : "NO MATCHES SCHEDULED",
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w800,
                color: Colors.white30,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
