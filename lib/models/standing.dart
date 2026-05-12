import 'team.dart';

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
