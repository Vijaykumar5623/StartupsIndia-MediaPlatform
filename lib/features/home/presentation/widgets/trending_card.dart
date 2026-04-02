import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/news_article.dart';
import '../../../../theme/style_guide.dart';

/// Large trending news card matching the Figma design:
/// Big image background, category tag, bold headline, source row.
class TrendingCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback? onTap;
  final double horizontalPadding;

  const TrendingCard({
    super.key,
    required this.article,
    this.onTap,
    this.horizontalPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Hero Image ─────────────────────────────────────
                article.thumbnailAsset.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: article.thumbnailAsset,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildImageFallback(),
                        errorWidget: (_, __, ___) => _buildImageFallback(),
                      )
                    : Image.asset(
                        article.thumbnailAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImageFallback(),
                      ),

                // ── Gradient overlay ────────────────────────────────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.80),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── Text content ────────────────────────────────────
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.category,
                          style: AppTypography.textSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Headline
                      Text(
                        article.headline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Source row
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: Image.asset(
                              article.sourceLogoAsset,
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBB1919),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Center(
                                  child: Text('B',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            article.sourceName,
                            style: AppTypography.textSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text(
                            article.timeAgo,
                            style: AppTypography.textSmall.copyWith(
                              color: Colors.white70,
                              fontSize: 11,
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
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.grayscaleSecondaryButton,
      ),
      child: Center(
        child: CachedNetworkImage(
          imageUrl: 'https://placehold.co/96x96/e5e7eb/9ca3af.png?text=Image',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: AppColors.grayscaleButtonText,
          ),
        ),
      ),
    );
  }
}
