class EditionStandingRule {
  final int id;
  final int edition;
  final String phase;
  final int fromPosition;
  final int? toPosition;
  final String outcome;
  final String color;
  final int priority;

  EditionStandingRule(
      {required this.id,
      required this.edition,
      required this.phase,
      required this.fromPosition,
      required this.outcome,
      required this.color,
      required this.priority,
      this.toPosition});

  factory EditionStandingRule.fromJson(Map<String, dynamic> json) {
    return EditionStandingRule(
        id: json['id'],
        edition: json['edition'],
        phase: json['phase'],
        fromPosition: json['from_position'],
        outcome: json['outcome'],
        color: json['color'],
        priority: json['priority'],
        toPosition: json['to_position']);
  }
}

class ChampionshipEdition {
  final int id;
  final String name;
  final String country;
  final String? logo;

  ChampionshipEdition({
    required this.id,
    required this.name,
    required this.country,
    this.logo,
  });

  factory ChampionshipEdition.fromJson(Map<String, dynamic> json) {
    return ChampionshipEdition(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      logo: json['logo'],
    );
  }
}

class MatchEdition {
  final int id;
  final String slug;
  final ChampionshipEdition championship;
  final String year;
  final String? label;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;

  MatchEdition({
    required this.id,
    required this.slug,
    required this.championship,
    required this.year,
    this.label,
    this.startDate,
    this.endDate,
    required this.isCurrent,
  });

  factory MatchEdition.fromJson(Map<String, dynamic> json) {
    return MatchEdition(
      id: json['id'],
      slug: json['slug'],
      championship: ChampionshipEdition.fromJson(json['championship']),
      year: json['year'],
      label: json['label'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isCurrent: json['is_current'],
    );
  }
}

class Edition {
  final int id;
  final String slug;
  final ChampionshipEdition championship;
  final String year;
  final String? label;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;

  Edition({
    required this.id,
    required this.slug,
    required this.championship,
    required this.year,
    this.label,
    this.startDate,
    this.endDate,
    required this.isCurrent,
  });

  factory Edition.fromJson(Map<String, dynamic> json) {
    return Edition(
      id: json['id'],
      slug: json['slug'],
      championship: ChampionshipEdition.fromJson(json['championship']),
      year: json['year'],
      label: json['label'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isCurrent: json['is_current'],
    );
  }
}
