import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/core/api/paging.dart';
import 'package:scoreboards/core/providers.dart';
import 'package:scoreboards/features/blogs/article.dart';

class ArticlesRepository {
  ArticlesRepository(this._dio);

  final Dio _dio;

  /// Every published article (the endpoint is paginated).
  Future<List<ArticleBase>> all({String search = ''}) async =>
      (await getAll(_dio, '/articles/',
              query: {if (search.isNotEmpty) 'search': search}))
          .map(ArticleBase.fromJson)
          .toList();

  Future<Article> bySlug(String slug) async =>
      Article.fromJson(await getJson<Json>(_dio, '/articles/slug/$slug/'));

  /// Counts a view. Best effort: failures are swallowed so a flaky network
  /// call never blocks or breaks reading.
  Future<void> recordView(int articleId) async {
    try {
      await _dio.post<void>('/articles/$articleId/view/');
    } catch (_) {}
  }
}

final articlesRepositoryProvider = Provider<ArticlesRepository>(
  (ref) => ArticlesRepository(ref.watch(dioProvider)),
);
