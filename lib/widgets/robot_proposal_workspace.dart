import 'package:flutter/material.dart';
import '../services/product_identity_service.dart';
import '../services/robot_proposal_service.dart';
import '../theme/robin_theme.dart';
import 'robot_material_simulator.dart';
import 'smart_order_specification_panel.dart';
import 'robin_dialog.dart';
import 'user_profile.dart';

class RobotProposalWorkspace extends StatefulWidget {
  final ProductIdentityKey recordKey;
  final String project;
  final String customer;
  const RobotProposalWorkspace(
      {super.key,
      required this.recordKey,
      required this.project,
      required this.customer});
  @override
  State<RobotProposalWorkspace> createState() => _RobotProposalWorkspaceState();
}

class _RobotProposalWorkspaceState extends State<RobotProposalWorkspace> {
  late final RobotProposalDraft draft;
  int activeRequest = 0;
  int activePart = 0;
  final majorDraft = <String, String>{};
  final middleDraft = <String, String>{};
  final memo = TextEditingController();
  RobotProposalRequest get request => draft.requests[activeRequest];
  RobotProposalPart get part => request.parts[activePart];
  @override
  void initState() {
    super.initState();
    draft = robotProposalFor(widget.recordKey);
  }

  @override
  void dispose() {
    memo.dispose();
    super.dispose();
  }

  RobotProposalPart newPart(String kind, {String? name}) {
    final id = newRobotProposalId();
    return RobotProposalPart(
        id: id,
        specificationKey: (widget.recordKey.$1, '${widget.recordKey.$2}/$id'),
        kind: kind,
        name: name ?? kind);
  }

