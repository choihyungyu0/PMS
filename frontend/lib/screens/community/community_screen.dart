import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _likedPostIds = <String>{};

  static final List<CommunityPostPreview> _demoPosts = [
    CommunityPostPreview(
      id: 'pms-tips',
      title: 'PMS 심할 때\n나만의 극복 방법 공유해요!',
      assetPath: AppAssets.communityAvatarPms,
      likeCount: 23,
      commentCount: 12,
      createdAt: DateTime(2026, 6, 11, 10),
      isRecommended: true,
      safetyTag: '경험 공유',
      layout: CommunityPostLayout.hero,
    ),
    CommunityPostPreview(
      id: 'stretching',
      title: '생리통 완화에 좋은\n스트레칭 동작 추천',
      assetPath: AppAssets.communityStretch,
      likeCount: 18,
      commentCount: 7,
      createdAt: DateTime(2026, 6, 12, 9),
      isRecommended: true,
      safetyTag: '생활 루틴',
      layout: CommunityPostLayout.compact,
    ),
    CommunityPostPreview(
      id: 'pcos-care',
      title: '다낭성난소증후군(PCOS)\n관리 팁 공유',
      assetPath: AppAssets.communityPcos,
      likeCount: 31,
      commentCount: 9,
      createdAt: DateTime(2026, 6, 10, 18),
      isPopular: true,
      safetyTag: '정보성 이야기',
      layout: CommunityPostLayout.compact,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: CommunityTab.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CommunityPostPreview> _postsForTab(CommunityTab tab) {
    final posts = List<CommunityPostPreview>.from(_demoPosts);
    switch (tab) {
      case CommunityTab.recommended:
        posts.sort((a, b) {
          if (a.isRecommended != b.isRecommended) {
            return a.isRecommended ? -1 : 1;
          }
          return b.engagementScore.compareTo(a.engagementScore);
        });
        return posts;
      case CommunityTab.latest:
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return posts;
      case CommunityTab.popular:
        posts.sort((a, b) => b.engagementScore.compareTo(a.engagementScore));
        return posts;
    }
  }

  void _toggleLike(CommunityPostPreview post) {
    setState(() {
      if (_likedPostIds.contains(post.id)) {
        _likedPostIds.remove(post.id);
      } else {
        _likedPostIds.add(post.id);
      }
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  void _showPostMenu(CommunityPostPreview _) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CommunitySheetTile(
                  icon: Icons.outlined_flag_rounded,
                  label: '신고하기',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showSnack('신고 기능은 준비 중이에요.');
                  },
                ),
                _CommunitySheetTile(
                  icon: Icons.visibility_off_outlined,
                  label: '관심 없음',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showSnack('관심 없음 기능은 준비 중이에요.');
                  },
                ),
                _CommunitySheetTile(
                  icon: Icons.close_rounded,
                  label: '닫기',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComposerNotice() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '커뮤니티 글쓰기 기능은 준비 중이에요.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '건강 정보는 진단이나 치료 목적이 아닌 경험 공유로만 작성해주세요.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      floatingActionButton: _CommunityFabButton(onTap: _showComposerNotice),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFEFCFF), Color(0xFFF8F4FF)],
            stops: [0, 0.54, 1],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _CommunityTabBar(controller: _tabController),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEDE8F5)),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: CommunityTab.values.map((tab) {
                    return _CommunityPostList(
                      posts: _postsForTab(tab),
                      likedPostIds: _likedPostIds,
                      onLike: _toggleLike,
                      onComment: (_) => _showSnack('댓글 기능은 준비 중이에요.'),
                      onMore: _showPostMenu,
                      onOpen: (_) => _showSnack('커뮤니티 상세 기능은 준비 중이에요.'),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityTabBar extends StatelessWidget {
  const _CommunityTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height * 0.108)
        .clamp(82.0, 112.0)
        .toDouble();

    return SizedBox(
      height: height,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth =
                  constraints.maxWidth / CommunityTab.values.length;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 190),
                    curve: Curves.easeOut,
                    left: itemWidth * controller.index + itemWidth * 0.20,
                    bottom: 0,
                    child: Container(
                      width: itemWidth * 0.60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(CommunityTab.values.length, (
                      index,
                    ) {
                      final tab = CommunityTab.values[index];
                      final isSelected = controller.index == index;

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.animateTo(index),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 160),
                              curve: Curves.easeOut,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryPurple
                                    : const Color(0xFF56566A),
                                fontSize: 29,
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w800,
                                letterSpacing: 0,
                                height: 1,
                              ),
                              child: Text(tab.label),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CommunityPostList extends StatelessWidget {
  const _CommunityPostList({
    required this.posts,
    required this.likedPostIds,
    required this.onLike,
    required this.onComment,
    required this.onMore,
    required this.onOpen,
  });

  final List<CommunityPostPreview> posts;
  final Set<String> likedPostIds;
  final ValueChanged<CommunityPostPreview> onLike;
  final ValueChanged<CommunityPostPreview> onComment;
  final ValueChanged<CommunityPostPreview> onMore;
  final ValueChanged<CommunityPostPreview> onOpen;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = (screenWidth * 0.095).clamp(26.0, 46.0);
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 116;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        34,
        horizontalPadding,
        bottomPadding,
      ),
      itemCount: posts.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 22),
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return const _CommunitySafetyNotice();
        }

        final post = posts[index];
        final isLiked = likedPostIds.contains(post.id);

        return _CommunityPostCard(
          post: post,
          isLiked: isLiked,
          onTap: () => onOpen(post),
          onLike: () => onLike(post),
          onComment: () => onComment(post),
          onMore: () => onMore(post),
        );
      },
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.isLiked,
    required this.onTap,
    required this.onLike,
    required this.onComment,
    required this.onMore,
  });

  final CommunityPostPreview post;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onMore;

  static const _titleColor = Color(0xFF1D2230);
  static const _iconColor = Color(0xFF8A52F2);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth =
        screenWidth - ((screenWidth * 0.095).clamp(26.0, 46.0) * 2).toDouble();
    final isNarrow = contentWidth < 360;
    final isHero = post.layout == CommunityPostLayout.hero;
    final height = isHero
        ? (MediaQuery.sizeOf(context).height * 0.302).clamp(276.0, 306.0)
        : (MediaQuery.sizeOf(context).height * 0.212).clamp(202.0, 230.0);
    final imageSize = isHero
        ? (contentWidth * 0.36).clamp(126.0, 152.0)
        : (contentWidth * 0.30).clamp(108.0, 132.0);
    final titleSize = isHero
        ? (isNarrow ? 24.0 : 29.0)
        : (isNarrow ? 22.0 : 24.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepPurple.withValues(alpha: 0.09),
                blurRadius: 25,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(right: 20, top: 19, child: _MoreButton(onTap: onMore)),
              if (isHero)
                _HeroPostContent(
                  post: post,
                  imageSize: imageSize,
                  titleSize: titleSize,
                  titleColor: _titleColor,
                  iconColor: _iconColor,
                  isLiked: isLiked,
                  onLike: onLike,
                  onComment: onComment,
                )
              else
                _CompactPostContent(
                  post: post,
                  imageSize: imageSize,
                  titleSize: titleSize,
                  titleColor: _titleColor,
                  iconColor: _iconColor,
                  isLiked: isLiked,
                  onLike: onLike,
                  onComment: onComment,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPostContent extends StatelessWidget {
  const _HeroPostContent({
    required this.post,
    required this.imageSize,
    required this.titleSize,
    required this.titleColor,
    required this.iconColor,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
  });

  final CommunityPostPreview post;
  final double imageSize;
  final double titleSize;
  final Color titleColor;
  final Color iconColor;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: 36,
            top: 28,
            child: _PostImage(size: imageSize, assetPath: post.assetPath),
          ),
          Positioned(
            left: 48,
            top: imageSize + 24,
            right: 20,
            child: Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: titleColor,
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
                height: 1.28,
              ),
            ),
          ),
          Positioned(
            left: 58,
            bottom: 28,
            child: _PostStats(
              likes: post.likeCount + (isLiked ? 1 : 0),
              comments: post.commentCount,
              isLiked: isLiked,
              color: iconColor,
              onLike: onLike,
              onComment: onComment,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactPostContent extends StatelessWidget {
  const _CompactPostContent({
    required this.post,
    required this.imageSize,
    required this.titleSize,
    required this.titleColor,
    required this.iconColor,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
  });

  final CommunityPostPreview post;
  final double imageSize;
  final double titleSize;
  final Color titleColor;
  final Color iconColor;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: 34,
            top: 32,
            child: _PostImage(size: imageSize, assetPath: post.assetPath),
          ),
          Positioned(
            left: imageSize + 48,
            top: 68,
            right: 16,
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                post.title,
                maxLines: 2,
                style: TextStyle(
                  color: titleColor,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  height: 1.32,
                ),
              ),
            ),
          ),
          Positioned(
            left: 58,
            bottom: 28,
            child: _PostStats(
              likes: post.likeCount + (isLiked ? 1 : 0),
              comments: post.commentCount,
              isLiked: isLiked,
              color: iconColor,
              onLike: onLike,
              onComment: onComment,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostImage extends StatelessWidget {
  const _PostImage({required this.size, required this.assetPath});

  final double size;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.20),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(
                color: AppColors.lightPurpleCard,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.primaryPurple,
                  size: 40,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '더보기',
      onPressed: onTap,
      icon: const Icon(Icons.more_horiz_rounded),
      color: const Color(0xFFB797F5),
      iconSize: 30,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 42, height: 42),
    );
  }
}

