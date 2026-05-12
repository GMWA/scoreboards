import 'package:flutter/material.dart';
import 'package:scoreboards/models/standing.dart';
import 'package:scoreboards/models/match.dart';
import 'package:scoreboards/enums/goals.dart';
import 'package:scoreboards/models/timeline_event.dart';

int standingSort(Standing a, Standing b) {
  // 1. Primary Rule: Points (Highest first)
  int pointsComparison = b.points.compareTo(a.points);
  if (pointsComparison != 0) return pointsComparison;

  // 2. Tiebreaker: Goal Difference (Highest first)
  int goalDiffA = a.goalsFor - a.goalsAgainst;
  int goalDiffB = b.goalsFor - b.goalsAgainst;
  int gdComparison = goalDiffB.compareTo(goalDiffA);
  if (gdComparison != 0) return gdComparison;

  // 3. Tiebreaker: Goals Scored (Highest first)
  int goalsForComparison = b.goalsFor.compareTo(a.goalsFor);
  if (goalsForComparison != 0) return goalsForComparison;

  // 4. Tiebreaker: Most Wins (Highest first)
  int winsComparison = b.wins.compareTo(a.wins);
  if (winsComparison != 0) return winsComparison;

  // 5. Final Tiebreaker: Alphabetical (Stable fallback)
  return a.participation.team.name.compareTo(b.participation.team.name);
}

List<Map<String, dynamic>> groupMatchesByEditionData(List<MatchBase> matches) {
  final Map<int, Map<String, dynamic>> editionGroups = {};

  for (var match in matches) {
    final edition = match.edition;
    final editionId = edition.id;
    final editionSlug = edition.slug;

    if (!editionGroups.containsKey(editionId)) {
      editionGroups[editionId] = {
        'id': editionId,
        'slug': editionSlug,
        'label': edition.label ?? edition.year,
        'logo': edition.championship.logo,
        'championshipId': edition.championship.id,
        'matches': <MatchBase>[],
      };
    }

    editionGroups[editionId]!['matches'].add(match);
  }

  return editionGroups.values.toList();
}

List<TimelineEvent> buildTimelineEvents(Match match) {
  final List<TimelineEvent> events = [];

  // GOALS
  for (final goal in match.goals) {
    if (goal.status == GoalStatus.cancelled) continue;

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
            "${goal.scorer?.firstname ?? ''} ${goal.scorer?.lastname ?? 'Unknown'}",
        description: goal.isOwnGoal
            ? "Own Goal"
            : (goal.assist != null ? "Asst: ${goal.assist!.lastname}" : null),
      ),
    );
  }

  // CARDS
  for (final card in match.cards) {
    events.add(
      TimelineEvent(
          minute: card.minute,
          stoppageMinute: card.stoppageMinute,
          type: card.cardType == 'red'
              ? TimelineEventType.redCard
              : TimelineEventType.yellowCard,
          isHome: card.team.id == match.homeTeam.id,
          title: "${card.player!.firstname} ${card.player!.lastname}"),
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
