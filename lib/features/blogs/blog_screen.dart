import 'package:flutter/material.dart';
import 'package:scoreboards/core/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scoreboards/core/theme.dart';
import 'package:scoreboards/core/config.dart';
import 'package:scoreboards/features/blogs/article.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoreboards/core/links.dart';
import 'package:scoreboards/core/router.dart';
import 'package:scoreboards/features/blogs/blogs_providers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogScreen extends ConsumerStatefulWidget {
  final String slug;
  const BlogScreen({super.key, required this.slug});

  @override
  BlogScreenState createState() => BlogScreenState();
}

class BlogScreenState extends ConsumerState<BlogScreen> {
  static const _openableSchemes = {'http', 'https', 'mailto'};

  Future<void> _openLink(String? url) async {
    var uri = url == null ? null : Uri.tryParse(url);
    if (uri == null) return;

    // Article bodies link to website pages (e.g. /teams/x); open the
    // matching app screen when there is one.
    final website = AppConfig.website;
    final route = appRouteForLink(uri, website);
    if (route != null) {
      context.push(route);
      return;
    }
    // Website-only pages such as /predictions open in the browser.
    if (!uri.hasScheme) uri = website.resolveUri(uri);
    if (!_openableSchemes.contains(uri.scheme)) return;

    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.linkOpenFailed)),
      );
    }
  }

  // Shares the website link rather than text: the receiving app builds the
  // preview card from the page's search title, description and cover.
  Future<void> _share(BuildContext buttonContext, Article a) async {
    // iPad anchors the share sheet to the button.
    final box = buttonContext.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(ShareParams(
      uri: articleWebLink(AppConfig.website, widget.slug),
      subject: a.title,
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final Article a;
    switch (ref.watch(articleProvider(widget.slug))) {
      case AsyncValue(hasValue: true, :final value):
        a = value!;
      case AsyncError():
        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: Center(
            child: Text(context.l10n.articleNotFound,
                style: GoogleFonts.hankenGrotesk(color: AppColors.textPrimary)),
          ),
        );
      default:
        return const Scaffold(
          backgroundColor: AppColors.bg,
          body:
              Center(child: CircularProgressIndicator(color: AppColors.coral)),
        );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: a.coverImage != null ? 220.0 : 90.0,
            pinned: true,
            backgroundColor: AppColors.bg,
            elevation: 0,
            actions: [
              Builder(
                builder: (buttonContext) => IconButton(
                  tooltip: context.l10n.shareArticle,
                  icon: const Icon(Icons.share_outlined,
                      color: AppColors.textPrimary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.bg.withValues(alpha: 0.6),
                  ),
                  onPressed: () => _share(buttonContext, a),
                ),
              ),
              const SizedBox(width: 8),
            ],
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
                          DateFormat.yMMMd().format(a.publishedAt!),
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
                        context.l10n.articleViews(a.viewsCount),
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
                    onLinkTap: (url, _, __) => _openLink(url),
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
                    _buildSectionHeader(context.l10n.relatedMatches),
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
        onTap: () => context.push(Routes.match(m.slug)),
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
