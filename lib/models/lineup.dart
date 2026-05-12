import 'package:scoreboards/models/match_team.dart';
import 'package:scoreboards/models/player.dart';

class MatchLineup {
  final int id;
  final int match;
  final MatchTeam team;
  final PlayerLookup player;
  final int minutesPlayed;
  final bool isStarting;
  final bool isCaptain;
  final num points;
  final String? position;

  MatchLineup({
    required this.id,
    required this.match,
    required this.team,
    required this.player,
    required this.minutesPlayed,
    required this.isStarting,
    required this.isCaptain,
    required this.points,
    this.position,
  });

  factory MatchLineup.fromJson(Map<String, dynamic> json) {
    return MatchLineup(
      id: json['id'],
      match: json['match'],
      team: MatchTeam.fromJson(json['team']),
      player: PlayerLookup.fromJson(json['player']),
      minutesPlayed: json['minutes_played'],
      isStarting: json['is_starting'],
      isCaptain: json['is_captain'],
      points: json['points'],
      position: json['position'],
    );
  }
}
