import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../state/auth_controller.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({
    super.key,
    required this.authController,
    this.onClose,
    this.onOpenReport,
    this.onOpenRecord,
  });

  final AuthController authController;
  final VoidCallback? onClose;
  final VoidCallback? onOpenReport;
  final VoidCallback? onOpenRecord;

  static const _menuItems = [
    _MyPageMenuData(
      title: '내 정보',
      assetPath: AppAssets.mypageInfo,
      action: _MyPageMenuAction.info,
    ),
    _MyPageMenuData(
      title: '내 리포트',
      assetPath: AppAssets.mypageReport,
      action: _MyPageMenuAction.report,
    ),
    _MyPageMenuData(
      title: '내 기록',
      assetPath: AppAssets.mypageRecord,
      action: _MyPageMenuAction.record,
    ),
    _MyPageMenuData(
      title: '알림 설정',
      assetPath: AppAssets.mypageNotification,
      action: _MyPageMenuAction.notification,
    ),
    _MyPageMenuData(
      title: '데이터 백업',
      assetPath: AppAssets.mypageBackup,
      action: _MyPageMenuAction.backup,
    ),
    _MyPageMenuData(
      title: '고객센터',
      assetPath: AppAssets.mypageCustomerCenter,
      action: _MyPageMenuAction.customerCenter,
    ),
    _MyPageMenuData(
      title: '설정',
      assetPath: AppAssets.mypageSettings,
      action: _MyPageMenuAction.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final nickname = _displayNickname(authController.user?.nickname);
        final showProfileNotice =
            authController.user == null &&
            authController.status == AuthStatus.authenticated;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFFCFAFF), Color(0xFFF2ECFF)],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: CustomPaint(painter: _MyPageBg())),
              SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontalPadding = (constraints.maxWidth * 0.05)
                        .clamp(18.0, 28.0)
                        .toDouble();
                    final profileHeight = (constraints.maxHeight * 0.18)
                        .clamp(142.0, 176.0)
                        .toDouble();

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        18,
                        horizontalPadding,
                        26,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: _CloseButton(
                              onTap: () => _handleClose(context),
                            ),
                          ),
                          const SizedBox(height: 28),
                          _ProfileCard(
                            height: profileHeight,
                            nickname: nickname,
                            loading:
                                authController.status == AuthStatus.checking,
                          ),
                          if (showProfileNotice) ...[
                            const SizedBox(height: 12),
                            const _ProfileNotice(),
                          ],
                          const SizedBox(height: 28),
                          _MenuPanel(
                            items: _menuItems,
                            onTap: (action) => _handleMenuTap(context, action),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _displayNickname(String? value) {
    final nickname = value?.trim();
    if (nickname == null || nickname.isEmpty) {
      return '사용자님';
    }
    final looksBroken =
        RegExp(r'^\?+$').hasMatch(nickname) || nickname.contains('�');
    if (looksBroken) {
      return '사용자님';
    }
    if (nickname.endsWith('님')) {
      return nickname;
    }
    return '$nickname님';
  }

  void _handleClose(BuildContext context) {
    if (onClose != null) {
      onClose!();
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  void _handleMenuTap(BuildContext context, _MyPageMenuAction action) {
    switch (action) {
      case _MyPageMenuAction.info:
        _showPlaceholderSheet(context, '내 정보', '내 정보 화면은 준비 중이에요.');
        break;
      case _MyPageMenuAction.report:
        if (onOpenReport != null) {
          onOpenReport!();
        } else {
          _showPlaceholderSheet(context, '내 리포트', '리포트 화면은 준비 중이에요.');
        }
        break;
      case _MyPageMenuAction.record:
        if (onOpenRecord != null) {
          onOpenRecord!();
        } else {
          _showPlaceholderSheet(context, '내 기록', '기록 화면은 준비 중이에요.');
        }
        break;
      case _MyPageMenuAction.notification:
        _showPlaceholderSheet(context, '알림 설정', '알림 설정 기능은 준비 중이에요.');
        break;
      case _MyPageMenuAction.backup:
        _showPlaceholderSheet(context, '데이터 백업', '데이터 백업 기능은 준비 중이에요.');
        break;
      case _MyPageMenuAction.customerCenter:
        _showPlaceholderSheet(
          context,
          '고객센터',
          '고객센터 기능은 준비 중이에요.\n문의가 필요한 경우 설정에서 안내할 예정입니다.',
        );
        break;
      case _MyPageMenuAction.settings:
        _showSettingsSheet(context);
        break;
    }
  }

  void _showPlaceholderSheet(
    BuildContext context,
    String title,
    String message,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _MyPageSheet(
          title: title,
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.55,
            ),
          ),
        );
      },
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _MyPageSheet(
          title: '설정',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: '로그아웃',
                subtitle: '저장된 로그인 토큰을 지우고 처음 화면으로 돌아가요.',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  authController.logout();
                },
              ),
              const SizedBox(height: 10),
              const _SettingsInfo(title: '앱 버전', value: 'MVP 1.0.0'),
              const SizedBox(height: 10),
              const _SettingsInfo(
                title: '개인정보 안내',
                value: '비밀번호, 토큰, 원본 건강 기록은 이 화면에 표시하지 않아요.',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.height,
    required this.nickname,
    required this.loading,
  });

  final double height;
  final String nickname;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final avatarSize = (height * 0.72).clamp(96.0, 126.0).toDouble();

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFAF7FF), Color(0xFFF0E7FF)],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.86),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D6BFF).withValues(alpha: 0.16),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.mypageProfileCardBg,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const CustomPaint(painter: _ProfilePattern());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              children: [
                _Avatar(size: avatarSize),
                const SizedBox(width: 26),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: loading
                            ? const _NameSkeleton()
                            : Text(
                                nickname,
                                key: ValueKey(nickname),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF12132C),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                  height: 1.05,
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '매일 정보 관리',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF625F80),
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 8,
      height: size + 8,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.82),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          AppAssets.mypageAvatar,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(
              color: Color(0xFFF4ECFF),
              child: Center(
                child: Text(
                  'MC',
                  style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({required this.items, required this.onTap});

  final List<_MyPageMenuData> items;
  final ValueChanged<_MyPageMenuAction> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.86),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.09),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 9),
            child: _MenuTile(item: item, onTap: () => onTap(item.action)),
          );
        }),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item, required this.onTap});

  final _MyPageMenuData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 82,
          padding: const EdgeInsets.fromLTRB(10, 8, 18, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEDE8F7), width: 0.9),
          ),
          child: Row(
            children: [
              _MenuIcon(assetPath: item.assetPath),
              const SizedBox(width: 26),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF10122B),
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF6A4DB8),
                size: 38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF1E9FF)],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 48,
          height: 48,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 52,
          height: 52,
          child: Icon(Icons.close_rounded, color: Color(0xFF0E1025), size: 40),
        ),
      ),
    );
  }
}

