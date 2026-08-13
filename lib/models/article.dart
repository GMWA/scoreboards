import 'package:scoreboards/models/player.dart';
import 'package:scoreboards/models/team.dart';

class ArticleMatchTag {
  final int id;
  final String slug;
  final DateTime date;
  final TeamLookup homeTeam;
  final TeamLookup awayTeam;

  ArticleMatchTag({
    required this.id,
    required this.slug,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
  });

  factory ArticleMatchTag.fromJson(Map<String, dynamic> json) {
    return ArticleMatchTag(
      id: json['id'],
      slug: json['slug'] ?? '',
      date: DateTime.parse(json['date']).toLocal(),
      homeTeam: TeamLookup.fromJson(json['home_team']),
      awayTeam: TeamLookup.fromJson(json['away_team']),
    );
  }
}

class ArticleChampionshipTag {
  final int id;
  final String name;
  final String? logo;

  ArticleChampionshipTag({required this.id, required this.name, this.logo});

  factory ArticleChampionshipTag.fromJson(Map<String, dynamic> json) {
    return ArticleChampionshipTag(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
    );
  }
}

class ArticleEditionTag {
  final int id;
  final String? slug;
  final String? label;
  final String year;

  ArticleEditionTag({
    required this.id,
    this.slug,
    this.label,
    required this.year,
  });

  factory ArticleEditionTag.fromJson(Map<String, dynamic> json) {
    return ArticleEditionTag(
      id: json['id'],
      slug: json['slug'],
      label: json['label'],
      year: json['year'],
    );
  }
}

class ArticleBase {
  final int id;
  final String? slug;
  final String title;
  final String excerpt;
  final String? coverImage;
  final DateTime? publishedAt;
  final int viewsCount;

  ArticleBase({
    required this.id,
    this.slug,
    required this.title,
    required this.excerpt,
    this.coverImage,
    this.publishedAt,
    required this.viewsCount,
  });

  factory ArticleBase.fromJson(Map<String, dynamic> json) {
    return ArticleBase(
      id: json['id'],
      slug: json['slug'],
      title: json['title'],
      excerpt: json['excerpt'] ?? '',
      coverImage: json['cover_image'],
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at']).toLocal()
          : null,
      viewsCount: json['views_count'] ?? 0,
    );
  }
}

class Article extends ArticleBase {
  final String body;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? author;
  final List<PlayerLookup> players;
  final List<TeamLookup> teams;
  final List<ArticleMatchTag> matches;
  final List<ArticleChampionshipTag> championships;
  final List<ArticleEditionTag> editions;

  Article({
    required super.id,
    super.slug,
    required super.title,
    required super.excerpt,
    super.coverImage,
    super.publishedAt,
    required super.viewsCount,
    required this.body,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    required this.players,
    required this.teams,
    required this.matches,
    required this.championships,
    required this.editions,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final base = ArticleBase.fromJson(json);

    return Article(
      id: base.id,
      slug: base.slug,
      title: base.title,
      excerpt: base.excerpt,
      coverImage: base.coverImage,
      publishedAt: base.publishedAt,
      viewsCount: base.viewsCount,
      body: json['body'] ?? '',
      status: json['status'] ?? 'draft',
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
      author: json['author'],
      players: (json['players'] as List? ?? [])
          .map((p) => PlayerLookup.fromJson(p))
          .toList(),
      teams: (json['teams'] as List? ?? [])
          .map((t) => TeamLookup.fromJson(t))
          .toList(),
      matches: (json['matches'] as List? ?? [])
          .map((m) => ArticleMatchTag.fromJson(m))
          .toList(),
      championships: (json['championships'] as List? ?? [])
          .map((c) => ArticleChampionshipTag.fromJson(c))
          .toList(),
      editions: (json['editions'] as List? ?? [])
          .map((e) => ArticleEditionTag.fromJson(e))
          .toList(),
    );
  }
}
