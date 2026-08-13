import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/article.dart';
import 'package:scoreboards/services/articles.dart';
import 'package:scoreboards/widgets/ui/article_card.dart';

class BlogsTabScreen extends StatefulWidget {
  const BlogsTabScreen({super.key});

  @override
  BlogsTabScreenState createState() => BlogsTabScreenState();
}

class BlogsTabScreenState extends State<BlogsTabScreen> {
  late Future<List<ArticleBase>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  void _loadArticles() {
    setState(() {
      _articlesFuture = ArticleService.getArticles();
    });
  }

  Future<void> _refreshArticles() async {
    _loadArticles();
  }

  @override
  Widget build(BuildContext context) {
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
          child: FutureBuilder<List<ArticleBase>>(
            future: _articlesFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.coral));
              }

              if (snapshot.hasError) {
                return _buildErrorState();
              }

              final articles = snapshot.data ?? [];

              if (articles.isEmpty) {
                return Center(
                  child: Text(
                    'No articles found.',
                    style: GoogleFonts.hankenGrotesk(color: AppColors.textSecondary),
                  ),
                );
              }

              return RefreshIndicator(
                backgroundColor: AppColors.surface,
                color: AppColors.coral,
                onRefresh: _refreshArticles,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                  itemCount: articles.length,
                  itemBuilder: (ctx, index) {
                    final article = articles[index];
                    return ArticleCard(
                      article: article,
                      onTap: article.slug != null
                          ? () => context.push('/blogs/${article.slug}')
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

  Widget _buildErrorState() {
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
            onPressed: _refreshArticles,
            child: Text('RETRY',
                style: GoogleFonts.hankenGrotesk(
                    color: AppColors.coral, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
