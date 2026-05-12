import 'package:scoreboards/models/team.dart';
import 'package:scoreboards/models/player.dart';

class PlayerTransfert {
  final int id;
  final PlayerLookup player;
  final TeamLookup team;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? fee;

  PlayerTransfert({
    required this.id,
    required this.player,
    required this.team,
    this.startDate,
    this.endDate,
    this.fee,
  });

  factory PlayerTransfert.fromJson(Map<String, dynamic> json) {
    return PlayerTransfert(
      id: json['id'],
      player: PlayerLookup.fromJson(json['player']),
      team: TeamLookup.fromJson(json['team']),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      fee: json['fee'] != null ? (json['fee'] as num).toDouble() : null,
    );
  }
}
