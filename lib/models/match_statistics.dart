/// One team's statistics for a match. A null stat is unknown (the source
/// didn't give it), which is not the same as 0. Cards are always known: the
/// backend counts them from the match's cards.
class TeamMatchStats {
  final int? possession; // %
  final int? shots;
  final int? shotsOnTarget;
  final int? corners;
  final int? fouls;
  final int? offsides;
  final int? saves;
  final int yellowCards;
  final int redCards;

  const TeamMatchStats({
    this.possession,
    this.shots,
    this.shotsOnTarget,
    this.corners,
    this.fouls,
    this.offsides,
    this.saves,
    this.yellowCards = 0,
    this.redCards = 0,
  });

  factory TeamMatchStats.fromJson(Map<String, dynamic> json) {
    return TeamMatchStats(
      possession: json['possession'],
      shots: json['shots'],
      shotsOnTarget: json['shots_on_target'],
      corners: json['corners'],
      fouls: json['fouls'],
      offsides: json['offsides'],
      saves: json['saves'],
      yellowCards: json['yellow_cards'] ?? 0,
      redCards: json['red_cards'] ?? 0,
    );
  }
}

/// A match's statistics for both teams, and where the numbers come from.
class MatchStatistics {
  final TeamMatchStats home;
  final TeamMatchStats away;
  // How they were entered: data_file, admin or reporter.
  final String source;
  // Where they were taken from, shown under the statistics; may be empty.
  final String sourceNote;

  const MatchStatistics({
    required this.home,
    required this.away,
    this.source = '',
    this.sourceNote = '',
  });

  factory MatchStatistics.fromJson(Map<String, dynamic> json) {
    return MatchStatistics(
      home: TeamMatchStats.fromJson(json['home']),
      away: TeamMatchStats.fromJson(json['away']),
      source: json['source'] ?? '',
      sourceNote: json['source_note'] ?? '',
    );
  }
}
