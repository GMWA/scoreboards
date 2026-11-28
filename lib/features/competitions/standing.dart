import 'package:scoreboards/shared/models/team.dart';

class Participation {
  final int id;
  final TeamLookup team;
  final String? group;

  Participation({
    required this.id,
    required this.team,
    this.group,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'],
      team: TeamLookup.fromJson(json['team']),
      group: json['group'],
    );
  }
}

class Standing {
  final int id;
  final Participation participation;
  final int points;
  final int played;
  final int wins;
  final int drawn;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int goalsDifference;

  Standing({
    required this.id,
    required this.participation,
    required this.points,
    required this.played,
    required this.wins,
    required this.drawn,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalsDifference,
  });

  factory Standing.fromJson(Map<String, dynamic> json) {
    return Standing(
      id: json['id'],
      participation: Participation.fromJson(json['participation']),
      points: json['points'],
      played: json['matches_played'],
      wins: json['wins'],
      drawn: json['draws'],
      losses: json['losses'],
      goalsFor: json['goals_for'],
      goalsAgainst: json['goals_against'],
      goalsDifference: json['goals_for'] - json['goals_against'],
    );
  }
}

/// Table order: points, goal difference, goals scored, wins, then name.
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
