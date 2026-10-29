import 'package:flutter/material.dart';

import '../models/access_control.dart';
import '../services/business_division_scope.dart';
import '../services/design_work_service.dart';
import '../services/platform_review_service.dart';
import '../services/robot_design_review_service.dart';
import '../widgets/business_division_workspace.dart';
import '../widgets/platform_review_workspace.dart';
import '../widgets/robot_design_review_panel.dart';
import '../widgets/robin_dialog.dart';

class DesignWorkManagementScreen extends StatefulWidget {
  final List<DesignOrderSource> orders;
  final String? initialReviewNumber;
  const DesignWorkManagementScreen(
      {super.key, this.orders = const [], this.initialReviewNumber});
  @override
  State<DesignWorkManagementScreen> createState() =>
      _DesignWorkManagementScreenState();
}

class _DesignWorkManagementScreenState
    extends State<DesignWorkManagementScreen> {
  DesignWorkKind? kind;
  DesignWorkStatus? status;
  String person = '';
  String query = '';
  String start = '';
  String end = '';
  bool urgentOnly = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialReviewNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final item = collectDesignWork()
            .where((r) =>
                r.kind == DesignWorkKind.review &&
                r.number == widget.initialReviewNumber)
            .firstOrNull;
        if (mounted && item != null) source(item);
      });
    }
  }

  Future<void> source(DesignWorkItem item) async {
    if (item.kind == DesignWorkKind.order) {
      Navigator.pop(context, (item.division, item.number));
      return;
    }
    if (item.robotKey != null || item.platformId != null) {
      final robot =
          item.robotKey == null ? null : robotReviewFor(item.robotKey!);
      await showDialog<void>(
          context: context,
          builder: (context) => Dialog(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: SizedBox(
                      height: MediaQuery.sizeOf(context).height * .85,
                      child: Column(children: [
                        ListTile(
                            title: Text('${item.number} · 원본 검토 요청서'),
                            trailing: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close))),
                        const Divider(height: 1),
                        Expanded(
                            child: SingleChildScrollView(
                                padding: const EdgeInsets.all(12),
                                child: item.robotKey != null
                                    ? RobotDesignReviewPanel(
                                        recordKey: item.robotKey!,
                                        projectName: robot!.projectName,
                                        customer: robot.customer,
                                        owner:
                                            robot.content.fields['requester'] ??
                                                '')
                                    : PlatformReviewWorkspace(
                                        initiallyExpanded: true,
                                        initialSelectedId: item.platformId))),
                      ])))));
      return;
    }
    final task =
        otherDesignTasks.value.where((r) => r.id == item.otherId).firstOrNull;
    if (task == null) return;
    await showDialog<void>(
        context: context,
        builder: (context) => RobinAlertDialog(
                title: Text(task.title),
                content: SizedBox(
                    width: 540,
                    child: SingleChildScrollView(
                        child: Text(
                            '유형: ${task.type}\n원본 접수번호: ${task.reference.isEmpty ? '없음' : task.reference}\n'
                            '관련 수주: ${task.orderReference.isEmpty ? '없음' : task.orderReference}\n'
                            '등록자: ${task.author}\n등록일: ${task.at.toLocal()}\n내용: ${task.notes}\n\n'
                            '수동 참조 등록입니다. 원본 시스템 조회·진위 확인은 아직 연동하지 않았습니다.'))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기'))
                ]));
  }

  void history(DesignWorkItem item) => showDialog<void>(
      context: context,
      builder: (context) => RobinAlertDialog(
              title: Text('${item.number} · 업무 관리 이력'),
              content: SizedBox(
                  width: 620,
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('검토 요청·회신의 상세 이력은 원본 요청서에서 확인합니다.'),
                        for (final change
                            in (designWorkChanges.value[item.id] ??
                                    <DesignWorkChange>[])
                                .reversed)
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                  '${change.author} · ${change.at.toLocal()}\n${change.differences.join('\n')}\n사유: ${change.reason}')),
                        if (designWorkChanges.value[item.id]?.isNotEmpty !=
                            true)
                          const Text('업무 관리 변경 이력이 없습니다.'),
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'))
              ]));

  Widget filter<T>(String label, T value, List<DropdownMenuItem<T>> items,
          ValueChanged<T?> onChanged) =>
      SizedBox(
          width: 170,
          child: DropdownButtonFormField<T>(
              key: ValueKey('$label:$value'),
              initialValue: value,
              isExpanded: true,
              decoration: InputDecoration(
                  labelText: label,
                  isDense: true,
                  border: const OutlineInputBorder()),
              items: items,
              onChanged: onChanged));

  Widget dateField(String label, ValueChanged<String> change) => SizedBox(
      width: 180,
      child: TextField(
          key: ValueKey(label),
          decoration: InputDecoration(
              labelText: label,
              hintText: 'YYYY-MM-DD',
              isDense: true,
              border: const OutlineInputBorder()),
          onChanged: (value) => setState(() => change(value.trim()))));

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('설계 업무관리')),
      body: BusinessDivisionWorkspace(
          builder: (context, scope) => ListenableBuilder(
              listenable: Listenable.merge([
                robotDesignReviews,
                platformReviews,
                otherDesignTasks,
                designWorkChanges
              ]),
              builder: (context, _) {
                if (!canReadDesignWork) {
                  return const Center(
                      child: Text('설계 업무 조회 권한 또는 사업부 배정을 확인해주세요.'));
                }
                final all =
                    collectDesignWork(orders: widget.orders, scope: scope);
                final people = all
                    .map((r) =>
                        r.displayAssignee.isEmpty ? '미배정' : r.displayAssignee)
                    .toSet()
                    .toList()
                  ..sort();
                final selectedPerson = people.contains(person) ? person : '';
                final invalidDates =
                    (start.isNotEmpty && !validPlatformDate(start)) ||
                        (end.isNotEmpty && !validPlatformDate(end)) ||
                        (start.isNotEmpty &&
                            end.isNotEmpty &&
                            start.compareTo(end) > 0);
                final rows = all.where((r) {
                  final owner =
                      r.displayAssignee.isEmpty ? '미배정' : r.displayAssignee;
                  return (kind == null || r.kind == kind) &&
                      (status == null || r.displayStatus == status) &&
                      (selectedPerson.isEmpty || owner == selectedPerson) &&
                      (!urgentOnly || r.displayUrgent) &&
                      '$owner ${r.number} ${r.title} ${r.sourceStatus}'
                          .toLowerCase()
                          .contains(query.toLowerCase()) &&
                      !invalidDates &&
                      ((start.isEmpty && end.isEmpty) ||
                          (validPlatformDate(r.displayDue) &&
                              (start.isEmpty ||
                                  r.displayDue.compareTo(start) >= 0) &&
                              (end.isEmpty ||
                                  r.displayDue.compareTo(end) <= 0)));
                }).toList();
                return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BusinessDivisionBar(scope: scope),
                          const Text('전체/담당자별 설계 현황 · 프론트 시안',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                              '검토 요청서는 원본 상태를 표시합니다. 수주·기타의 상태/담당자/기한은 ROBIN 임시 관리값입니다.\n'
                              '업무 기한 기준으로 기간 조회합니다(시안). 기간 지정 시 기한 미입력 건은 제외합니다. 앱 재시작 시 관리값은 초기화됩니다.'),
                          const SizedBox(height: 12),
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            ChoiceChip(
                                label: const Text('전체'),
                                selected: kind == null,
                                onSelected: (_) => setState(() => kind = null)),
                            for (final k in DesignWorkKind.values)
                              ChoiceChip(
                                  label: Text(k.label),
                                  selected: kind == k,
                                  onSelected: (_) => setState(() => kind = k)),
                            if (canManageDesignWork)
                              OutlinedButton.icon(
                                  key: const ValueKey('design-add-other'),
                                  onPressed: () => showDialog<void>(
                                      context: context,
                                      builder: (_) =>
                                          _OtherTaskDialog(scope: scope)),
                                  icon: const Icon(Icons.add),
                                  label: const Text('기타 업무 등록')),
                          ]),
                          const SizedBox(height: 12),
                          Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                filter<String>(
                                    '담당자',
                                    selectedPerson,
                                    [
                                      const DropdownMenuItem(
                                          value: '', child: Text('전체 담당자')),
                                      for (final p in people)
                                        DropdownMenuItem(
                                            value: p, child: Text(p))
                                    ],
                                    (v) => setState(() => person = v ?? '')),
                                filter<String>(
                                    '상태',
                                    status?.name ?? '',
                                    [
                                      const DropdownMenuItem(
                                          value: '', child: Text('전체 상태')),
                                      for (final s in DesignWorkStatus.values)
                                        DropdownMenuItem(
                                            value: s.name, child: Text(s.label))
                                    ],
                                    (v) => setState(() => status =
                                        DesignWorkStatus.values
                                            .where((s) => s.name == v)
                                            .firstOrNull)),
                                dateField('기한 시작', (v) => start = v),
                                dateField('기한 종료', (v) => end = v),
                                FilterChip(
                                    label: const Text('긴급만'),
                                    selected: urgentOnly,
                                    onSelected: (v) =>
                                        setState(() => urgentOnly = v)),
                                SizedBox(
                                    width: 260,
                                    child: TextField(
                                        key: const ValueKey(
                                            'design-work-search'),
                                        decoration: const InputDecoration(
                                            hintText: '번호 / 업무명 / 담당자 검색',
                                            isDense: true,
                                            border: OutlineInputBorder()),
                                        onChanged: (v) =>
                                            setState(() => query = v.trim()))),
                              ]),
                          if (invalidDates)
                            const Text(
                                '기간을 YYYY-MM-DD로 입력하고 시작일 ≤ 종료일로 설정해주세요.',
                                style: TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          Text(
                              '조회 ${rows.length}건 · 진행 ${rows.where((r) => r.displayStatus == DesignWorkStatus.working).length} · '
                              '보류 ${rows.where((r) => r.displayStatus == DesignWorkStatus.held).length} · '
                              '완료 ${rows.where((r) => r.displayStatus == DesignWorkStatus.done).length} · '
                              '미확인 ${rows.where((r) => r.displayStatus == DesignWorkStatus.unknown).length}'),
                          const SizedBox(height: 8),
                          if (rows.isEmpty)
                            const Padding(
                                padding: EdgeInsets.all(24),
                                child: Text('조회 조건에 해당하는 설계 업무가 없습니다.'))
                          else
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                    columnSpacing: 18,
                                    dataRowMinHeight: 56,
                                    dataRowMaxHeight: 80,
                                    columns: [
                                      for (final label in [
                                        '긴급',
                                        '구분',
                                        '번호',
                                        '업무명',
                                        '담당자',
                                        '상태 / 원본',
                                        '업무 기한',
                                        '사업부',
                                        '작업'
                                      ])
                                        DataColumn(label: Text(label))
                                    ],
                                    rows: [
                                      for (final item in rows)
                                        DataRow(key: ValueKey(item.id), cells: [
                                          DataCell(Text(
                                              item.displayUrgent ? '긴급' : '—',
                                              style: TextStyle(
                                                  color: item.displayUrgent
                                                      ? Colors.red
                                                      : null))),
                                          DataCell(Text(item.kind.label)),
                                          DataCell(Text(item.number)),
                                          DataCell(SizedBox(
                                              width: 260,
                                              child: Tooltip(
                                                  message: item.title,
                                                  child: Text(item.title,
                                                      maxLines: 2,
                                                      overflow: TextOverflow
                                                          .ellipsis)))),
                                          DataCell(Text(
                                              item.displayAssignee.isEmpty
                                                  ? '미배정'
                                                  : item.displayAssignee)),
                                          DataCell(Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item.displayStatus.label),
                                                Text(item.sourceStatus,
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey))
                                              ])),
                                          DataCell(Text(item.displayDue.isEmpty
                                              ? '미입력'
                                              : item.displayDue)),
                                          DataCell(Text(item.division.label)),
                                          DataCell(Row(children: [
                                            TextButton(
                                                onPressed: () => source(item),
                                                child: Text(item.kind ==
                                                        DesignWorkKind.order
                                                    ? '프로젝트 설계'
                                                    : '원본')),
                                            if (mayManageDesignItem(item))
                                              TextButton(
                                                  key: ValueKey(
                                                      'manage-${item.id}'),
                                                  onPressed: () =>
                                                      showDialog<void>(
                                                          context: context,
                                                          builder: (_) =>
                                                              _WorkDialog(
                                                                  item: item,
                                                                  orders: widget
                                                                      .orders)),
                                                  child: const Text('업무관리')),
                                            IconButton(
                                                tooltip: '관리 이력',
                                                onPressed: () => history(item),
                                                icon: const Icon(Icons.history,
                                                    size: 18))
                                          ])),
                                        ])
                                    ])),
                        ]));
              })));
}

