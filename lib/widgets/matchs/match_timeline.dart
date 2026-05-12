import 'package:flutter/material.dart';
import 'package:scoreboards/widgets/matchs/timeline_row.dart';
import 'package:scoreboards/models/timeline_event.dart';


class MatchTimeline extends StatelessWidget {
  final List<TimelineEvent> events;

  const MatchTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(child: Text("No match events yet"));
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
