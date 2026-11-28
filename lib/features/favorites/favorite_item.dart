/// A lightweight, serializable record of something the user follows —
/// either a team or a competition (championship edition). Storing the
/// display fields (name/logo) alongside the id means the "Following" row
/// on the Scores screen and the Settings favorites list can render without
/// re-fetching the full Team/Edition model.
enum FavoriteKind { team, competition }

class FavoriteItem {
  final int id;
  final String slug;
  final String name;
  final String? logo;
  final FavoriteKind kind;

  const FavoriteItem({
    required this.id,
    required this.slug,
    required this.name,
    required this.kind,
    this.logo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'logo': logo,
        'kind': kind.name,
      };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] as int,
      slug: json['slug'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      kind: (json['kind'] as String) == 'competition'
          ? FavoriteKind.competition
          : FavoriteKind.team,
    );
  }
}
