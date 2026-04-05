import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/news_article.dart';
import '../../../../theme/style_guide.dart';
import '../screens/article_detail_screen.dart';

/// Reusable tile for the 'Latest' news feed section.
/// Matches the Figma design: thumbnail left, category/headline/source right, bookmark icon.
class NewsTile extends ConsumerStatefulWidget {
  final NewsArticle article;
  final VoidCallback? onTap;

  const NewsTile({super.key, required this.article, this.onTap});

  @override
  ConsumerState<NewsTile> createState() => _NewsTileState();
}

class _NewsTileState extends ConsumerState<NewsTile> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.article.isBookmarked;
  }

  @override
  void didUpdateWidget(NewsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isBookmarked = widget.article.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () => _openDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ────────────────────────────────────────────
            Hero(
              tag: widget.article.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.article.thumbnailAsset.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: widget.article.thumbnailAsset,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _thumbnailFallback(),
                        errorWidget: (context, url, error) =>
                            _thumbnailFallback(),
                      )
                    : Image.asset(
                        widget.article.thumbnailAsset,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _thumbnailFallback(),
                      ),
              ),
            ),

            const SizedBox(width: 12),

            // ── Text block ───────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  Text(
                    widget.article.category.toUpperCase(),
                    style: AppTypography.textSmall.copyWith(
                      color: AppColors.primaryDefault,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Headline
                  Text(
                    widget.article.headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textSmall.copyWith(
                      color: AppColors.grayscaleTitleActive,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Source row: logo + name + time + bookmark
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: widget.article.sourceLogoAsset.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: widget.article.sourceLogoAsset,
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => _logoFallback(),
                                errorWidget: (context, url, error) =>
                                    _logoFallback(),
                              )
                            : Image.asset(
                                widget.article.sourceLogoAsset,
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _logoFallback(),
                              ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          widget.article.sourceName,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textSmall.copyWith(
                            color: AppColors.grayscaleBodyText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.grayscaleButtonText,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.article.timeAgo,
                        style: AppTypography.textSmall.copyWith(
                          color: AppColors.grayscaleButtonText,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      // Bookmark icon
                      GestureDetector(
                        onTap: _toggleBookmark,
                        child: Icon(
                          _isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          color: _isBookmarked
                              ? AppColors.primaryDefault
                              : AppColors.grayscaleButtonText,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBookmark() {
    // Optimistic UI update
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    // In a real app, you'd call the repository here to persist the change
    // For now, this just shows the optimistic toggle
  }

  Widget _thumbnailFallback() {
    return Container(
      width: 96,
      height: 96,
      color: AppColors.grayscaleSecondaryButton,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grayscaleButtonText,
      ),
    );
  }

  Widget _logoFallback() {
    return Container(
      width: 20,
      height: 20,
      color: AppColors.grayscaleLine,
      child: const Icon(
        Icons.newspaper,
        size: 12,
        color: AppColors.grayscaleButtonText,
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticleDetailScreen(article: widget.article),
      ),
    );
  }
}
