import 'package:flutter/material.dart';

import '../models/access_control.dart';
import '../services/business_division_scope.dart';
import '../theme/robin_theme.dart';
import 'robin_dialog.dart';
import 'user_profile.dart';

/// Shares the division preference across the three business screens, while
/// recalculating access when the signed-in account or its team changes.
class BusinessDivisionWorkspace extends StatelessWidget {
  final Widget Function(BuildContext, BusinessDivisionScope) builder;
  const BusinessDivisionWorkspace({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge([
          selectedBusinessDivision,
          robinUserProfile,
          robinTeams,
        ]),
        builder: (context, _) =>
            builder(context, BusinessDivisionScope.current()),
      );
}

class BusinessDivisionBar extends StatelessWidget {
  final BusinessDivisionScope scope;
  const BusinessDivisionBar({super.key, required this.scope});

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('business-division-bar'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: RobinTheme.surface,
          border: Border.all(color: RobinTheme.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('업무 사업부'),
            if (scope.allowed.length > 1)
              DropdownButton<RobinBusinessDivision?>(
                key: const ValueKey('business-division-selector'),
                value: scope.selected,
                isDense: true,
                underline: const SizedBox.shrink(),
                items: [
                  const DropdownMenuItem(value: null, child: Text('전체 사업부')),
                  for (final division in scope.allowed)
                    DropdownMenuItem(
                        value: division, child: Text(division.label)),
                ],
                onChanged: (value) => selectedBusinessDivision.value = value,
              )
            else
              Text(scope.label, key: const ValueKey('business-division-label')),
            Text(
              scope.allowed.isEmpty
                  ? '팀 관리에서 사업부 배정을 확인해주세요.'
                  : scope.selected == null
                      ? '허용된 사업부 통합 조회 · 등록 시 사업부를 선택합니다.'
                      : '${scope.selected!.label} 데이터 조회 · 임시 데이터',
              style: RobinTheme.labelXs,
            ),
          ],
        ),
      );
}

Future<RobinBusinessDivision?> chooseRegistrationDivision(
    BuildContext context, BusinessDivisionScope scope) async {
  if (scope.allowed.isEmpty) return null;
  if (scope.selected != null) return scope.selected;
  return showDialog<RobinBusinessDivision>(
    context: context,
    builder: (context) => RobinAlertDialog(
      title: const Text('등록 사업부 선택'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('전체 조회에서는 등록할 사업부를 먼저 선택해주세요.'),
          const SizedBox(height: 12),
          for (final division in scope.allowed)
            ListTile(
              title: Text(division.label),
              onTap: () => Navigator.pop(context, division),
            ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('취소'))
      ],
    ),
  );
}
