import 'package:timeago/timeago.dart' as timeago;

String formatArticleTimestamp(DateTime? createdAt, {String fallback = 'now'}) {
  if (createdAt == null) return fallback;
  return timeago.format(createdAt, locale: 'en_short');
}
