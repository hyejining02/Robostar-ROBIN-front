import 'package:flutter/material.dart';

import '../models/access_control.dart';
import '../theme/robin_theme.dart';
import 'user_profile.dart';

class RobinSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const RobinSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      color: RobinTheme.sidebarBg,
      child: Column(
        children: [
          _logo(),
          _profile(),
          Expanded(
            child: ValueListenableBuilder<RobinUserProfile>(
              valueListenable: robinUserProfile,
              builder: (context, profile, _) => ListView(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
                children: [
                  for (final group in _groupsFor(profile)) _group(group),
                ],
              ),
            ),
          ),
          _todo(),
          _logout(context),
        ],
      ),
    );
  }

  Widget _logo() => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: RobinTheme.sidebarBorder)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: RobinTheme.primary,
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.center,
              child: const Text('R',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17)),
            ),
            const SizedBox(width: 10),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ROBIN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2)),
                Text('수주관리시스템',
                    style: TextStyle(color: Color(0xFF99999F), fontSize: 10)),
              ],
            ),
          ],
        ),
      );

  Widget _profile() => ValueListenableBuilder<RobinUserProfile>(
        valueListenable: robinUserProfile,
        builder: (context, profile, _) => Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: RobinTheme.sidebarActive,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: RobinTheme.primary,
                child: Text(profile.name.isEmpty ? '?' : profile.name[0],
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${profile.name} ${profile.rank}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(profile.department,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFFAAAAB0), fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _group(_MenuGroup group) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 5),
                child: Text(group.label,
                    style: const TextStyle(
                        color: Color(0xFF77777D),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .6)),
              ),
            ...group.items.map(_item),
          ],
        ),
      );

  Widget _item(_MenuItem item) {
    final active = selectedIndex == item.index;
    return InkWell(
      onTap: () => onItemSelected(item.index),
      borderRadius: BorderRadius.circular(7),
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: active ? RobinTheme.sidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: active
              ? const Border(
                  left: BorderSide(color: RobinTheme.primary, width: 3))
              : null,
        ),
        child: Row(
          children: [
            Icon(item.icon,
                size: 18,
                color: active ? Colors.white : const Color(0xFF99999F)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item.label,
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFFB8B8BC),
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  )),
            ),
            if (item.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: RobinTheme.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(item.badge!,
                    style: const TextStyle(color: Colors.white, fontSize: 9)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _todo() => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: RobinTheme.primary.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: RobinTheme.primary.withValues(alpha: .35)),
        ),
        child: const Row(
          children: [
            Icon(Icons.notifications_active_outlined,
                color: Color(0xFFFFBACB), size: 18),
            SizedBox(width: 9),
            Expanded(
              child: Text('내 To-Do  4건',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.chevron_right, color: Color(0xFF99999F), size: 17),
          ],
        ),
      );

  Widget _logout(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFAAAAB0),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            ),
            icon: const Icon(Icons.logout, size: 17),
            label: const Text('로그아웃'),
          ),
        ),
      );

  List<_MenuGroup> _groupsFor(RobinUserProfile profile) {
    final allowed = profile.isAdmin
        ? portalTabPermissions.map((tab) => tab.index).toSet()
        : departmentTabPermissions.value[profile.departmentPermission] ?? {0};
    List<_MenuItem> visible(List<_MenuItem> items) =>
        items.where((item) => allowed.contains(item.index)).toList();

    return [
      _MenuGroup(
          '홈',
          visible(const [
            _MenuItem(Icons.home_outlined, 'Home', 0),
          ])),
      _MenuGroup(
          '수주/프로젝트 관리',
          visible(const [
            _MenuItem(Icons.account_tree_outlined, '파이프라인 등록', 1, badge: '6'),
            _MenuItem(Icons.request_quote_outlined, '수주관리', 2),
            _MenuItem(Icons.view_timeline_outlined, '프로젝트 관리', 3),
          ])),
      _MenuGroup(
          'AX Board',
          visible(const [
            _MenuItem(Icons.grid_view_outlined, 'AX Board', 4),
            _MenuItem(Icons.auto_awesome_outlined, 'AI Assistant', 5),
            _MenuItem(Icons.campaign_outlined, '공지사항', 6),
            _MenuItem(Icons.update_outlined, '로그 및 이슈 조회', 7),
            _MenuItem(Icons.help_outline, '자주 묻는 질문', 8),
          ])),
      _MenuGroup(
        '시스템 관리',
        profile.isAdmin
            ? const [
                _MenuItem(Icons.sync_alt_outlined, '연계 모니터링', 9),
                _MenuItem(Icons.people_alt_outlined, '직원 관리', 10),
                _MenuItem(Icons.admin_panel_settings_outlined, '권한 관리', 11),
                _MenuItem(Icons.person_outline, '마이페이지', 12),
              ]
            : const [
                _MenuItem(Icons.person_outline, '마이페이지', 12),
              ],
      ),
    ].where((group) => group.items.isNotEmpty).toList();
  }
}

class _MenuGroup {
  final String label;
  final List<_MenuItem> items;
  const _MenuGroup(this.label, this.items);
}

class _MenuItem {
  final IconData icon;
  final String label;
  final int index;
  final String? badge;
  const _MenuItem(this.icon, this.label, this.index, {this.badge});
}
