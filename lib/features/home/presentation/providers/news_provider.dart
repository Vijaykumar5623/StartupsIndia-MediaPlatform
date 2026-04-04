import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/news_article_model.dart';
import '../../../../core/repository/firestore_repository.dart';

final latestNewsProvider = StreamProvider<List<NewsArticleModel>>((ref) {
  return ref.watch(firestoreRepositoryProvider).getLatestNews();
});

final trendingNewsProvider = StreamProvider<List<NewsArticleModel>>((ref) {
  return ref.watch(firestoreRepositoryProvider).getTrendingNews();
});
