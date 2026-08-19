import 'package:flutter/material.dart';
import '../theme/robin_theme.dart';
import 'notification_center.dart';
import 'user_profile.dart';

class RobinAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const RobinAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: RobinTheme.surface,
        border: Border(bottom: BorderSide(color: RobinTheme.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 페이지 제목
          Text(title, style: RobinTheme.headingSm.copyWith(fontSize: 15)),
          const SizedBox(width: 24),

          // 검색창
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: RobinTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: RobinTheme.border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search, size: 16, color: RobinTheme.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '프로젝트, 수주번호, 고객사로 검색하세요.',
                          hintStyle: RobinTheme.bodySm.copyWith(
                            color: RobinTheme.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: RobinTheme.bodyMd,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // 알림 아이콘
          _IconBtn(
            icon: Icons.notifications_outlined,
            badgeCount: unreadRobinNotificationCount,
            onPressed: () => showRobinNotificationCenter(context),
          ),
          const SizedBox(width: 4),

          // 유저 정보
          ValueListenableBuilder<RobinUserProfile>(
            valueListenable: robinUserProfile,
            builder: (context, profile, _) => InkWell(
              onTap: () => showRobinProfileEditor(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: RobinTheme.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_outline,
                            size: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.department,
                            style: RobinTheme.headingSm.copyWith(fontSize: 12)),
                        Text('${profile.name} ${profile.rank}',
                            style: RobinTheme.bodySm),
                      ],
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        size: 16, color: RobinTheme.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback? onPressed;
  const _IconBtn({required this.icon, this.badgeCount = 0, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon, size: 20, color: RobinTheme.textSecondary),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            minimumSize: const Size(36, 36),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: RobinTheme.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
