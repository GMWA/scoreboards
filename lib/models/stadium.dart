class Stadium {
  final int id;
  final String name;
  final String slug;
  final String city;
  final String country;
  final num capacity;
  final bool isOpened;
  final String? address;
  final num? openedYear;
  final String? image;
  final String? website;

  Stadium(
      {required this.id,
      required this.name,
      required this.slug,
      required this.city,
      required this.country,
      required this.capacity,
      required this.isOpened,
      this.address,
      this.openedYear,
      this.image,
      this.website});

  factory Stadium.fromJson(Map<String, dynamic> json) {
    return Stadium(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        city: json['city'],
        country: json['country'],
        capacity: json['capacity'],
        isOpened: json['is_opened'],
        address: json['address'],
        openedYear: json['opened_year'],
        image: json['image'],
        website: json['website']);
  }
}
