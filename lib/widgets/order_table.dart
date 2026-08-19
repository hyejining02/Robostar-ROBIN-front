import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_project.dart';
import '../theme/robin_theme.dart';

class OrderTable extends StatefulWidget {
  final List<OrderProject> projects;
  final ValueChanged<OrderProject>? onRowTap;
  final String? selectedOrderNo;

  const OrderTable({
    super.key,
    required this.projects,
    this.onRowTap,
    this.selectedOrderNo,
  });

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RobinTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: RobinTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilterBar(),
          const Divider(height: 1),
          _buildTableHeader(),
          const Divider(height: 1),
          ...widget.projects.map((p) => _buildRow(p)),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _FilterItem(
              label: '기간',
              value: '2024-05-01 ~ 2024-05-31',
              icon: Icons.calendar_today_outlined),
          _FilterDropdown(label: '프로젝트 구분'),
          _FilterDropdown(label: '프로젝트 종류'),
          _FilterDropdown(label: '고객사'),
          _FilterDropdown(label: '진행 상태'),
          const SizedBox(width: 4),
          // 검색창
          SizedBox(
            width: 220,
            height: 34,
            child: TextField(
              decoration: InputDecoration(
                hintText: '수주번호 / 프로젝트명 검색',
                hintStyle:
                    RobinTheme.bodySm.copyWith(color: RobinTheme.textMuted),
                prefixIcon:
                    Icon(Icons.search, size: 16, color: RobinTheme.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: RobinTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: RobinTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: RobinTheme.accent),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: RobinTheme.bodyMd.copyWith(fontSize: 12),
            ),
          ),
          _ResetButton(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: RobinTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _HeaderCell('수주번호', flex: 3),
          _HeaderCell('프로젝트명', flex: 4),
          _HeaderCell('프로젝트 구분', flex: 2),
          _HeaderCell('프로젝트 종류', flex: 2),
          _HeaderCell('고객사', flex: 2),
          _HeaderCell('수주금액(만원)', flex: 2),
          _HeaderCell('프로젝트 상태', flex: 3),
          _HeaderCell('전체 진행률', flex: 3),
          // 진행 단계 (6개)
          _HeaderCell('수주', flex: 1),
          _HeaderCell('설계', flex: 1),
          _HeaderCell('구매', flex: 1),
          _HeaderCell('생산', flex: 1),
          _HeaderCell('납품/설치', flex: 1),
          _HeaderCell('운전/검수', flex: 1),
          _HeaderCell('납기일', flex: 3),
          _HeaderCell('최종 업데이트', flex: 3),
        ],
      ),
    );
  }

  Widget _buildRow(OrderProject p) {
    final isSelected = widget.selectedOrderNo == p.orderNo;
    return InkWell(
      onTap: () => widget.onRowTap?.call(p),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? RobinTheme.accentLight : Colors.transparent,
          border: const Border(bottom: BorderSide(color: RobinTheme.divider)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // 수주번호
            Expanded(
                flex: 3,
                child: Text(
                  p.orderNo,
                  style: RobinTheme.bodyMd.copyWith(
                    color: RobinTheme.accent,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                )),
            // 프로젝트명
            Expanded(
                flex: 4,
                child: Text(
                  p.projectName,
                  style: RobinTheme.bodyMd.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                )),
            // 구분 배지
            Expanded(flex: 2, child: _CategoryBadge(p.category)),
            // 종류
            Expanded(
                flex: 2,
                child: Text(
                  p.projectType,
                  style: RobinTheme.bodySm.copyWith(fontSize: 11),
                )),
            // 고객사
            Expanded(
                flex: 2,
                child: Text(
                  p.customer,
                  style: RobinTheme.bodySm,
                )),
            // 수주금액
            Expanded(
                flex: 2,
                child: Text(
                  NumberFormat('#,###').format(p.amount),
                  style: RobinTheme.bodyMd.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )),
            // 상태
            Expanded(flex: 3, child: _StatusBadge(p.status)),
            // 진행률
            Expanded(flex: 3, child: _ProgressBar(value: p.progress)),
            // 단계 아이콘들
            Expanded(flex: 1, child: _StepIcon(p.stepOrder, true)),
            Expanded(flex: 1, child: _StepIcon(p.stepDesign, p.stepOrder)),
            Expanded(flex: 1, child: _StepIcon(p.stepPurchase, p.stepDesign)),
            Expanded(
                flex: 1, child: _StepIcon(p.stepProduction, p.stepPurchase)),
            Expanded(
                flex: 1, child: _StepIcon(p.stepDelivery, p.stepProduction)),
            Expanded(
                flex: 1, child: _StepIcon(p.stepOperation, p.stepDelivery)),
            // 납기일
            Expanded(
                flex: 3,
                child: Text(
                  _dateFmt.format(p.dueDate),
                  style: RobinTheme.bodySm.copyWith(fontSize: 11),
                )),
            // 최종 업데이트
            Expanded(
                flex: 3,
                child: Text(
                  _dateFmt.format(p.lastUpdated),
                  style: RobinTheme.bodySm.copyWith(fontSize: 11),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final added = widget.projects.length - SampleData.initialProjectCount;
    final total = 28 + (added < 0 ? 0 : added);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('전체 $total건', style: RobinTheme.bodySm),
          const Spacer(),
          _PageBtn(icon: Icons.chevron_left, onTap: () {}),
          _PageNum(n: 1, isActive: true),
          _PageNum(n: 2),
          _PageNum(n: 3),
          _PageBtn(icon: Icons.chevron_right, onTap: () {}),
        ],
      ),
    );
  }
}

// ── 작은 컴포넌트들 ─────────────────────────────────────────

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, {required this.flex});

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Text(label, style: RobinTheme.labelXs),
      );
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge(this.category);

  @override
  Widget build(BuildContext context) {
    final isRobot = category == '로봇';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isRobot ? const Color(0xFFEFF6FF) : const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isRobot ? RobinTheme.accent : const Color(0xFF7C3AED),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: RobinTheme.statusBg(status),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: RobinTheme.statusFg(status),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
}

