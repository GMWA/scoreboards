enum MatchStatus {
  planned('planned'),
  scheduled('scheduled'),
  ongoing('ongoing'),
  completed('completed'),
  awarded('awarded'),
  postponed('postponed'),
  cancelled('cancelled'),
  abandoned('abandoned');

  const MatchStatus(this.value);
  final String value;

  static MatchStatus fromString(String value) => MatchStatus.values
      .firstWhere((e) => e.value == value, orElse: () => MatchStatus.planned);

  /// Whether the score means anything: the match is underway or over (an
  /// abandoned match can have a partial score). Not-yet-played, postponed
  /// and cancelled matches carry a meaningless 0-0.
  bool get hasScore => switch (this) {
        ongoing || completed || awarded || abandoned => true,
        _ => false,
      };
}


enum KnockoutRound {
  r32('R32'),
  r16('R16'),
  quarterFinale('QF'),
  semiFinale('SF'),
  finale('F');

  const KnockoutRound(this.value);
  final String value;

  static KnockoutRound fromString(String value) => KnockoutRound.values
      .firstWhere((e) => e.value == value, orElse: () => KnockoutRound.r32);
}


enum CompetitionPhase {
  group('group'),
  knockout('knockout');

  const CompetitionPhase(this.value);
  final String value;

  static CompetitionPhase fromString(String value) => CompetitionPhase.values
      .firstWhere((e) => e.value == value, orElse: () => CompetitionPhase.group);
}


enum MatchType {
  league('league'),
  cup('cup');

  const MatchType(this.value);
  final String value;

  static MatchType fromString(String value) => MatchType.values
      .firstWhere((e) => e.value == value, orElse: () => MatchType.league);
}
