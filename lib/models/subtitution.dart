import 'package:scoreboards/models/match_team.dart';
import 'package:scoreboards/models/player.dart';

class Substitution {
  final int id;
  final int match;
  final MatchTeam team;
  final PlayerLookup playerIn;
  final PlayerLookup playerOut;
  final int minute;
  final int? stoppageMinute;
  final String? reason;

  Substitution({
    required this.id,
    required this.match,
    required this.team,
    required this.playerIn,
    required this.playerOut,
    required this.minute,
    this.stoppageMinute,
    this.reason,
  });

  factory Substitution.fromJson(Map<String, dynamic> json) {
    return Substitution(
      id: json['id'],
      match: json['match'],
      team: MatchTeam.fromJson(json['team']),
      playerIn: PlayerLookup.fromJson(json['player_in']),
      playerOut: PlayerLookup.fromJson(json['player_out']),
      minute: json['minute'],
      stoppageMinute: json['stoppage_minute'],
      reason: json['reason'],
    );
  }
}
