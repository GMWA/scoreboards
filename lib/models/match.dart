import 'package:scoreboards/models/match_team.dart';
import 'package:scoreboards/models/editions.dart';
import 'package:scoreboards/models/card.dart';
import 'package:scoreboards/models/goal.dart';
import 'package:scoreboards/models/stadium.dart';
import 'package:scoreboards/models/subtitution.dart';
import 'package:scoreboards/models/lineup.dart';
import 'package:scoreboards/enums/matchs.dart';

class MatchBase {
  final int id;
  final String slug;
  final String type;
  final DateTime date;
  final String location;
  final String round;
  final MatchStatus status;
  final Stadium? stadium;
  final MatchEdition edition;
  final MatchTeam homeTeam;
  final MatchTeam awayTeam;
  // Scores
  final int? scoreHTHome;
  final int? scoreHTAway;
  final int? score90Home;
  final int? score90Away;
  final int scoreFinalHome;
  final int scoreFinalAway;
  final int? scorePsoHome;
  final int? scorePsoAway;
  // Flags
  final bool wentToExtraTime;
  final bool wentToPenalties;
  final int? attendance;

  MatchBase({
    required this.id,
    required this.slug,
    required this.type,
    required this.date,
    required this.location,
    required this.round,
    required this.status,
    this.stadium,
    required this.edition,
    required this.homeTeam,
    required this.awayTeam,
    this.scoreHTHome,
    this.scoreHTAway,
    this.score90Home,
    this.score90Away,
    required this.scoreFinalHome,
    required this.scoreFinalAway,
    this.scorePsoHome,
    this.scorePsoAway,
    required this.wentToExtraTime,
    required this.wentToPenalties,
    this.attendance,
  });

  factory MatchBase.fromJson(Map<String, dynamic> json) {
    return MatchBase(
      id: json['id'],
      slug: json['slug'],
      type: json['type'] ?? 'league',
      date: DateTime.parse(json['date']),
      location: json['location'] ?? '',
      round: json['round'] ?? '',
      stadium:
          json['stadium'] != null ? Stadium.fromJson(json['stadium']) : null,
      status: MatchStatus.fromString(json['status']),
      edition: MatchEdition.fromJson(json['edition']),
      homeTeam: MatchTeam.fromJson(json['home_team']),
      awayTeam: MatchTeam.fromJson(json['away_team']),
      scoreHTHome: json['score_ht_home'],
      scoreHTAway: json['score_ht_away'],
      score90Home: json['score_90_home'],
      score90Away: json['score_90_away'],
      scoreFinalHome: json['score_final_home'] ?? 0,
      scoreFinalAway: json['score_final_away'] ?? 0,
      scorePsoHome: json['score_pso_home'],
      scorePsoAway: json['score_pso_away'],
      wentToExtraTime: json['went_to_extra_time'] ?? false,
      wentToPenalties: json['went_to_penalties'] ?? false,
      attendance: json['attendance'],
    );
  }
}

class Match extends MatchBase {
  final List<Goal> goals;
  final List<Card> cards;
  final List<Substitution> substitutions;
  final List<MatchLineup> lineups;

  Match(
      {
      // Pass all base fields to super
      required super.id,
      required super.slug,
      required super.type,
      required super.date,
      required super.location,
      required super.round,
      required super.status,
      required super.edition,
      required super.homeTeam,
      required super.awayTeam,
      super.scoreHTHome,
      super.scoreHTAway,
      super.score90Home,
      super.score90Away,
      required super.scoreFinalHome,
      required super.scoreFinalAway,
      super.scorePsoHome,
      super.scorePsoAway,
      required super.wentToExtraTime,
      required super.wentToPenalties,
      super.attendance,
      // Add detail-specific fields
      required this.goals,
      required this.cards,
      required this.substitutions,
      required this.lineups});

  factory Match.fromJson(Map<String, dynamic> json) {
    // 1. Parse the base properties first
    final base = MatchBase.fromJson(json);

    // 2. Return the detailed version with lists
    return Match(
      id: base.id,
      slug: base.slug,
      type: base.type,
      date: base.date,
      location: base.location,
      round: base.round,
      status: base.status,
      edition: base.edition,
      homeTeam: base.homeTeam,
      awayTeam: base.awayTeam,
      scoreHTHome: base.scoreHTHome,
      scoreHTAway: base.scoreHTAway,
      score90Home: base.score90Home,
      score90Away: base.score90Away,
      scoreFinalHome: base.scoreFinalHome,
      scoreFinalAway: base.scoreFinalAway,
      scorePsoHome: base.scorePsoHome,
      scorePsoAway: base.scorePsoAway,
      wentToExtraTime: base.wentToExtraTime,
      wentToPenalties: base.wentToPenalties,
      attendance: base.attendance,

      // 3. Map the lists
      goals:
          (json['goals'] as List? ?? []).map((g) => Goal.fromJson(g)).toList(),
      cards:
          (json['cards'] as List? ?? []).map((c) => Card.fromJson(c)).toList(),
      substitutions: (json['substitutions'] as List? ?? [])
          .map((s) => Substitution.fromJson(s))
          .toList(),
      lineups: (json['lineups'] as List? ?? [])
          .map((lineup) => MatchLineup.fromJson(lineup))
          .toList(),
    );
  }
}
