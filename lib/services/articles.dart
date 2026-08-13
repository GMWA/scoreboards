import 'dart:convert';
import 'package:http/http.dart';
import 'package:scoreboards/models/article.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/services/api_pagination.dart';

class ArticleService {
  static Client client = Client();

  static Future<List<ArticleBase>> getArticles({String search = ""}) async {
    final uri = Uri.parse(urls['ARTICLES']['ALL']).replace(queryParameters: {
      if (search.isNotEmpty) 'search': search,
    });

    return await fetchPaginated(
      client: client,
      uri: uri,
      fromJson: (item) => ArticleBase.fromJson(item),
    );
  }

  static Future<Article> getArticleBySlug(String slug) async {
    Response res =
        await client.get(Uri.parse(urls['ARTICLES']['BY_SLUG'] + "$slug/"));

    if (res.statusCode == 200) {
      dynamic articleItem = jsonDecode(res.body);
      return Article.fromJson(articleItem);
    } else {
      throw Exception("Can't get article.");
    }
  }

  static Future<Article> getArticleById(int articleId) async {
    Response res = await client.get(Uri.parse(urls['ARTICLES']['BY_ID']
        .replaceAll('#articleId', articleId.toString())));

    if (res.statusCode == 200) {
      dynamic articleItem = jsonDecode(res.body);
      return Article.fromJson(articleItem);
    } else {
      throw Exception("Can't get article.");
    }
  }

  /// Best-effort view count increment — failures are swallowed so a flaky
  /// network call never blocks or breaks the reading experience.
  static Future<void> recordView(int articleId) async {
    try {
      await client.post(Uri.parse(
          urls['ARTICLES']['VIEW'].replaceAll('#articleId', articleId.toString())));
    } catch (_) {}
  }
}
