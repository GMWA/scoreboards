import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/features/blogs/article.dart';
import 'package:scoreboards/features/blogs/articles_repository.dart';

/// Every article, for the Blogs tab.
final articlesProvider = FutureProvider.autoDispose<List<ArticleBase>>(
  (ref) => ref.watch(articlesRepositoryProvider).all(),
);

/// An article; opening it counts a view.
final articleProvider =
    FutureProvider.autoDispose.family<Article, String>((ref, slug) async {
  final repo = ref.watch(articlesRepositoryProvider);
  final article = await repo.bySlug(slug);
  unawaited(repo.recordView(article.id));
  return article;
});
