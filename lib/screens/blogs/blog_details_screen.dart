import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/models/article.dart';
import 'package:scoreboards/services/articles.dart';

class BlogDetailsScreen extends StatefulWidget {
  final String slug;
  const BlogDetailsScreen({super.key, required this.slug});

  @override
  BlogDetailsScreenState createState() => BlogDetailsScreenState();
}

class BlogDetailsScreenState extends State<BlogDetailsScreen> {
  Article? article;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    try {
      final data = await ArticleService.getArticleBySlug(widget.slug);
      if (mounted) {
        setState(() {
          article = data;
          isLoading = false;
        });
      }
      ArticleService.recordView(data.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Article not found.";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.coral)),
      );
    }

    if (article == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text(errorMessage ?? "Error",
              style: GoogleFonts.hankenGrotesk(color: AppColors.textPrimary)),
        ),
      );
    }

    final a = article!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: a.coverImage != null ? 220.0 : 90.0,
            pinned: true,
            backgroundColor: AppColors.bg,
            elevation: 0,
            flexibleSpace: a.coverImage != null
                ? FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: a.coverImage!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Container(color: AppColors.surface),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.bg.withValues(alpha: 0.85),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (a.publishedAt != null) ...[
                        const Icon(Icons.schedule,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(a.publishedAt!),
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      const Icon(Icons.visibility_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${a.viewsCount} views',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (a.teams.isNotEmpty || a.championships.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...a.championships.map((c) => _buildTagChip(c.name)),
                        ...a.teams.map((t) => _buildTagChip(t.name)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Html(
                    data: a.body.isNotEmpty ? a.body : '<p>${a.excerpt}</p>',
                    style: {
                      'body': Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        color: AppColors.textPrimary,
                        fontSize: FontSize(15),
                        lineHeight: const LineHeight(1.5),
                        fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                      ),
                      'a': Style(color: AppColors.coral),
                      'img': Style(
                        margin: Margins.symmetric(vertical: 10),
                      ),
                    },
                  ),
                  if (a.matches.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionHeader('Related matches'),
                    const SizedBox(height: 10),
                    ...a.matches.map((m) => _buildMatchTile(context, m)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildMatchTile(BuildContext context, ArticleMatchTag m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/matchs/details/${m.slug}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${m.homeTeam.name} vs ${m.awayTeam.name}',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 12, color: AppColors.coral),
            ],
          ),
        ),
      ),
    );
  }
}
