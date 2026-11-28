import 'package:flutter/material.dart';
import 'package:scoreboards/core/l10n.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/features/match/widgets/timeline_row.dart';
import 'package:scoreboards/shared/models/timeline_event.dart';

class MatchTimeline extends StatelessWidget {
  final List<TimelineEvent> events;

  const MatchTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noMatchEvents,
          style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return TimelineRow(event: events[index]);
      },
    );
  }
}
