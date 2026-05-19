import 'package:scoreboards/models/stadium.dart';

class MatchTeam {
  final int id;
  final String slug;
  final String name;
  final String? logo;
  final Stadium? stadium;
  final String? country;
  final String? website;

  MatchTeam({
    required this.id,
    required this.slug,
    required this.name,
    this.logo,
    this.stadium,
    this.country,
    this.website
  });

  factory MatchTeam.fromJson(Map<String, dynamic> json) {
    return MatchTeam(
      id: _parseInt(json['id']),
      slug: json['slug'],
      name: json['name']?.toString() ?? 'Unknown Team',
      logo: json['logo']?.toString(),
      stadium:
          json['stadium'] != null ? Stadium.fromJson(json['stadium']) : null,
      country: json['country']?.toString(),
      website: json['website'],
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
