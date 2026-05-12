import 'package:scoreboards/models/player.dart';
import 'package:scoreboards/models/match_team.dart';

class Card {
  final int id;
  final String cardType;
  final int minute;
  final int? stoppageMinute;
  // final int matchId;
  final PlayerLookup? player;
  final MatchTeam  team;
  final String? reason;
  final bool isSecondYellow;

  Card({
    required this.id,
    required this.cardType,
    required this.minute,
    this.stoppageMinute,
    // required this.matchId,
    this.player,
    required this.team,
    required this.isSecondYellow,
    this.reason,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'],
      cardType: json['card_type'],
      minute: json['minute'],
      stoppageMinute: json['stoppage_minute'] ?? 0,
      // matchId: json['match'],
      player:
          json['player'] != null ? PlayerLookup.fromJson(json['player']) : null,
      team: MatchTeam.fromJson(json['team']),
      reason: json['reason'],
      isSecondYellow: json['is_second_yellow'],
    );
  }
}
