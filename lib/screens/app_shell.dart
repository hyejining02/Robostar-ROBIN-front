import 'package:flutter/material.dart';
import '../models/access_control.dart';
import '../theme/robin_theme.dart';
import '../widgets/sidebar.dart';
import '../widgets/user_profile.dart';
import 'access_management_screen.dart';
import 'dashboard_screen.dart';
import 'portal_module_screen.dart';
import 'story_line_screens.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = robinUserProfile.value.isDealer ? 1 : 0;
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(onNavigate: _navigate);
      case 1:
        return PortalModuleScreen(
          type: PortalModule.pipeline,
          onNavigate: _navigate,
        );
      case 2:
        return const OrderManagementScreen();
      case 3:
        return const ProjectManagementScreen();
      case 4:
        return const PortalModuleScreen(type: PortalModule.organizationApps);
      case 5:
        return const PortalModuleScreen(type: PortalModule.aiAssistant);
      case 6:
        return const PortalModuleScreen(type: PortalModule.notice);
      case 7:
        return const PortalModuleScreen(type: PortalModule.updateHistory);
      case 8:
        return const PortalModuleScreen(type: PortalModule.faq);
      case 9:
        return const PortalModuleScreen(type: PortalModule.integration);
      case 10:
        return const EmployeeManagementScreen();
      case 11:
        return const TeamManagementScreen();
      case 12:
        return const PermissionManagementScreen();
      case 13:
        return const PortalModuleScreen(type: PortalModule.myPage);
      default:
        return _PlaceholderScreen(label: _menuLabels[index]);
    }
  }

  void _navigate(int index) {
    final profile = robinUserProfile.value;
    final allowedBusinessTabs =
        departmentTabPermissions.value[profile.departmentPermission] ?? {0};
    final allowed = profile.isAdmin ||
        (index == 13 && !profile.isDealer) ||
        (index <= 8 && allowedBusinessTabs.contains(index));
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('접근 권한이 없는 메뉴입니다.')),
      );
      return;
    }
    setState(() => _selectedIndex = index);
  }

  static const _menuLabels = [
    'Home',
    '파이프라인 등록',
    '수주관리',
    '프로젝트 관리',
    'AX Board',
    'AI Assistant',
    '공지사항',
    '로그 및 이슈 조회',
    '자주 묻는 질문',
    '연계 모니터링',
    '직원 관리',
    '팀 관리',
    '권한 관리',
    '마이페이지',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          RobinSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: _navigate,
          ),
          Expanded(child: _buildScreen(_selectedIndex)),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RobinTheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_outlined,
                size: 48, color: RobinTheme.textMuted),
            const SizedBox(height: 16),
            Text(label, style: RobinTheme.headingLg),
            const SizedBox(height: 8),
            Text('준비 중인 페이지입니다.', style: RobinTheme.bodySm),
          ],
        ),
      ),
    );
  }
}
