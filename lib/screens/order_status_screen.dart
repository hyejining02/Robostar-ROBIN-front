import 'package:flutter/material.dart';
import '../models/order_project.dart';
import '../theme/robin_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/stat_cards.dart';
import '../widgets/order_table.dart';
import '../widgets/detail_panel.dart';
import '../widgets/project_detail_view.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  OrderProject? _selectedProject;
  OrderProject? _detailProject;
  String? _recentOrderNo;

  @override
  void initState() {
    super.initState();
    _recentOrderNo = SampleData.recentlyRegisteredOrderNo;
    _selectedProject = _recentOrderNo == null
        ? SampleData.projects.first
        : SampleData.projects.firstWhere(
            (project) => project.orderNo == _recentOrderNo,
            orElse: () => SampleData.projects.first,
          );
    SampleData.recentlyRegisteredOrderNo = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RobinTheme.background,
      appBar: RobinAppBar(title: '대리점 포털'),
      body: _detailProject != null
          ? ProjectDetailView(
              project: _detailProject!,
              onBack: () => setState(() => _detailProject = null),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 메인 콘텐츠 ──────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 페이지 헤더
                        _PageHeader(),
                        if (_recentOrderNo != null) ...[
                          const SizedBox(height: 12),
                          _RegistrationNotice(orderNo: _recentOrderNo!),
                        ],
                        const SizedBox(height: 20),

                        // 통계 카드
                        const StatCardsRow(),
                        const SizedBox(height: 20),

                        // 수주 테이블
                        OrderTable(
                          projects: SampleData.projects,
                          selectedOrderNo: _selectedProject?.orderNo,
                          onRowTap: (p) => setState(() => _selectedProject = p),
                        ),
                        const SizedBox(height: 20),

                        // 푸터
                        _Footer(),
                      ],
                    ),
                  ),
                ),

                // --- 오른쪽 디테일 패널 ---
                ProjectDetailPanel(
                  project: _selectedProject,
                  onViewDetails: _selectedProject == null
                      ? null
                      : () => setState(() => _detailProject = _selectedProject),
                ),
              ],
            ),
    );
  }
}

class _RegistrationNotice extends StatelessWidget {
  final String orderNo;

  const _RegistrationNotice({required this.orderNo});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: RobinTheme.successLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: RobinTheme.success.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 19, color: RobinTheme.success),
            const SizedBox(width: 9),
            Text('$orderNo 수주가 등록되어 현황에 반영되었습니다.',
                style: RobinTheme.bodyMd.copyWith(
                    color: RobinTheme.success, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('수주 현황', style: RobinTheme.headingLg),
        const SizedBox(height: 4),
        Text(
          '등록하신 수주 및 프로젝트의 진행 상황을 확인할 수 있습니다.',
          style: RobinTheme.bodySm,
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '© 2027 ROBOSTAR Co., Ltd. All Rights Reserved.',
        style: RobinTheme.bodySm.copyWith(fontSize: 11),
      ),
    );
  }
}
