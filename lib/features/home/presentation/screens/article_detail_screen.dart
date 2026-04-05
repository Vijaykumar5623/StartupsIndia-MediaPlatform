import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/repository/firestore_repository.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../theme/style_guide.dart';
import '../../../explore/data/repositories/mock_source_repository.dart';
import '../../../explore/domain/repositories/source_repository.dart';
import '../../domain/models/news_article.dart';
import 'comments_screen.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final NewsArticle article;
  final SourceRepository? sourceRepository;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    this.sourceRepository,
  });

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  late final SourceRepository _sourceRepository;
  late bool _isFollowing;
  late bool _isLiked;
  late bool _isBookmarked;
  late int _likesCount;
  bool _isUpdatingFollow = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _sourceRepository = widget.sourceRepository ?? MockSourceRepository();
    _isFollowing = widget.article.isSourceFollowing;
    _isLiked = widget.article.isLiked;
    _isBookmarked = widget.article.isBookmarked;
    _likesCount = widget.article.likesCount;
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    try {
      final userModel = await ref
          .read(authRepositoryProvider)
          .getCurrentUserModel();
      if (mounted) {
        setState(() => _userId = userModel?.uid);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscaleWhite,
      appBar: AppBar(
        backgroundColor: AppColors.grayscaleWhite,
        surfaceTintColor: AppColors.grayscaleWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.grayscaleTitleActive,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSharePlaceholder,
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.grayscaleBodyText,
            ),
          ),
          IconButton(
            onPressed: _showMenuPlaceholder,
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.grayscaleBodyText,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSourceRow(),
              const SizedBox(height: 16),
              _buildHeroImage(),
              const SizedBox(height: 14),
              Text(
                widget.article.category,
                style: AppTypography.textSmall.copyWith(
                  color: AppColors.grayscaleBodyText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.article.headline,
                style: AppTypography.displayMediumBold.copyWith(
                  fontSize: 40,
                  height: 1.2,
                  color: AppColors.grayscaleTitleActive,
                ),
              ),
              const SizedBox(height: 16),
              ..._buildBodyParagraphs(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildSourceRow() {
    return Row(
      children: [
        _buildSourceLogo(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.article.sourceName,
                style: AppTypography.textMedium.copyWith(
                  color: AppColors.grayscaleTitleActive,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                widget.article.timeAgo,
                style: AppTypography.textSmall.copyWith(
                  color: AppColors.grayscaleBodyText,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 38,
          child: ElevatedButton(
            onPressed: _isUpdatingFollow ? null : _toggleFollowSource,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDefault,
              foregroundColor: AppColors.grayscaleWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 0,
            ),
            child: _isUpdatingFollow
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.grayscaleWhite,
                    ),
                  )
                : Text(
                    _isFollowing ? 'Following' : 'Follow',
                    style: AppTypography.textSmall.copyWith(
                      color: AppColors.grayscaleWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceLogo() {
    final logo = widget.article.sourceLogoAsset;
    return ClipOval(
      child: SizedBox(
        width: 44,
        height: 44,
        child: logo.startsWith('http')
            ? CachedNetworkImage(
                imageUrl: logo,
                fit: BoxFit.cover,
                placeholder: (context, url) => _logoFallback(),
                errorWidget: (context, url, error) => _logoFallback(),
              )
            : Image.asset(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _logoFallback(),
              ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final image = widget.article.thumbnailAsset;
    return Hero(
      tag: widget.article.id,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: image.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _imageFallback(),
                  errorWidget: (context, url, error) => _imageFallback(),
                )
              : Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _imageFallback(),
                ),
        ),
      ),
    );
  }

  List<Widget> _buildBodyParagraphs() {
    final fallbackBody =
        'This article body will be populated from your API or database.\n\nUse the NewsArticle.body field to pass formatted story paragraphs for optimal reader experience.';
    final raw = widget.article.body.trim().isEmpty
        ? fallbackBody
        : widget.article.body.trim();
    final parts = raw.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

    return parts
        .map(
          (paragraph) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              paragraph.trim(),
              style: AppTypography.textMedium.copyWith(
                fontSize: 17,
                height: 1.55,
                color: AppColors.grayscaleBodyText,
              ),
            ),
          ),
        )
        .toList(growable: false);
  }

  Widget _buildBottomActionBar() {
    return SafeArea(
      top: false,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.grayscaleWhite,
          border: Border(
            top: BorderSide(
              color: AppColors.grayscaleLine.withValues(alpha: 0.8),
            ),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _toggleLike,
              child: Row(
                children: [
                  Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                    size: 22,
                    color: _isLiked
                        ? const Color(0xFFE91E63)
                        : AppColors.grayscaleBodyText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatEngagement(_likesCount),
                    style: AppTypography.textMedium.copyWith(
                      color: AppColors.grayscaleTitleActive,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 26),
            GestureDetector(
              onTap: _openComments,
              child: Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 20,
                    color: AppColors.grayscaleBodyText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatEngagement(widget.article.commentsCount),
                    style: AppTypography.textMedium.copyWith(
                      color: AppColors.grayscaleTitleActive,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _toggleBookmark,
              icon: Icon(
                _isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                size: 23,
                color: _isBookmarked
                    ? AppColors.primaryDefault
                    : AppColors.grayscaleBodyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFollowSource() async {
    setState(() => _isUpdatingFollow = true);

    final updated = await _sourceRepository.toggleFollowSource(
      sourceId: _resolvedSourceId,
      isFollowing: !_isFollowing,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isFollowing = updated;
      _isUpdatingFollow = false;
    });
  }

  String get _resolvedSourceId {
    if (widget.article.sourceId.trim().isNotEmpty) {
      return widget.article.sourceId;
    }
    return widget.article.sourceName.toLowerCase().replaceAll(' ', '_');
  }

  void _toggleLike() async {
    if (_userId == null) return;

    // Optimistic update
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
      if (_likesCount < 0) {
        _likesCount = 0;
      }
    });

    // Persist to Firestore
    try {
      await ref
          .read(firestoreRepositoryProvider)
          .toggleLike(widget.article.id, _userId!);
    } catch (e) {
      // Revert on error
      setState(() {
        _isLiked = !_isLiked;
        _likesCount += _isLiked ? 1 : -1;
      });
    }
  }

  void _toggleBookmark() async {
    if (_userId == null) return;

    // Optimistic update
    setState(() => _isBookmarked = !_isBookmarked);

    // Persist to Firestore
    try {
      await ref
          .read(firestoreRepositoryProvider)
          .toggleBookmark(widget.article.id, _userId!);
    } catch (e) {
      // Revert on error
      setState(() => _isBookmarked = !_isBookmarked);
    }
  }

  void _showSharePlaceholder() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share action coming soon')));
  }

  void _showMenuPlaceholder() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Menu action coming soon')));
  }

  void _openComments() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommentsScreen(article: widget.article),
      ),
    );
  }

  String _formatEngagement(int value) {
    if (value >= 1000) {
      final kValue = value / 1000;
      return kValue % 1 == 0
          ? '${kValue.toStringAsFixed(0)}K'
          : '${kValue.toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  Widget _logoFallback() {
    return Container(
      color: AppColors.grayscaleSecondaryButton,
      alignment: Alignment.center,
      child: const Icon(
        Icons.public_rounded,
        color: AppColors.grayscaleButtonText,
        size: 20,
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.grayscaleSecondaryButton,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.grayscaleButtonText,
        size: 30,
      ),
    );
  }
}