class _ProfileNotice extends StatelessWidget {
  const _ProfileNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DFFF)),
      ),
      child: const Text(
        '사용자 정보를 불러오지 못했어요.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NameSkeleton extends StatelessWidget {
  const _NameSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE5FF),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _MyPageSheet extends StatelessWidget {
  const _MyPageSheet({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8F4FF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.deepPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsInfo extends StatelessWidget {
  const _SettingsInfo({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE8F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPageMenuData {
  const _MyPageMenuData({
    required this.title,
    required this.assetPath,
    required this.action,
  });

  final String title;
  final String assetPath;
  final _MyPageMenuAction action;
}

enum _MyPageMenuAction {
  info,
  report,
  record,
  notification,
  backup,
  customerCenter,
  settings,
}

class _MyPageBg extends CustomPainter {
  const _MyPageBg();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE2D7FF).withValues(alpha: 0.8),
              const Color(0xFFF6F1FF).withValues(alpha: 0.15),
            ],
          ).createShader(
            Rect.fromLTWH(
              -size.width * 0.22,
              -size.height * 0.14,
              size.width * 0.64,
              size.height * 0.33,
            ),
          );

    final topShape = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.36, 0)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.08,
        size.width * 0.10,
        size.height * 0.09,
        0,
        size.height * 0.16,
      )
      ..close();
    canvas.drawPath(topShape, paint);

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(size.width * 0.19, size.height * 0.06),
      4,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.62, size.height * 0.11),
      3,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MyPageBg oldDelegate) => false;
}

class _ProfilePattern extends CustomPainter {
  const _ProfilePattern();

  @override
  void paint(Canvas canvas, Size size) {
    final purple = Paint()
      ..color = const Color(0xFFB99DFF).withValues(alpha: 0.34);
    canvas.drawCircle(
      Offset(size.width * 0.91, size.height * 0.92),
      size.width * 0.31,
      purple,
    );
    canvas.drawCircle(
      Offset(size.width * 0.94, size.height * 0.66),
      size.width * 0.18,
      Paint()..color = const Color(0xFFDACEFF).withValues(alpha: 0.42),
    );

    final curvePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final curve = Path()
      ..moveTo(size.width * 0.78, size.height * 0.75)
      ..cubicTo(
        size.width * 0.89,
        size.height * 0.52,
        size.width * 0.96,
        size.height * 0.50,
        size.width,
        size.height * 0.45,
      );
    canvas.drawPath(curve, curvePaint);

    final glow = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.43), 4, glow);
    canvas.drawCircle(Offset(size.width * 0.66, size.height * 0.01), 5, glow);
  }

  @override
  bool shouldRepaint(covariant _ProfilePattern oldDelegate) => false;
}
