import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/style_guide.dart';
import '../widgets/notification_tile.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../notifications/domain/models/app_notification.dart';
import '../../../../core/utils/time_format_helper.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final Set<String> _followingIds = {'follow_01'};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final uid = ref.watch(authStateChangesProvider).value?.uid;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.grayscaleSecondaryButton,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) => _buildList(notifications, isDark, uid),
                loading: () => _buildList(const [], isDark, uid),
                error: (_, _) => _buildList(const [], isDark, uid),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteOne(String? uid, String id) {
    if (uid == null) return;
    ref.read(notificationRepositoryProvider).deleteNotification(uid, id);
  }

  Future<void> _clearAll(String? uid) async {
    if (uid == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.grayscaleWhite,
        title: Text(
          'Clear all notifications?',
          style: AppTypography.textSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.grayscaleTitleActive,
          ),
        ),
        content: Text(
          'This removes every notification and cannot be undone.',
          style: AppTypography.textSmall.copyWith(
            fontSize: 13,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.grayscaleBodyText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Clear all',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(notificationRepositoryProvider).deleteAllNotifications(uid);
    }
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.grayscaleWhite;
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.grayscaleLine;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.grayscaleTitleActive;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: textColor,
              size: 22,
            ),
          ),
          Expanded(
            child: Text(
              'Notifications',
              textAlign: TextAlign.center,
              style: AppTypography.textSmall.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          // Balance spacer
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildList(
    List<AppNotification> notifications,
    bool isDark,
    String? uid,
  ) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.grayscaleButtonText,
            ),
            const SizedBox(height: 12),
            Text(
              'No notifications yet',
              style: AppTypography.textSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.grayscaleBodyText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You\'re all caught up!',
              style: AppTypography.textSmall.copyWith(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.grayscaleButtonText,
              ),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfYesterday = startOfToday.subtract(const Duration(days: 1));

    final today = <AppNotification>[];
    final yesterday = <AppNotification>[];
    final older = <AppNotification>[];

    for (final n in notifications) {
      if (n.createdAt.isAfter(startOfToday)) {
        today.add(n);
      } else if (n.createdAt.isAfter(startOfYesterday)) {
        yesterday.add(n);
      } else {
        older.add(n);
      }
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (today.isNotEmpty) ...[
          _buildGroupHeader('Today', isDark),
          _buildGroupSliver(today, isDark, uid),
        ],
        if (yesterday.isNotEmpty) ...[
          _buildGroupHeader('Yesterday', isDark),
          _buildGroupSliver(yesterday, isDark, uid),
        ],
        if (older.isNotEmpty) ...[
          _buildGroupHeader('Earlier', isDark),
          _buildGroupSliver(older, isDark, uid),
        ],
        SliverToBoxAdapter(child: _buildClearAll(isDark, uid)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildClearAll(bool isDark, String? uid) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextButton.icon(
        onPressed: () => _clearAll(uid),
        icon: const Icon(
          Icons.delete_sweep_outlined,
          size: 18,
          color: Color(0xFFEF4444),
        ),
        label: Text(
          'Clear all',
          style: AppTypography.textSmall.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFEF4444),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildGroupHeader(String title, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        child: Text(
          title.toUpperCase(),
          style: AppTypography.textSmall.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.grayscaleBodyText,
          ),
        ),
      ),
    );
  }

  SliverList _buildGroupSliver(
    List<AppNotification> items,
    bool isDark,
    String? uid,
  ) {
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return NotificationTile(
          type: item.type,
          title: item.title,
          subtitle: item.subtitle,
          timeAgo: formatArticleTimestamp(item.createdAt),
          avatarLabel: item.avatarLabel,
          isDark: isDark,
          isFollowing: _followingIds.contains(item.id),
          onDelete: () => _deleteOne(uid, item.id),
          onFollowTap: item.type == NotificationType.follow
              ? () {
                  setState(() {
                    if (_followingIds.contains(item.id)) {
                      _followingIds.remove(item.id);
                    } else {
                      _followingIds.add(item.id);
                    }
                  });
                }
              : null,
        );
      },
    );
  }
}
