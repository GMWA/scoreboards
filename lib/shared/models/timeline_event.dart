enum TimelineEventType {
  goal,
  ownGoal,
  penaltyGoal,
  yellowCard,
  redCard,
  substitution,
}

class TimelineEvent {
  final int minute;
  final TimelineEventType type;
  final bool isHome;
  final String title;
  final int? stoppageMinute;
  final String? description;

  TimelineEvent({
    required this.minute,
    required this.type,
    required this.isHome,
    required this.title,
    this.description,
    this.stoppageMinute

  });
}
