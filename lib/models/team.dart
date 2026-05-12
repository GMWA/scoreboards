import 'package:scoreboards/models/stadium.dart';

class Team {
  final int id;
  final String teamType;
  final String name;
  final String slug;
  final String? logo;
  final String coach;
  final Stadium? stadium;
  final String? league;
  final int? founded;
  final String? country;
  final String? confederation;
  final String? website;

  Team(
      {required this.id,
      required this.slug,
      required this.name,
      required this.teamType,
      required this.coach,
      this.logo,
      this.founded,
      this.stadium,
      this.league,
      this.country,
      this.confederation,
      this.website});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
        id: json['id'],
        slug: json['slug'],
        name: json['name'],
        logo: json['logo'],
        founded: json['founded'],
        teamType: json['team_type'],
        coach: json['coach'],
        stadium:
            json['stadium'] != null ? Stadium.fromJson(json['stadium']) : null,
        league: json['league'],
        country: json['country'],
        confederation: json['confederation'],
        website: json['website']);
  }
}

class PlayerTeam {
  final int id;
  final String slug;
  final String firstname;
  final String lastname;
  final String? logo;
  final int jerseyNumber;

  PlayerTeam(
      {required this.id,
      required this.slug,
      required this.firstname,
      required this.lastname,
      required this.jerseyNumber,
      this.logo});

  factory PlayerTeam.fromJson(Map<String, dynamic> json) {
    return PlayerTeam(
        id: json['id'],
        slug: json['slug'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        jerseyNumber: json['jersey_number'],
        logo: json['logo'] ?? json['team_logo']);
  }
}

class TeamLookup {
  final int id;
  final String slug;
  final String name;
  final String? logo;
  final String? website;
  final Stadium? stadium;
  final String? country;

  TeamLookup(
      {required this.id,
      required this.slug,
      required this.name,
      this.logo,
      this.website,
      this.country,
      this.stadium});

  factory TeamLookup.fromJson(Map<String, dynamic> json) {
    return TeamLookup(
        id: json['id'],
        slug: json['slug'],
        name: json['name'] ?? '',
        logo: json['logo'],
        website: json['website'],
        stadium:
            json['stadium'] != null ? Stadium.fromJson(json['stadium']) : null,
        country: json['country']);
  }
}
