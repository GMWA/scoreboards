import 'package:flutter/material.dart';
import 'package:scoreboards/helpers/utils.dart';
import 'package:scoreboards/models/timeline_event.dart';


class TimelineRow extends StatelessWidget {
  final TimelineEvent event;

  const TimelineRow({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: event.isHome 
              ? _EventBubble(event: event, align: TextAlign.right) 
              : const SizedBox(),
          ),

          SizedBox(
            width: 60,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${event.minute}${event.stoppageMinute != null && event.stoppageMinute! > 0 ? '+${event.stoppageMinute}' : ''}'",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Container(width: 2, color: Colors.grey.shade200),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _getIcon(event),
                ),
                Expanded(
                  child: Container(width: 2, color: Colors.grey.shade200),
                ),
              ],
            ),
          ),

          Expanded(
            child: !event.isHome 
              ? _EventBubble(event: event, align: TextAlign.left) 
              : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _getIcon(TimelineEvent event) {
    Color color;
    IconData icon = timelineIcon(event.type);

    switch (event.type) {
      case TimelineEventType.redCard: color = Colors.red; break;
      case TimelineEventType.yellowCard: color = Colors.amber; break;
      case TimelineEventType.goal: color = Colors.green; break;
      case TimelineEventType.ownGoal: color = Colors.red; break;
      case TimelineEventType.substitution: color = Colors.blue; break;
      default: color = Colors.grey;
    }

    return Icon(icon, color: color, size: 18);
  }
}

class _EventBubble extends StatelessWidget {
  final TimelineEvent event;
  final TextAlign align;

  const _EventBubble({required this.event, required this.align});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: align == TextAlign.right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            textAlign: align,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (event.description != null)
            Text(
              event.description!,
              textAlign: align,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }
}
