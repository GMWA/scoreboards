import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/services/matchs.dart';
import 'package:scoreboards/widgets/ui/match_card.dart';

/// An edition's matches, loaded a page at a time as the user scrolls.
class MatchList extends StatefulWidget {
  final int editionId;
  final String status; // Optional: "scheduled", "played", etc.

  const MatchList({
    super.key,
    required this.editionId,
    this.status = "",
  });

  @override
  State<MatchList> createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  final List<MatchBase> _matches = [];
  Uri? _next;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _failed = false;
    });

    try {
      final page = await MatchService.getMatchsByEditionPage(
        widget.editionId,
        status: widget.status,
        next: _next,
      );
      if (!mounted) return;
      setState(() {
        _matches.addAll(page.items);
        _next = page.next;
        _hasMore = page.next != null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _failed = true;
      });
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 600) _loadNextPage();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_matches.isEmpty) {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator(color: AppColors.coral));
      }
      if (_failed) {
        return Center(child: _retryButton('Error loading matches'));
      }
      return Center(
          child: Text('No matches available',
              style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)));
    }

    final bool showFooter = _hasMore || _failed;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _matches.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _matches.length) return MatchCard(match: _matches[index]);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: _failed
                  ? _retryButton('Could not load more matches')
                  : const CircularProgressIndicator(color: AppColors.coral),
            ),
          );
        },
      ),
    );
  }

  Widget _retryButton(String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message,
            style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary)),
        TextButton(
          onPressed: _loadNextPage,
          child: Text('RETRY',
              style: GoogleFonts.hankenGrotesk(
                  color: AppColors.coral, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
