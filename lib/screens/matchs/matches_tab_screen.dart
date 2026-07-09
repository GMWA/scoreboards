import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/services/matchs.dart';
import 'package:scoreboards/screens/matchs/match_details_screen.dart';

/// Landing screen for the "Matches" bottom-nav tab (the design's "Match
/// Center"). Shows the currently live match if there is one, otherwise the
/// next upcoming match, otherwise an empty state pointing back to Scores.
class MatchesTabScreen extends StatefulWidget {
  const MatchesTabScreen({super.key});

  @override
  State<MatchesTabScreen> createState() => _MatchesTabScreenState();
}

class _MatchesTabScreenState extends State<MatchesTabScreen> {
  late Future<List<MatchBase>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadDefaultMatch();
  }

  Future<List<MatchBase>> _loadDefaultMatch() async {
    try {
      final live = await MatchService.getLiveMatches();
      if (live.isNotEmpty) return live;
    } catch (_) {
      // fall through to "no match" state below
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FutureBuilder<List<MatchBase>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.coral),
              );
            }

            final matches = snapshot.data ?? [];
            if (matches.isEmpty) {
              return _buildEmptyState(context);
            }

            // Embed the existing Match Center screen for the first live
            // match. Reusing MatchDetailsScreen keeps the Timeline/tabs
            // implementation in one place.
            return MatchDetailsScreen(slug: matches.first.slug);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_soccer, size: 56, color: AppColors.border),
            const SizedBox(height: 16),
            Text(
              'No live match right now',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pick a match from Scores to see live details here once it kicks off.',
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
