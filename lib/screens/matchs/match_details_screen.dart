import 'package:flutter/material.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/widgets/matchs/match_timeline.dart';
import 'package:scoreboards/widgets/matchs/match_header.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMatch();
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
          errorMessage = "Could not find match details.";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = AppColors.darkBg;
    const Color brandRed = AppColors.brand;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          match?.edition.label!.toUpperCase() ?? "MATCH DETAILS",
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Colors.white70,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _buildBody(darkBg, brandRed),
    );
  }

  Widget _buildBody(Color darkBg, Color brandRed) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFE64C52)));
    }

    if (match == null) {
      return Center(
          child: Text(errorMessage ?? "Match not found",
              style: const TextStyle(
                  color: Colors.white54, fontFamily: 'Lexend')));
    }

    return Column(
      children: [
        MatchHeader(match: match!),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            children: [
              const Text(
                "MATCH TIMELINE",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 1, color: Colors.white10)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.5),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: MatchTimeline(
              events: buildTimelineEvents(match!),
            ),
          ),
        ),
      ],
    );
  }
}