  @override
  Widget build(BuildContext context) {
    final known = draft.requests
        .where((r) => r.total != null)
        .fold<int>(0, (sum, r) => sum + r.total!);
    final missing = draft.requests.where((r) => r.total == null).length;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: RobinTheme.border),
          borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Proposal · 사양검토(컨셉설계) 의뢰', style: RobinTheme.headingSm),
        const SizedBox(height: 6),
        Text('${widget.customer} · ${widget.project}',
            style: RobinTheme.bodySm),
        const SizedBox(height: 10),
        Wrap(spacing: 12, runSpacing: 5, children: [
          Text('의뢰 ${draft.requests.length}건', style: RobinTheme.headingSm),
          Text(
              '예상 재료비 ${missing == 0 ? robotMoney(known) : '합계 미완료 · 계산된 금액 ${robotMoney(known)}'}',
              style: RobinTheme.headingSm),
          if (missing > 0)
            Text('계산 기준 미선택 의뢰 $missing건', style: RobinTheme.labelXs),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (var i = 0; i < draft.requests.length; i++)
            ChoiceChip(
                key: ValueKey('robot-request-${draft.requests[i].id}'),
                label: Text('의뢰 ${i + 1} · ${draft.requests[i].name}'),
                selected: activeRequest == i,
                onSelected: (_) => setState(() {
                      activeRequest = i;
                      activePart = 0;
                      memo.clear();
                    })),
          ActionChip(
              key: const ValueKey('robot-request-add'),
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('신규 의뢰'),
              onPressed: () => setState(() {
                    draft.requests.add(RobotProposalRequest(
                        id: newRobotProposalId(),
                        parts: [newPart('로봇', name: 'X축 로봇')]));
                    activeRequest = draft.requests.length - 1;
                    activePart = 0;
                    memo.clear();
                  })),
        ]),
        const SizedBox(height: 10),
        TextFormField(
            key: ValueKey('robot-request-name-${request.id}'),
            initialValue: request.name,
            decoration: const InputDecoration(
                labelText: '의뢰명', border: OutlineInputBorder(), isDense: true),
            onChanged: (v) => setState(() => request.name = v)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, children: [
          OutlinedButton(
              onPressed: copyRequest, child: const Text('사양 복제해 새 의뢰')),
          TextButton(
              onPressed:
                  draft.requests.length <= 1 || request.revisions.isNotEmpty
                      ? null
                      : deleteRequest,
              child: const Text('미저장 의뢰 삭제')),
        ]),
        const Divider(height: 20),
        Text('1. 구성 형태', style: RobinTheme.headingSm),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 4, children: [
          for (final axes in [
            <String>['X'],
            ['X', 'Y'],
            ['X', 'Y', 'Z']
          ])
            OutlinedButton(
                onPressed: () => setAxes(axes),
                child: Text(axes.length == 1 ? '단축' : '${axes.length}축 조합')),
          for (final kind in ['로봇', '브라켓', '토션바', '기타'])
            TextButton(
                onPressed: () => setState(() {
                      request.parts.add(newPart(kind));
                      activePart = request.parts.length - 1;
                    }),
                child: Text('+ ${kind == '로봇' ? '축(로봇)' : kind}')),
        ]),
        const SizedBox(height: 8),
        Text('2. 구성품', style: RobinTheme.headingSm),
        const SizedBox(height: 6),
        SizedBox(
            height: (request.parts.length * 68).clamp(68, 190).toDouble(),
            child: ListView(children: [
              for (var i = 0; i < request.parts.length; i++) componentRow(i),
            ])),
        const SizedBox(height: 10),
        Text('3. ${part.name} · 분류 및 사양', style: RobinTheme.headingSm),
        const SizedBox(height: 8),
        classificationEditor(),
        const SizedBox(height: 8),
        TextFormField(
            key: ValueKey('robot-component-name-${part.id}'),
            initialValue: part.name,
            decoration: const InputDecoration(
                labelText: '구성품명', border: OutlineInputBorder(), isDense: true),
            onChanged: (v) => setState(() => part.name = v)),
        const SizedBox(height: 8),
        if (part.kind == '로봇')
          SmartOrderSpecificationPanel(
            key: ValueKey('robot-smartorder-${part.id}'),
            recordKey: part.specificationKey,
            onApplied: (_) => setState(() {}),
          ),
        TextFormField(
            key: ValueKey('robot-component-note-${part.id}'),
            initialValue: part.note,
            maxLines: 2,
            onChanged: (v) => setState(() => part.note = v),
            decoration: const InputDecoration(
                labelText: '구성품 요청사항·특기사항',
                border: OutlineInputBorder(),
                isDense: true)),
        const SizedBox(height: 10),
        RobotMaterialSimulator(
            key: ValueKey('robot-simulator-${part.id}'),
            part: part,
            onChanged: () => setState(() {})),
        const SizedBox(height: 10),
        revisionPanel(),
      ]),
    );
  }

  Widget componentRow(int i) {
    final item = request.parts[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
          color: i == activePart
              ? RobinTheme.primary.withValues(alpha: .06)
              : RobinTheme.background,
          border: Border.all(color: RobinTheme.border),
          borderRadius: BorderRadius.circular(6)),
      child: ListTile(
        key: ValueKey('robot-component-${item.id}'),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text('${i + 1}. ${item.name} · ${item.kind}',
            style: RobinTheme.bodySm),
        subtitle: Text(item.classification?.path ?? '대·중·소분류 선택 필요',
            style: RobinTheme.labelXs),
        onTap: () => setState(() => activePart = i),
        trailing: SizedBox(
            width: 190,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints.tightFor(width: 32, height: 32),
                  icon: const Icon(Icons.remove, size: 15),
                  onPressed: item.quantity <= 1
                      ? null
                      : () => setState(() => item.quantity--)),
              Text('${item.quantity}개', style: RobinTheme.labelXs),
              IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints.tightFor(width: 32, height: 32),
                  icon: const Icon(Icons.add, size: 15),
                  onPressed: () => setState(() => item.quantity++)),
              IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints.tightFor(width: 32, height: 32),
                  icon: const Icon(Icons.close, size: 15),
                  tooltip: '구성품 삭제',
                  onPressed:
                      request.parts.length <= 1 ? null : () => deletePart(i)),
            ])),
      ),
    );
  }

  Widget classificationEditor() {
    final classification = part.classification;
    final major = majorDraft[part.id] ?? classification?.major;
    final middle = middleDraft[part.id] ??
        (classification == null
            ? null
            : '${classification.middle}|${classification.middleName}');
    final majors = {
      for (final c in robotItemClassifications) c.major: c.majorName
    };
    final middles = {
      for (final c in robotItemClassifications.where((c) => c.major == major))
        '${c.middle}|${c.middleName}': '${c.middle} · ${c.middleName}'
    };
    final minors = robotItemClassifications
        .where(
            (c) => c.major == major && '${c.middle}|${c.middleName}' == middle)
        .toList();
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth < 580 ? c.maxWidth : (c.maxWidth - 16) / 3;
      return Wrap(spacing: 8, runSpacing: 8, children: [
        SizedBox(
            width: width,
            child: DropdownButtonFormField<String>(
              key: ValueKey('robot-class-major-${part.id}'),
              initialValue: major,
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: '품목대분류',
                  border: OutlineInputBorder(),
                  isDense: true),
              items: [
                for (final e in majors.entries)
                  DropdownMenuItem(
                      value: e.key, child: Text('${e.key} · ${e.value}'))
              ],
              onChanged: (v) => setState(() {
                majorDraft[part.id] = v!;
                middleDraft.remove(part.id);
                part.classificationRow = null;
              }),
            )),
        SizedBox(
            width: width,
            child: DropdownMenu<String>(
              key: ValueKey('robot-class-middle-${part.id}-$major-$middle'),
              width: width,
              initialSelection: middle,
              enabled: major != null,
              enableFilter: true,
              requestFocusOnTap: true,
              menuHeight: 260,
              label: const Text('품목중분류 · 검색'),
              inputDecorationTheme: const InputDecorationTheme(
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  constraints: BoxConstraints(minHeight: 36, maxHeight: 40)),
              dropdownMenuEntries: [
                for (final e in middles.entries)
                  DropdownMenuEntry(value: e.key, label: e.value)
              ],
              onSelected: (v) => setState(() {
                if (v != null) middleDraft[part.id] = v;
                part.classificationRow = null;
              }),
            )),
        SizedBox(
            width: width,
            child: DropdownButtonFormField<int>(
              key: ValueKey('robot-class-minor-${part.id}-$middle'),
              initialValue: classification?.row,
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: '품목소분류',
                  border: OutlineInputBorder(),
                  isDense: true),
              items: [
                for (final item in minors)
                  DropdownMenuItem(
                      value: item.row,
                      child: Text('${item.minor} · ${item.minorName}'))
              ],
              onChanged: middle == null
                  ? null
                  : (v) => setState(() => part.classificationRow = v),
            )),
      ]);
    });
  }

  Widget revisionPanel() => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: RobinTheme.background,
            border: Border.all(color: RobinTheme.border),
            borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('4. 재료비 내역 · 사양검토 이력', style: RobinTheme.headingSm),
          const SizedBox(height: 6),
          for (final item in request.parts)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Expanded(
                      child: Text('${item.name} × ${item.quantity}',
                          style: RobinTheme.bodySm)),
                  Text(
                      item.cost == null
                          ? '계산 기준 미선택'
                          : robotMoney(item.cost!.total * item.quantity),
                      style: RobinTheme.bodySm)
                ])),
          const Divider(),
          Text(
              '의뢰 합계 ${request.total == null ? '미완료' : robotMoney(request.total!)} · ${request.dirty ? '변경사항 미저장' : '최신 Rev 저장됨'}',
              style: RobinTheme.headingSm),
          const SizedBox(height: 8),
          TextField(
              key: const ValueKey('robot-proposal-revision-memo'),
              controller: memo,
              decoration: const InputDecoration(
                  labelText: '검토 메모',
                  hintText: '고객 요청 변경사항을 입력하세요.',
                  border: OutlineInputBorder(),
                  isDense: true)),
          const SizedBox(height: 6),
          FilledButton(
              key: const ValueKey('robot-proposal-save-revision'),
              onPressed: saveRevision,
              child: const Text('Rev 저장')),
          Text(
              '저장한 구성품·사양은 아래 설계 검토 의뢰서에서 불러와 요청합니다. 도면 업로드·답변·첨부 이력은 기존 설계 검토 기능을 사용합니다.',
              style: RobinTheme.labelXs),
          if (request.revisions.isEmpty)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('저장된 Rev가 없습니다.')),
          for (final rev in request.revisions.reversed)
            ExpansionTile(
                title: Text(
                    '${rev.label} · ${rev.cost == null ? '금액 미산출' : robotMoney(rev.cost!)}',
                    style: RobinTheme.headingSm),
                subtitle: Text(
                    '${rev.at.toString().substring(0, 16)} · ${rev.author} · ${rev.memo}',
                    style: RobinTheme.labelXs),
                children: [
                  for (final change in rev.changes)
                    ListTile(
                        dense: true,
                        title: Text(change, style: RobinTheme.bodySm)),
                  for (final snapshot in rev.parts.values)
                    ExpansionTile(
                        title:
                            Text(snapshot['구성품명']!, style: RobinTheme.bodySm),
                        children: [
                          for (final field in snapshot.entries)
                            if (field.value.isNotEmpty)
                              ListTile(
                                  dense: true,
                                  title: Text('${field.key}: ${field.value}',
                                      style: RobinTheme.bodySm))
                        ]),
                ]),
        ]),
      );

  void saveRevision() {
    if (request.name.trim().isEmpty) {
      message('의뢰명을 입력해주세요.');
      return;
    }
    try {
      final rev = saveRobotProposalRevision(request,
          author: robinUserProfile.value.name, memo: memo.text.trim());
      setState(() => memo.clear());
      message('${rev.label} 사양과 재료비를 저장했습니다.');
    } on StateError catch (e) {
      message(e.message);
    }
  }

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<bool> confirm(String title, String text) async =>
      await showDialog<bool>(
          context: context,
          builder: (context) => RobinAlertDialog(
                  title: Text(title),
                  content: Text(text),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('변경')),
                  ])) ??
      false;
  Future<void> deletePart(int index) async {
    final item = request.parts[index];
    if (!await confirm(
            '구성품 삭제', '${item.name}을 현재 구성에서 삭제할까요? 저장한 Rev는 유지됩니다.') ||
        !mounted) {
      return;
    }
    setState(() {
      request.parts.removeAt(index);
      activePart = 0;
    });
  }

  Future<void> deleteRequest() async {
    if (!await confirm('미저장 의뢰 삭제', '${request.name}을 삭제할까요?') || !mounted) {
      return;
    }
    setState(() {
      draft.requests.removeAt(activeRequest);
      activeRequest = 0;
      activePart = 0;
    });
  }

  Future<void> setAxes(List<String> axes) async {
    final remove = request.parts
        .where((p) =>
            p.kind == '로봇' && !axes.any((axis) => p.name.startsWith('$axis축')))
        .toList();
    if (remove.isNotEmpty &&
        (!await confirm('축 구성 변경',
                '${remove.map((p) => p.name).join(', ')}을 현재 구성에서 제외할까요? 저장한 Rev는 유지됩니다.') ||
            !mounted)) {
      return;
    }
    setState(() {
      request.parts.removeWhere(remove.contains);
      for (final axis in axes) {
        if (!request.parts
            .any((p) => p.kind == '로봇' && p.name.startsWith('$axis축'))) {
          request.parts.add(newPart('로봇', name: '$axis축 로봇'));
        }
      }
      activePart = 0;
    });
  }

  void copyRequest() {
    final copied = <RobotProposalPart>[];
    for (final source in request.parts) {
      final copy = newPart(source.kind, name: source.name);
      copy.quantity = source.quantity;
      copy.classificationRow = source.classificationRow;
      copy.note = source.note;
      copy.costInputs.addAll(source.costInputs);
      copy.costOptions.addAll(source.costOptions);
      final spec = proposalSpecifications.value[source.specificationKey];
      if (spec != null) {
        proposalSpecifications.value = {
          ...proposalSpecifications.value,
          copy.specificationKey: spec
        };
      }
      copied.add(copy);
    }
    setState(() {
      draft.requests.add(RobotProposalRequest(
          id: newRobotProposalId(),
          name: '${request.name} (복제)',
          parts: copied));
      activeRequest = draft.requests.length - 1;
      activePart = 0;
      memo.clear();
    });
  }
}

String robotProposalReviewSummary(ProductIdentityKey key) {
  final draft = robotProposalDrafts[key];
  if (draft == null) return '';
  return draft.requests.where((r) => r.revisions.isNotEmpty).map((r) {
    final rev = r.revisions.last;
    return '${rev.requestName} · ${rev.label}${r.dirty ? ' (현재 수정 중 · 저장본 기준)' : ''}\n'
        '${rev.parts.values.map((p) => p.entries.where((e) => e.value.isNotEmpty).map((e) => '${e.key}: ${e.value}').join('\n')).join('\n\n')}\n'
        '예상 재료비(DEMO): ${rev.cost == null ? '미산출' : robotMoney(rev.cost!)}';
  }).join('\n\n');
}
