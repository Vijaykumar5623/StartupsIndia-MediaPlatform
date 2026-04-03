import '../../../home/domain/models/news_article.dart';
import '../../../home/domain/models/news_feed_data.dart';
import 'source_profile_model.dart';

class TopicSearchItem {
  final String id;
  final String title;
  final String description;
  final String thumbnailAsset;

  const TopicSearchItem({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailAsset,
  });
}

class AuthorItem {
  final String id;
  final String name;
  final String followers;
  final String avatarAsset;

  const AuthorItem({
    required this.id,
    required this.name,
    required this.followers,
    required this.avatarAsset,
  });
}

class MockExploreData {
  static final List<NewsArticle> news = [
    ...NewsFeedData.latestArticles,
    NewsFeedData.trendingArticle,
  ];

  static const List<TopicSearchItem> topics = [
    TopicSearchItem(
      id: 'topic_1',
      title: 'Technology',
      description: 'AI, apps, devices and startup ecosystem updates.',
      thumbnailAsset: 'assets/images/thumb_tech.png',
    ),
    TopicSearchItem(
      id: 'topic_2',
      title: 'Business',
      description: 'Markets, venture funding and global business news.',
      thumbnailAsset: 'assets/images/thumb_business.png',
    ),
    TopicSearchItem(
      id: 'topic_3',
      title: 'Sports',
      description: 'Match reports, previews and athlete interviews.',
      thumbnailAsset: 'assets/images/thumb_sports.png',
    ),
  ];

  static const List<AuthorItem> authors = [
    AuthorItem(
      id: 'author_1',
      name: 'Samantha Reed',
      followers: '1.2M followers',
      avatarAsset: 'assets/images/thumb_politics.png',
    ),
    AuthorItem(
      id: 'author_2',
      name: 'Michael Tan',
      followers: '860K followers',
      avatarAsset: 'assets/images/thumb_tech.png',
    ),
    AuthorItem(
      id: 'author_3',
      name: 'Aarav Sharma',
      followers: '540K followers',
      avatarAsset: 'assets/images/thumb_business.png',
    ),
  ];

  static final Map<String, SourceProfileModel>
  sourceProfilesByAuthorId = <String, SourceProfileModel>{
    'author_1': SourceProfileModel(
      id: 'source_bbc',
      name: 'BBC News',
      avatarUrl: 'assets/icons/bbc.png',
      bio:
          'An operational business division of the British Broadcasting Corporation responsible for gathering and broadcasting news and current affairs.',
      websiteUrl: 'https://www.bbc.com/news',
      followersCount: 1200000,
      followingCount: 124000,
      newsCount: 326,
      isFollowing: true,
      newsArticles: <NewsArticle>[
        NewsFeedData.trendingArticle,
        ...NewsFeedData.latestArticles,
      ],
      recentArticles: <NewsArticle>[
        ...NewsFeedData.latestArticles,
        NewsFeedData.trendingArticle,
      ],
    ),
    'author_2': SourceProfileModel(
      id: 'source_reuters',
      name: 'Reuters',
      avatarUrl: 'assets/images/thumb_politics.png',
      bio:
          'Global reporting agency delivering fast and trusted coverage on politics, markets, and world affairs.',
      websiteUrl: 'https://www.reuters.com',
      followersCount: 860000,
      followingCount: 54000,
      newsCount: 192,
      isFollowing: true,
      newsArticles: <NewsArticle>[...NewsFeedData.latestArticles],
      recentArticles: <NewsArticle>[
        NewsFeedData.latestArticles[1],
        NewsFeedData.latestArticles[3],
        NewsFeedData.latestArticles[0],
      ],
    ),
    'author_3': SourceProfileModel(
      id: 'source_verge',
      name: 'The Verge',
      avatarUrl: 'assets/images/thumb_tech.png',
      bio:
          'Technology publication focused on the future of consumer tech, culture, and digital innovation.',
      websiteUrl: 'https://www.theverge.com',
      followersCount: 540000,
      followingCount: 31000,
      newsCount: 154,
      isFollowing: false,
      newsArticles: <NewsArticle>[
        NewsFeedData.latestArticles[2],
        NewsFeedData.latestArticles[5],
        NewsFeedData.trendingArticle,
      ],
      recentArticles: <NewsArticle>[
        NewsFeedData.latestArticles[5],
        NewsFeedData.latestArticles[2],
      ],
    ),
  };

  static SourceProfileModel sourceProfileForAuthor(AuthorItem author) {
    return sourceProfilesByAuthorId[author.id] ??
        SourceProfileModel(
          id: author.id,
          name: author.name,
          avatarUrl: author.avatarAsset,
          bio: 'Coverage and updates from ${author.name}.',
          websiteUrl: 'https://example.com',
          followersCount: 100000,
          followingCount: 1000,
          newsCount: 20,
          isFollowing: false,
          newsArticles: <NewsArticle>[...news],
          recentArticles: <NewsArticle>[...news],
        );
  }
}
