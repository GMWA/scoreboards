import 'package:scoreboards/models/match_team.dart';
import 'package:scoreboards/enums/goals.dart';

class GoalPlayer {
  final int id;
  final String slug;
  final String firstname;
  final String lastname;
  final String? logo;
  final int? jerseyNumber;

  GoalPlayer({
    required this.id,
    required this.slug,
    required this.firstname,
    required this.lastname,
    this.logo,
    this.jerseyNumber,
  });

  factory GoalPlayer.fromJson(Map<String, dynamic> json) {
    return GoalPlayer(
      id: json['id'],
      slug: json['slug'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      logo: json['logo'],
      jerseyNumber: json['jersey_number'],
    );
  }
}

class Goal {
  final int id;
  final int matchId;
  final MatchTeam team;
  final int minute;
  final int? stoppageMinute;
  final bool isOwnGoal;
  final bool isPenalty;
  final GoalPlayer? scorer;
  final GoalPlayer? assist;
  final GoalStatus status;
  final GoalType goalType;
  final int? shootoutOrder;

  Goal({
    required this.id,
    required this.matchId,
    required this.team,
    required this.minute,
    this.stoppageMinute,
    required this.isOwnGoal,
    required this.isPenalty,
    this.scorer,
    this.assist,
    required this.status,
    required this.goalType,
    this.shootoutOrder,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      matchId: json['match'],
      team: MatchTeam.fromJson(json['team']),
      minute: json['minute'],
      stoppageMinute: json['stoppage_minute'] ?? 0,
      isOwnGoal: json['is_csc'] ?? false,
      isPenalty: json['is_penalty'] ?? false,
      scorer:
          json['scorer'] != null ? GoalPlayer.fromJson(json['scorer']) : null,
      assist: json['assister'] != null
          ? GoalPlayer.fromJson(json['assister'])
          : null,
      status: GoalStatus.fromString(json['status'] ?? 'valid'),
      goalType: GoalType.fromString(json['goal_type'] ?? 'normal'),
      shootoutOrder: json['shootout_order'],
    );
  }

  // Helper for UI: Check if the goal actually counts on the scoreboard
  bool get isValid => status == GoalStatus.valid;

  // Helper for UI: Get display time (e.g., 45+2)
  String get displayTime {
    if (goalType == GoalType.penaltyShootout) return "PSO";
    if (stoppageMinute! > 0) return "$minute+$stoppageMinute'";
    return "$minute'";
  }
}