class _WorkDialog extends StatefulWidget {
  final DesignWorkItem item;
  final List<DesignOrderSource> orders;
  const _WorkDialog({required this.item, required this.orders});
  @override
  State<_WorkDialog> createState() => _WorkDialogState();
}

class _WorkDialogState extends State<_WorkDialog> {
  late final owner = TextEditingController(text: widget.item.displayAssignee);
  late final due = TextEditingController(text: widget.item.displayDue);
  final reason = TextEditingController();
  late final String token;
  late DesignWorkStatus status = widget.item.displayStatus;
  late bool urgent = widget.item.displayUrgent;
  String error = '';
  @override
  void initState() {
    super.initState();
    token = widget.item.token;
  }

  @override
  void dispose() {
    owner.dispose();
    due.dispose();
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.item.kind == DesignWorkKind.review;
    return RobinAlertDialog(
        title: Text('${widget.item.number} · 업무관리'),
        content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(review
                  ? '검토 상태·담당자·기한은 원본 요청서에서 변경합니다.'
                  : 'ROBIN 시안의 임시 관리값입니다. ERP 상태를 변경하지 않습니다.'),
              DropdownButtonFormField<DesignWorkStatus>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: '상태'),
                  items: [
                    for (final s in DesignWorkStatus.values)
                      DropdownMenuItem(value: s, child: Text(s.label))
                  ],
                  onChanged:
                      review ? null : (v) => setState(() => status = v!)),
              TextField(
                  key: const ValueKey('design-owner'),
                  controller: owner,
                  enabled: !review,
                  decoration: const InputDecoration(labelText: '담당자')),
              TextField(
                  key: const ValueKey('design-due'),
                  controller: due,
                  enabled: !review,
                  decoration:
                      const InputDecoration(labelText: '업무 기한 YYYY-MM-DD')),
              CheckboxListTile(
                  title: const Text('긴급 업무'),
                  value: urgent,
                  onChanged: (v) => setState(() => urgent = v!)),
              TextField(
                  key: const ValueKey('design-reason'),
                  controller: reason,
                  decoration: const InputDecoration(labelText: '변경 사유 *')),
              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),
            ]))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
              key: const ValueKey('design-save'),
              onPressed: () {
                try {
                  updateDesignWork(
                      id: widget.item.id,
                      expectedToken: token,
                      orders: widget.orders,
                      status: status,
                      assignee: owner.text,
                      due: due.text,
                      urgent: urgent,
                      reason: reason.text);
                  Navigator.pop(context);
                } catch (e) {
                  setState(() =>
                      error = e.toString().replaceFirst('Bad state: ', ''));
                }
              },
              child: const Text('저장'))
        ]);
  }
}

