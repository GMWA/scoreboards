import 'package:scoreboards/shared/models/player.dart';
import 'package:scoreboards/shared/models/match_team.dart';

class DisciplinaryCard {
  final int id;
  final String cardType;
  final int minute;
  final int? stoppageMinute;
  // final int matchId;
  final PlayerLookup? player;
  /// A card shown to a member of the team's staff (a coach sent off from
  /// the bench) names them here instead of a player; '' for a player.
  final String staffName;
  /// head_coach, assistant_coach or other; '' for a player.
  final String staffRole;
  final MatchTeam  team;
  final String? reason;
  final bool isSecondYellow;

  DisciplinaryCard({
    required this.id,
    required this.cardType,
    required this.minute,
    this.stoppageMinute,
    // required this.matchId,
    this.player,
    this.staffName = '',
    this.staffRole = '',
    required this.team,
    required this.isSecondYellow,
    this.reason,
  });

  factory DisciplinaryCard.fromJson(Map<String, dynamic> json) {
    return DisciplinaryCard(
      id: json['id'],
      cardType: json['card_type'],
      minute: json['minute'] ?? 0,
      stoppageMinute: json['stoppage_minute'] ?? 0,
      // matchId: json['match'],
      player:
          json['player'] != null ? PlayerLookup.fromJson(json['player']) : null,
      staffName: (json['staff_name'] as String? ?? '').trim(),
      staffRole: json['staff_role'] as String? ?? '',
      team: MatchTeam.fromJson(json['team']),
      reason: json['reason'],
      isSecondYellow: json['is_second_yellow'],
    );
  }

  bool get isStaff => staffName.isNotEmpty;

  /// The staff member's role, as shown under their name.
  String get staffRoleLabel => switch (staffRole) {
        'head_coach' => 'Head coach',
        'assistant_coach' => 'Assistant coach',
        _ => 'Staff',
      };
}
