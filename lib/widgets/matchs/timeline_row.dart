import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
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
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${event.minute}${event.stoppageMinute != null && event.stoppageMinute! > 0 ? '+${event.stoppageMinute}' : ''}'",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(child: Container(width: 2, color: AppColors.divider)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _getIcon(event),
                ),
                Expanded(child: Container(width: 2, color: AppColors.divider)),
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
      case TimelineEventType.redCard:
        color = AppColors.coral;
        break;
      case TimelineEventType.yellowCard:
        color = AppColors.yellowCard;
        break;
      case TimelineEventType.goal || TimelineEventType.penaltyGoal:
        color = AppColors.mint;
        break;
      case TimelineEventType.ownGoal:
        color = AppColors.coral;
        break;
      case TimelineEventType.substitution:
        color = AppColors.textSecondary;
        break;
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
        crossAxisAlignment:
            align == TextAlign.right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            textAlign: align,
            style: GoogleFonts.hankenGrotesk(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: AppColors.textPrimary,
            ),
          ),
          if (event.description != null)
            Text(
              event.description!,
              textAlign: align,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