class _PostStats extends StatelessWidget {
  const _PostStats({
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.color,
    required this.onLike,
    required this.onComment,
  });

  final int likes;
  final int comments;
  final bool isLiked;
  final Color color;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatButton(
          tooltip: '좋아요',
          icon: Icons.favorite_rounded,
          value: likes,
          color: color,
          filled: isLiked,
          onTap: onLike,
        ),
        const SizedBox(width: 34),
        _StatButton(
          tooltip: '댓글',
          icon: Icons.chat_bubble_outline_rounded,
          value: comments,
          color: color,
          filled: false,
          isComment: true,
          onTap: onComment,
        ),
      ],
    );
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton({
    required this.tooltip,
    required this.icon,
    required this.value,
    required this.color,
    required this.filled,
    required this.onTap,
    this.isComment = false,
  });

  final String tooltip;
  final IconData icon;
  final int value;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  final bool isComment;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: Center(
                  child: isComment
                      ? _CommentBubbleIcon(color: color)
                      : Icon(
                          icon,
                          color: color,
                          size: 32,
                          shadows: filled
                              ? [
                                  Shadow(
                                    color: color.withValues(alpha: 0.30),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$value',
                style: const TextStyle(
                  color: Color(0xFF77719C),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentBubbleIcon extends StatelessWidget {
  const _CommentBubbleIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 31,
      height: 31,
      child: CustomPaint(painter: _CommentBubblePainter(color: color)),
    );
  }
}

class _CommentBubblePainter extends CustomPainter {
  const _CommentBubblePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.13,
        size.height * 0.12,
        size.width * 0.72,
        size.height * 0.62,
      ),
      Radius.circular(size.width * 0.17),
    );
    canvas.drawRRect(bubble, paint);

    final tail = Path()
      ..moveTo(size.width * 0.32, size.height * 0.73)
      ..lineTo(size.width * 0.21, size.height * 0.88)
      ..lineTo(size.width * 0.46, size.height * 0.73);
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant _CommentBubblePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _CommunitySafetyNotice extends StatelessWidget {
  const _CommunitySafetyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9E1FF)),
      ),
      child: const Text(
        '커뮤니티 내용은 개인 경험 공유이며 진단이나 치료를 제공하지 않습니다.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.4,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _CommunityFabButton extends StatelessWidget {
  const _CommunityFabButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14, bottom: 8),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        elevation: 12,
        shadowColor: AppColors.deepPurple.withValues(alpha: 0.35),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Ink(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFA35AFF),
                  Color(0xFF7335F2),
                  Color(0xFF5A2BE8),
                ],
              ),
              border: Border.all(color: const Color(0xFFC5A5FF), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Tooltip(
              message: '글쓰기',
              child: Center(
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: CustomPaint(painter: _PlusPainter()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlusPainter extends CustomPainter {
  const _PlusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final length = size.width * 0.62;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.2
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawLine(
        center.translate(-length / 2, 0),
        center.translate(length / 2, 0),
        paint,
      )
      ..drawLine(
        center.translate(0, -length / 2),
        center.translate(0, length / 2),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant _PlusPainter oldDelegate) {
    return false;
  }
}

class _CommunitySheetTile extends StatelessWidget {
  const _CommunitySheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primaryPurple),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      onTap: onTap,
    );
  }
}

class CommunityPostPreview {
  const CommunityPostPreview({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.safetyTag,
    required this.layout,
    this.isRecommended = false,
    this.isPopular = false,
  });

  final String id;
  final String title;
  final String assetPath;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final bool isRecommended;
  final bool isPopular;
  final String safetyTag;
  final CommunityPostLayout layout;

  int get engagementScore => likeCount + commentCount;
}

enum CommunityTab {
  recommended('추천'),
  latest('최신'),
  popular('인기');

  const CommunityTab(this.label);

  final String label;
}

enum CommunityPostLayout { hero, compact }
