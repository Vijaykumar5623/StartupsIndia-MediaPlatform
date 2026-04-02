import 'package:flutter/material.dart';
import '../../../../theme/style_guide.dart';
import '../../domain/models/news_article.dart';
import '../../domain/models/news_feed_data.dart';
import '../widgets/trending_card.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  List<NewsArticle> get _trendingArticles => [
        NewsFeedData.trendingArticle,
        ...NewsFeedData.latestArticles,
      ];

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _trendingArticles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TrendingCard(
              article: _trendingArticles[index],
              horizontalPadding: 0,
            ),
          );
        },
      ),
    );
  }
}
