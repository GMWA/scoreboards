import 'package:flutter/material.dart';

import 'package:scoreboards/shared/models/goal_enums.dart';
import 'package:scoreboards/shared/models/match.dart';
import 'package:scoreboards/shared/models/timeline_event.dart';

/// The match's events (goals, cards, substitutions) in timeline order.
List<TimelineEvent> buildTimelineEvents(Match match) {
  final List<TimelineEvent> events = [];

  // GOALS
  for (final goal in match.goals) {
    // Shootout kicks are summarised in the header's PEN score, and only
    // valid goals count: missed penalties and VAR-pending goals don't.
    if (!goal.isValid || goal.goalType == GoalType.penaltyShootout) continue;

    events.add(
      TimelineEvent(
        minute: goal.minute,
        stoppageMinute: goal.stoppageMinute,
        type: goal.isOwnGoal
            ? TimelineEventType.ownGoal
            : goal.isPenalty
                ? TimelineEventType.penaltyGoal
                : TimelineEventType.goal,
        isHome: goal.team.id == match.homeTeam.id,
        title:
            "${goal.scorer?.firstname ?? ''} ${goal.scorer?.lastname ?? 'Unknown Player'}",
        description: goal.isOwnGoal
            ? "Own Goal"
            : (goal.assist != null ? "Asst: ${goal.assist!.lastname}" : null),
      ),
    );
  }

  // CARDS
  for (final card in match.cards) {
    // A staff card shows the role under the name, like the website.
    final details = [
      if (card.isStaff) card.staffRoleLabel,
      if (card.isSecondYellow) 'Second yellow',
    ].join(' · ');
    events.add(
      TimelineEvent(
          minute: card.minute,
          stoppageMinute: card.stoppageMinute,
          type: card.cardType == 'red' || card.isSecondYellow
              ? TimelineEventType.redCard
              : TimelineEventType.yellowCard,
          isHome: card.team.id == match.homeTeam.id,
          title: card.isStaff
              ? card.staffName
              : card.player == null
                  ? 'Unknown Player'
                  : "${card.player!.firstname} ${card.player!.lastname}",
          description: details.isEmpty ? null : details),
    );
  }

  // SUBSTITUTIONS
  for (final sub in match.substitutions) {
    events.add(
      TimelineEvent(
        minute: sub.minute,
        stoppageMinute: sub.stoppageMinute,
        type: TimelineEventType.substitution,
        isHome: sub.team.id == match.homeTeam.id,
        title: sub.playerIn.lastname,
        description: '⬅ ${sub.playerOut.lastname}',
      ),
    );
  }

  events.sort((a, b) {
    int cmp = a.minute.compareTo(b.minute);
    if (cmp != 0) return cmp;
    return (a.stoppageMinute ?? 0).compareTo(b.stoppageMinute ?? 0);
  });
  return events;
}

IconData timelineIcon(TimelineEventType type) {
  switch (type) {
    case TimelineEventType.goal ||
          TimelineEventType.penaltyGoal ||
          TimelineEventType.ownGoal:
      return Icons.sports_soccer;
    case TimelineEventType.yellowCard:
      return Icons.square;
    case TimelineEventType.redCard:
      return Icons.stop;
    case TimelineEventType.substitution:
      return Icons.sync_alt;
  }
}
