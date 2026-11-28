import 'package:flutter/material.dart';
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
            'Blogs',
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
            error: () => _buildErrorState(refresh),
            data: (articles) {
              if (articles.isEmpty) {
                return Center(
                  child: Text(
                    'No articles found.',
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

  Widget _buildErrorState(Future<void> Function() retry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.border, size: 48),
          const SizedBox(height: 16),
          Text(
            'Connection Error',
            style: GoogleFonts.hankenGrotesk(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          TextButton(
            onPressed: retry,
            child: Text('RETRY',
                style: GoogleFonts.hankenGrotesk(
                    color: AppColors.coral, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
