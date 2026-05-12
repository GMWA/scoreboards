import 'package:scoreboards/models/editions.dart';

class Championship {
  final int id;
  final String name;
  final String country;
  final String? logo;
  final List<Edition> editions;

  Championship(
      {required this.id,
      required this.name,
      required this.country,
      this.logo,
      required this.editions});

  factory Championship.fromJson(Map<String, dynamic> json) {
    return Championship(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      country: json['country'],
      editions: (json['editions'] as List)
          .map((edition) => Edition.fromJson(edition))
          .toList(),
    );
  }
}