class _ProgressBar extends StatelessWidget {
  final int value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    Color barColor;
    if (value >= 90)
      barColor = RobinTheme.success;
    else if (value >= 50)
      barColor = RobinTheme.accent;
    else
      barColor = RobinTheme.warning;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: RobinTheme.divider,
              valueColor: AlwaysStoppedAnimation(barColor),
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text('$value%',
            style: RobinTheme.labelXs.copyWith(
              fontSize: 10,
              color: barColor,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}

class _StepIcon extends StatelessWidget {
  final bool done;
  final bool prevDone;
  const _StepIcon(this.done, this.prevDone);

  @override
  Widget build(BuildContext context) {
    if (done) {
      return const Icon(Icons.check_circle,
          size: 16, color: RobinTheme.success);
    } else if (prevDone) {
      return Icon(Icons.radio_button_unchecked,
          size: 16, color: RobinTheme.warning.withOpacity(0.7));
    }
    return const Text('-',
        style: TextStyle(color: RobinTheme.textMuted, fontSize: 12));
  }
}

class _FilterItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _FilterItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: RobinTheme.border),
        borderRadius: BorderRadius.circular(6),
        color: RobinTheme.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label  ', style: RobinTheme.labelXs),
          Text(value, style: RobinTheme.bodySm.copyWith(fontSize: 12)),
          const SizedBox(width: 4),
          Icon(icon, size: 13, color: RobinTheme.textMuted),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  const _FilterDropdown({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: RobinTheme.border),
        borderRadius: BorderRadius.circular(6),
        color: RobinTheme.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: RobinTheme.bodySm.copyWith(fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down,
              size: 14, color: RobinTheme.textMuted),
        ],
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: RobinTheme.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh,
                size: 13, color: RobinTheme.textSecondary),
            const SizedBox(width: 4),
            Text('초기화', style: RobinTheme.bodySm.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PageBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            border: Border.all(color: RobinTheme.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: RobinTheme.textSecondary),
        ),
      );
}

class _PageNum extends StatelessWidget {
  final int n;
  final bool isActive;
  const _PageNum({required this.n, this.isActive = false});

  @override
  Widget build(BuildContext context) => Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive ? RobinTheme.accent : Colors.transparent,
          border: Border.all(
            color: isActive ? RobinTheme.accent : RobinTheme.border,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
            child: Text(
          '$n',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : RobinTheme.textSecondary,
          ),
        )),
      );
}