class _OtherTaskDialog extends StatefulWidget {
  final BusinessDivisionScope scope;
  const _OtherTaskDialog({required this.scope});
  @override
  State<_OtherTaskDialog> createState() => _OtherTaskDialogState();
}

class _OtherTaskDialogState extends State<_OtherTaskDialog> {
  final fields = {
    for (final id in [
      'reference',
      'title',
      'assignee',
      'due',
      'order',
      'notes'
    ])
      id: TextEditingController()
  };
  late RobinBusinessDivision division =
      widget.scope.selected ?? widget.scope.allowed.first;
  String type = '서비스요청';
  String error = '';
  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
          title: const Text('기타 설계 업무 등록'),
          content: SizedBox(
              width: 540,
              child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text(
                    '서비스·불량 원본 접수번호를 참조하는 수동 등록입니다. 원본 시스템은 아직 연동되지 않습니다.'),
                DropdownButtonFormField<RobinBusinessDivision>(
                    initialValue: division,
                    decoration: const InputDecoration(labelText: '사업부'),
                    items: [
                      for (final d
                          in widget.scope.allowed.where(widget.scope.includes))
                        DropdownMenuItem(value: d, child: Text(d.label))
                    ],
                    onChanged: (v) => setState(() => division = v!)),
                DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: '업무 유형'),
                    items: [
                      for (final t in ['서비스요청', '불량', '기타'])
                        DropdownMenuItem(value: t, child: Text(t))
                    ],
                    onChanged: (v) => setState(() => type = v!)),
                for (final e in {
                  'reference': '원본 접수번호 (서비스/불량 필수)',
                  'title': '업무명 *',
                  'assignee': '담당자 *',
                  'due': '업무 기한 YYYY-MM-DD',
                  'order': '관련 수주번호 (선택)',
                  'notes': '요청 내용'
                }.entries)
                  TextField(
                      key: ValueKey('other-${e.key}'),
                      controller: fields[e.key],
                      decoration: InputDecoration(labelText: e.value)),
                if (error.isNotEmpty)
                  Text(error, style: const TextStyle(color: Colors.red)),
              ]))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소')),
            FilledButton(
                key: const ValueKey('other-create'),
                onPressed: () {
                  try {
                    createOtherDesignTask(
                        division: division,
                        type: type,
                        reference: fields['reference']!.text,
                        title: fields['title']!.text,
                        assignee: fields['assignee']!.text,
                        due: fields['due']!.text,
                        orderReference: fields['order']!.text,
                        notes: fields['notes']!.text);
                    Navigator.pop(context);
                  } catch (e) {
                    setState(() =>
                        error = e.toString().replaceFirst('Bad state: ', ''));
                  }
                },
                child: const Text('등록'))
          ]);
}
