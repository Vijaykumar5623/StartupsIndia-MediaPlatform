import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/news_article_model.dart';
import '../../../../core/utils/time_format_helper.dart';
import '../../../../theme/style_guide.dart';
import '../../domain/models/news_article.dart';
import '../providers/news_provider.dart';
import '../widgets/trending_card.dart';

class TrendingScreen extends ConsumerWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingNewsProvider);

    return Scaffold(
      backgroundColor: AppColors.grayscaleWhite,
      appBar: AppBar(
        backgroundColor: AppColors.grayscaleWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.grayscaleTitleActive,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trending',
          style: AppTypography.displaySmallBold.copyWith(
            color: AppColors.grayscaleTitleActive,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
            color: AppColors.grayscaleTitleActive,
          ),
        ],
      ),
      body: trendingAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No trending articles yet.',
                style: AppTypography.textSmall.copyWith(
                  color: AppColors.grayscaleBodyText,
                ),
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TrendingCard(
                  article: _toNewsArticle(items[index]),
                  horizontalPadding: 0,
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryDefault),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Failed to load trending news: $error',
              textAlign: TextAlign.center,
              style: AppTypography.textSmall.copyWith(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  NewsArticle _toNewsArticle(NewsArticleModel model) {
    return NewsArticle(
      id: model.id,
      authorId: model.authorId,
      category: model.category,
      headline: model.headline,
      sourceName: model.sourceName,
      sourceId: model.sourceId,
      sourceLogoAsset: model.sourceLogoAsset,
      thumbnailAsset: model.thumbnailAsset,
      timeAgo: formatArticleTimestamp(model.createdAt, fallback: model.timeAgo),
      body: model.body,
      likesCount: model.likesCount,
      commentsCount: model.commentsCount,
      isSourceFollowing: model.isSourceFollowing,
      isBookmarked: model.isBookmarked,
      isLiked: model.isLiked,
    );
  }
}
