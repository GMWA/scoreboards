enum MatchStatus {
  planned('planned'),
  inProgress('in_progress'),
  completed('completed'),
  awarded('awarded'),
  postponed('postponed');

  const MatchStatus(this.value);
  final String value;

  static MatchStatus fromString(String value) => MatchStatus.values
      .firstWhere((e) => e.value == value, orElse: () => MatchStatus.planned);
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
