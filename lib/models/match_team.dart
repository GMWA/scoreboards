class MatchTeam {
  final int id;
  final String slug;
  final String name;
  final String? logo;
  final String? stadium;
  final String? country;

  MatchTeam({
    required this.id,
    required this.slug,
    required this.name,
    this.logo,
    this.stadium,
    this.country,
  });

  factory MatchTeam.fromJson(Map<String, dynamic> json) {
    return MatchTeam(
      id: _parseInt(json['id']),
      slug: json['slug'],
      name: json['name']?.toString() ?? 'Unknown Team',
      logo: json['logo']?.toString(),
      stadium: json['stadium']?.toString(),
      country: json['country']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
