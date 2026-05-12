import 'package:scoreboards/models/team.dart';

class PlayerLookup {
  final int id;
  final String slug;
  final String firstname;
  final String lastname;
  final String? avatar;
  final int? jerseyNumber;

  PlayerLookup({
    required this.id,
    required this.slug,
    required this.firstname,
    required this.lastname,
    this.avatar,
    this.jerseyNumber,
  });

  factory PlayerLookup.fromJson(Map<String, dynamic> json) {
    return PlayerLookup(
      id: json['id'],
      slug: json['slug'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      avatar: json['avatar'],
      jerseyNumber: json['jersey_number'],
    );
  }
}

class Player {
  final int id;
  final String slug;
  final String firstname;
  final String lastname;
  final String position;
  final String nationality;
  final DateTime dateOfBirth;
  final int jerseyNumber;
  final String matricule;
  final String? avatar;

  Player({
    required this.id,
    required this.slug,
    required this.firstname,
    required this.lastname,
    required this.position,
    required this.nationality,
    required this.dateOfBirth,
    required this.jerseyNumber,
    required this.matricule,
    this.avatar,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      slug: json['slug'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      position: json['position'],
      nationality: json['nationality'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      jerseyNumber: json['jersey_number'],
      matricule: json['matricule'],
      avatar: json['avatar'] ?? json['player_avatar'],
    );
  }
}

class PlayerStats {
  final PlayerLookup player;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;
  final TeamLookup playerTeam;

  PlayerStats({
    required this.player,
    required this.goals,
    required this.assists,
    required this.yellowCards,
    required this.redCards,
    required this.playerTeam,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      player: PlayerLookup.fromJson(json['player']),
      goals: json['goals'],
      assists: json['assists'],
      yellowCards: json['yellow_cards'],
      redCards: json['red_cards'],
      playerTeam: TeamLookup.fromJson(json['team']),
    );
  }
}

class PlayerTeamHistory {
  final TeamLookup team;
  final DateTime startDate;
  final DateTime? endDate;

  PlayerTeamHistory({
    required this.team,
    required this.startDate,
    this.endDate,
  });

  factory PlayerTeamHistory.fromJson(Map<String, dynamic> json) {
    return PlayerTeamHistory(
      team: TeamLookup.fromJson(json['team']),
      startDate: DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }
}

class PlayerContract {
  final int id;
  final PlayerLookup player;
  final TeamLookup team;
  final DateTime startDate;
  final DateTime? endDate;
  final double? fee;

  PlayerContract({
    required this.id,
    required this.player,
    required this.team,
    required this.startDate,
    this.endDate,
    this.fee,
  });

  factory PlayerContract.fromJson(Map<String, dynamic> json) {
    return PlayerContract(
      id: json['id'],
      player: PlayerLookup.fromJson(json['player']),
      team: TeamLookup.fromJson(json['team']),
      startDate: DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      fee: json['fee'] != null ? (json['fee'] as num).toDouble() : null,
    );
  }
}
