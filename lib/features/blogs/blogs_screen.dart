import 'package:flutter/material.dart';
import 'package:scoreboards/core/l10n.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/features/blogs/article.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/core/router.dart';
import 'package:scoreboards/features/blogs/blogs_providers.dart';
import 'package:scoreboards/shared/widgets/async_view.dart';
import 'package:scoreboards/features/blogs/widgets/article_card.dart';

class BlogsScreen extends ConsumerWidget {
  const BlogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> refresh() => ref
        .refresh(articlesProvider.future)
        .catchError((Object _) => <ArticleBase>[]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Text(
            context.l10n.navBlogs,
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: AsyncView<List<ArticleBase>>(
            value: ref.watch(articlesProvider),
            error: () => _buildErrorState(context, refresh),
            data: (articles) {
              if (articles.isEmpty) {
                return Center(
                  child: Text(
                    context.l10n.noArticles,
                    style: GoogleFonts.hankenGrotesk(
                        color: AppColors.textSecondary),
                  ),
                );
              }

              return RefreshIndicator(
                backgroundColor: AppColors.surface,
                color: AppColors.coral,
                onRefresh: refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 8.0),
                  itemCount: articles.length,
                  itemBuilder: (ctx, index) {
                    final article = articles[index];
                    return ArticleCard(
                      article: article,
                      onTap: article.slug != null
                          ? () => context.push(Routes.blog(article.slug!))
                          : null,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
      BuildContext context, Future<void> Function() retry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.border, size: 48),
          const SizedBox(height: 16),
          Text(
            context.l10n.connectionError,
            style: GoogleFonts.hankenGrotesk(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          TextButton(
            onPressed: retry,
            child: Text(context.l10n.retry.toUpperCase(),
                style: GoogleFonts.hankenGrotesk(
                    color: AppColors.coral, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
