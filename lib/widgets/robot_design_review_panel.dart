import 'package:flutter/material.dart';

import '../models/access_control.dart';
import '../services/desktop_file_service.dart';
import '../services/product_identity_service.dart';
import '../services/robot_design_review_catalog.dart';
import '../services/robot_design_review_service.dart';
import '../theme/robin_theme.dart';
import 'robin_dialog.dart';
import 'user_profile.dart';

class RobotDesignReviewPanel extends StatefulWidget {
  final ProductIdentityKey recordKey;
  final String projectName;
  final String customer;
  final String owner;
  final List<ReviewDrawing> drawings;
  final String Function()? proposalSummary;
  const RobotDesignReviewPanel(
      {super.key,
      required this.recordKey,
      required this.projectName,
      required this.customer,
      required this.owner,
      this.proposalSummary,
      this.drawings = const []});
  @override
  State<RobotDesignReviewPanel> createState() => _RobotDesignReviewPanelState();
}

class _RobotDesignReviewPanelState extends State<RobotDesignReviewPanel> {
  final fields = <String, TextEditingController>{};
  final reason = TextEditingController();
  final drawingNumber = TextEditingController();
  Set<int> selectedOptions = {};
  List<ReviewAttachment> attachments = [];
  final List<ReviewDrawing> replyDrawings = [];
  ReviewDrawing? drawing;
  RobotReviewRole role = RobotReviewRole.sales;
  int baseVersion = 0;
  int formEpoch = 0;
  bool dirty = false;
  bool picking = false;
  List<String> errors = [];

  bool get admin => robinUserProfile.value.isAdmin;
  bool get sales =>
      admin ||
      robinUserProfile.value.departmentPermission ==
          RobinDepartmentPermission.sales;
  bool get designer =>
      admin ||
      robinUserProfile.value.departmentPermission ==
          RobinDepartmentPermission.engineering;
  bool get canEdit =>
      role == RobotReviewRole.sales &&
      sales &&
      !robinUserProfile.value.isDealer;
  bool get canReply =>
      role == RobotReviewRole.design &&
      designer &&
      !robinUserProfile.value.isDealer;
  RobotDesignReview get saved => robotReviewFor(widget.recordKey);
  Map<String, String> get values =>
      {for (final e in fields.entries) e.key: e.value.text.trim()};
  RobotReviewContent get content => RobotReviewContent(
      fields: values,
      options: selectedOptions,
      attachments: attachments,
      drawing: drawing == null
          ? null
          : ReviewDrawing(
              id: drawing!.id,
              fileName: drawing!.fileName,
              number: drawingNumber.text.trim(),
              revision: drawing!.revision,
              demo: drawing!.demo,
              file: drawing!.file));

  @override
  void initState() {
    super.initState();
    for (final id in robotReviewFieldLabels.keys) {
      fields[id] = TextEditingController();
    }
    if (!admin && designer) role = RobotReviewRole.design;
    load();
    robotDesignReviews.addListener(refresh);
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  void load() {
    final record = saved;
    for (final e in fields.entries) {
      e.value.text = record.content.fields[e.key] ?? '';
    }
    if (record.version == 0) {
      fields['requester']!.text = widget.owner;
      fields['maker']!.text = '미지정';
      final spec = proposalSpecifications.value[widget.recordKey];
      if (spec != null) {
        fields['model']!.text = spec.model;
        fields['stroke']!.text = spec.stroke;
        fields['motor']!.text = spec.motorDirection;
        fields['sensor']!.text = spec.sensorDirection;
      }
    }
    selectedOptions = {...record.content.options};
    attachments = [...record.content.attachments];
    drawing = record.content.drawing;
    drawingNumber.text =
        drawing?.number ?? identityFor(widget.recordKey).drawingNumber;
    baseVersion = record.version;
    dirty = false;
    formEpoch++;
    errors = [];
    reason.clear();
  }

  @override
  void dispose() {
    robotDesignReviews.removeListener(refresh);
    for (final controller in fields.values) {
      controller.dispose();
    }
    reason.dispose();
    drawingNumber.dispose();
    super.dispose();
  }

  void changed() => setState(() {
        dirty = true;
        errors = [];
      });
  void run(RobotReviewAction action) {
    try {
      applyRobotReview(
          key: widget.recordKey,
          expectedVersion: baseVersion,
          action: action,
          role: role,
          author:
              '${robinUserProfile.value.name} ${robinUserProfile.value.rank}',
          projectName: widget.projectName,
          customer: widget.customer,
          content: content,
          reason: reason.text);
      setState(load);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('검토 요청서를 현재 앱 세션에 저장했습니다.')));
    } catch (error) {
      setState(() => errors =
          error.toString().replaceFirst('Bad state: ', '').split('\n'));
    }
  }

  Widget input(String id,
          {bool required = false, int lines = 1, double width = 230}) =>
      SizedBox(
          width: width,
          child: TextFormField(
              key: ValueKey('review-$id'),
              controller: fields[id],
              enabled: canEdit,
              maxLines: lines,
              onChanged: (_) => changed(),
              decoration: InputDecoration(
                  labelText:
                      '${robotReviewFieldLabels[id]}${required ? ' *' : ''}',
                  isDense: true,
                  border: const OutlineInputBorder())));
  Widget choice(String id, List<String> items, {bool required = false}) =>
      SizedBox(
          width: 230,
          child: DropdownButtonFormField<String>(
              key: ValueKey('review-$id'),
              isExpanded: true,
              initialValue:
                  items.contains(fields[id]!.text) ? fields[id]!.text : '',
              decoration: InputDecoration(
                  labelText:
                      '${robotReviewFieldLabels[id]}${required ? ' *' : ''}',
                  isDense: true,
                  border: const OutlineInputBorder()),
              items: ['', ...items]
                  .map((s) => DropdownMenuItem(
                      value: s, child: Text(s.isEmpty ? '선택' : s)))
                  .toList(),
              onChanged: !canEdit
                  ? null
                  : (v) {
                      fields[id]!.text = v ?? '';
                      changed();
                    }));

  Future<void> attach() async {
    setState(() => picking = true);
    try {
      final file = await DesktopFileService.pickReferenceDocument();
      if (file == null || !mounted) return;
      final metadata = await showDialog<(String, String)>(
          context: context, builder: (_) => const _ReviewAttachmentMetadata());
      if (metadata == null || !mounted) return;
      setState(() {
        attachments.add(ReviewAttachment(
            id: 'local-${DateTime.now().microsecondsSinceEpoch}',
            file: file,
            selectedAt: DateTime.now(),
            drawingNumber: metadata.$1,
            drawingRevision: metadata.$2));
        dirty = true;
      });
    } catch (error) {
      if (mounted) setState(() => errors = ['첨부 선택 실패: $error']);
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  Future<void> download(ReviewAttachment attachment) async {
    try {
      await DesktopFileService.saveSelectedDocument(attachment.file);
    } catch (error) {
      if (mounted) setState(() => errors = ['첨부 다운로드 실패: $error']);
    }
  }

  Future<void> attachReplyDrawing() async {
    setState(() => picking = true);
    try {
      final file = await DesktopFileService.pickReferenceDocument();
      if (file == null || !mounted) return;
      final metadata = await showDialog<(String, String)>(
          context: context, builder: (_) => const _ReviewAttachmentMetadata());
      if (metadata == null || !mounted) return;
      if (metadata.$1.isEmpty || metadata.$2.isEmpty) {
        throw StateError('결과 도면은 도면번호와 Revision을 모두 입력해주세요.');
      }
      setState(() {
        drawing = ReviewDrawing(
            id: 'result-${DateTime.now().microsecondsSinceEpoch}-${replyDrawings.length}',
            fileName: file.name,
            number: metadata.$1,
            revision: metadata.$2,
            file: file);
        replyDrawings.add(drawing!);
        drawingNumber.text = metadata.$1;
        formEpoch++;
        dirty = true;
      });
    } catch (error) {
      if (mounted) setState(() => errors = ['결과 도면 선택 실패: $error']);
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  void viewEvent(RobotReviewEvent event) => showDialog<void>(
      context: context,
      builder: (_) => RobinAlertDialog(
              title: Text('요청서 Rev.${event.revision} · ${event.to.label}'),
              content: SizedBox(
                  width: 800,
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            '${event.author} · ${event.at.toLocal()}\n사유: ${event.reason.isEmpty ? '없음' : event.reason}'),
                        Text('연결 도면: ${event.snapshot.drawing?.label ?? '없음'}'),
                        if (event.snapshot.drawing?.file != null)
                          TextButton.icon(
                              onPressed: () async {
                                try {
                                  await DesktopFileService.saveSelectedDocument(
                                      event.snapshot.drawing!.file!);
                                } catch (error) {
                                  if (mounted) {
                                    setState(() =>
                                        errors = ['결과 도면 다운로드 실패: $error']);
                                  }
                                }
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('결과 도면 다운로드')),
                        const Divider(),
                        const Text('변경 전후'),
                        for (final change in event.changes) Text(change),
                        const Divider(),
                        const Text('당시 요청서 원본'),
                        for (final e in event.snapshot.values.entries)
                          Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                  '${e.key}: ${e.value.isEmpty ? '미입력' : e.value}')),
                        for (final file in event.snapshot.attachments)
                          TextButton.icon(
                              onPressed: () => download(file),
                              icon: const Icon(Icons.download, size: 16),
                              label: Text(file.file.name)),
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'))
              ]));

  @override
  Widget build(BuildContext context) {
    final record = saved;
    final editableState = [
      RobotReviewStatus.draft,
      RobotReviewStatus.changes,
      RobotReviewStatus.rejected
    ].contains(record.status);
    final active = [RobotReviewStatus.requested, RobotReviewStatus.reviewing]
        .contains(record.status);
    final drawings = <String, ReviewDrawing>{
      for (final d in widget.drawings) d.id: d,
      for (final d in replyDrawings) d.id: d,
      for (final file in attachments)
        if (file.drawing != null) file.id: file.drawing!,
      if (drawing != null) drawing!.id: drawing!,
    };
    return Container(
        key: ValueKey('robot-review-${widget.recordKey.$2}'),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: RobinTheme.border),
            borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('로봇 설계 검토 요청서', style: RobinTheme.headingSm),
                Text(
                    '검토-${widget.recordKey.$2} · Rev.${record.revision} · ${record.status.label}',
                    key: const ValueKey('review-state')),
                if (dirty)
                  const Text('미저장 변경 있음',
                      style: TextStyle(color: RobinTheme.signalRed)),
                if (record.drawingRecheck)
                  const Text('사양 변경 · 도면 재검토 필요',
                      style: TextStyle(color: RobinTheme.signalRed)),
              ]),
          const SizedBox(height: 6),
          Text('${widget.customer} · ${widget.projectName}',
              style: RobinTheme.bodySm),
          const SizedBox(height: 6),
          const Text(
              '프론트 시안 · 상태전이/필수값/역할은 운영 확정 전입니다. 현재 앱 세션에만 저장하며 ERP·서버 파일 공유는 연결하지 않습니다.\n'
              '댓글과 별개인 정식 수정요청 이력입니다. 최초 요청 시 도면은 선택 사항, 완료 시 도면 연결 필수는 시안 기준입니다.',
              style: TextStyle(fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (admin)
                  SizedBox(
                      width: 230,
                      child: DropdownButtonFormField<RobotReviewRole>(
                          key: const ValueKey('review-demo-role'),
                          initialValue: role,
                          decoration: const InputDecoration(
                              labelText: '관리자 시연 역할',
                              isDense: true,
                              border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(
                                value: RobotReviewRole.sales,
                                child: Text('영업 요청 시연')),
                            DropdownMenuItem(
                                value: RobotReviewRole.design,
                                child: Text('설계 회신 시연'))
                          ],
                          onChanged: (r) => setState(() {
                                role = r!;
                                load();
                              }))),
                OutlinedButton(
                    onPressed: () => setState(load),
                    child: const Text('저장본 다시 불러오기')),
                const Text('역할 전환/다시 불러오기는 미저장 입력을 버리고 저장본을 표시합니다.',
                    style: TextStyle(fontSize: 11)),
              ]),
          if (!sales && !designer) const Text('현재 계정은 조회만 가능합니다.'),
          for (final error in errors)
            Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(error,
                    style: const TextStyle(color: RobinTheme.signalRed))),
          const SizedBox(height: 12),
          // No nested scroll viewport: the Proposal page continues scrolling as a whole.
          Column(
              key: ValueKey('review-form-$formEpoch'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 8, runSpacing: 12, children: [
                  input('requester', required: true),
                  input('designer', required: true),
                  input('due', required: true),
                  input('documentNo')
                ]),
                const SizedBox(height: 14),
                Text('구조·모델·사용조건', style: RobinTheme.headingSm),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 12, children: [
                  choice('composition', ['단축', '조합'], required: true),
                  choice(
                      'drive',
                      [
                        'B/Screw',
                        'Belt',
                        'Linear',
                        'Rack&Pinion',
                        'Guide',
                        'Stage',
                        '기타'
                      ],
                      required: true),
                  choice('layout', ['직렬', '병렬', '기타/미확인']),
                  if (values['composition'] == '조합')
                    input('combination', required: true),
                  input('model', required: true),
                  input('stroke'),
                  input('payload'),
                  input('speed'),
                  input('center'),
                  input('cycles'),
                  choice('rails', ['1', '2', '기타/미확인']),
                  input('motor'),
                  input('sensor'),
                ]),
                const SizedBox(height: 8),
                const Text(
                    '*는 요청 제출용 시안 필수값입니다. 사용조건의 단위·필수 여부는 설계팀 확인이 필요합니다.',
                    style: TextStyle(fontSize: 11)),
                TextButton(
                    onPressed: !canEdit
                        ? null
                        : () {
                            final spec =
                                proposalSpecifications.value[widget.recordKey];
                            if (spec == null) {
                              setState(() => errors = ['불러올 컨셉 사양이 없습니다.']);
                              return;
                            }
                            fields['model']!.text = spec.model;
                            fields['stroke']!.text = spec.stroke;
                            fields['motor']!.text = spec.motorDirection;
                            fields['sensor']!.text = spec.sensorDirection;
                            changed();
                          },
                    child: const Text('현재 컨셉 사양 불러오기 (저장 전 확인)')),
                if (widget.proposalSummary != null)
                  TextButton.icon(
                    key: const ValueKey('review-import-proposal-revisions'),
                    onPressed: !canEdit
                        ? null
                        : () {
                            final summary = widget.proposalSummary!();
                            if (summary.isEmpty) {
                              setState(() =>
                                  errors = ['먼저 위 사양검토 의뢰에서 Rev를 저장해주세요.']);
                              return;
                            }
                            final current = fields['request']!.text.trim();
                            if (!current.contains(summary)) {
                              fields['request']!.text = [
                                if (current.isNotEmpty) current,
                                summary
                              ].join('\n\n');
                            }
                            changed();
                          },
                    icon: const Icon(Icons.input, size: 16),
                    label: const Text('구성품·최신 저장 Rev 불러오기'),
                  ),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 12, children: [
                  choice('maker', ['미지정', '지정']),
                  if (values['maker'] == '지정')
                    input('makerName', required: true),
                  input('makerNotes')
                ]),
                const SizedBox(height: 12),
                ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('구조별 설계 특기사항 · 원본 항목'),
                    subtitle: Text(
                        '선택 ${selectedOptions.length}개 · 적용 불가 항목은 사유 표시 · 확인되지 않은 조합은 설계 확인 필요'),
                    children: [
                      for (final group
                          in robotReviewOptions.map((o) => o.group).toSet())
                        ExpansionTile(title: Text(group), children: [
                          for (final option in robotReviewOptions
                              .where((o) => o.group == group))
                            Builder(builder: (_) {
                              final restriction =
                                  reviewOptionRestriction(option, values);
                              final selected =
                                  selectedOptions.contains(option.row);
                              return CheckboxListTile(
                                  key: ValueKey('review-option-${option.row}'),
                                  dense: true,
                                  value: selected,
                                  title: Text(option.label),
                                  subtitle: Text(
                                      '${option.description}\n${option.source}${restriction == null ? '' : '\n$restriction'}'),
                                  onChanged: !canEdit ||
                                          (!selected && restriction != null)
                                      ? null
                                      : (v) {
                                          if (v == true) {
                                            selectedOptions.add(option.row);
                                          } else {
                                            selectedOptions.remove(option.row);
                                          }
                                          changed();
                                        });
                            })
                        ])
                    ]),
                if (selectedOptions.isNotEmpty) ...[
                  const Text('선택 특기사항'),
                  for (final option in robotReviewOptions
                      .where((o) => selectedOptions.contains(o.row)))
                    Text(
                        '${option.label}${reviewOptionRestriction(option, values) == null ? '' : ' · 적용 불가: ${reviewOptionRestriction(option, values)}'}'),
                ],
                ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('영업 특기사항 · 사양정보 영업팀 B3:B16'),
                    children: [
                      Wrap(spacing: 8, runSpacing: 12, children: [
                        for (final id in [
                          'marking',
                          'lmCap',
                          'cable',
                          'cableTreatment',
                          'grease',
                          'plateNut',
                          'reducer',
                          'linearSupply',
                          'sticker',
                          'woodPacking',
                          'combinedShipment',
                          'boxPacking',
                          'salesOther'
                        ])
                          input(id)
                      ]),
                      const SizedBox(height: 8)
                    ]),
                const SizedBox(height: 10),
                LayoutBuilder(
                    builder: (_, c) =>
                        Wrap(spacing: 8, runSpacing: 12, children: [
                          input('extra', lines: 3, width: c.maxWidth),
                          input('request',
                              lines: 3, required: true, width: c.maxWidth)
                        ])),
              ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            Text('첨부·요청서/도면 버전 연결', style: RobinTheme.headingSm),
            OutlinedButton.icon(
                key: const ValueKey('review-attach'),
                onPressed: !canEdit || picking ? null : attach,
                icon: const Icon(Icons.attach_file, size: 16),
                label: Text(picking ? '파일 선택 중…' : '파일 첨부')),
            if (canReply)
              OutlinedButton.icon(
                  key: const ValueKey('review-attach-result'),
                  onPressed: picking ? null : attachReplyDrawing,
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('결과 도면 첨부')),
          ]),
          const Text(
              '첨부는 선택한 로컬 파일 참조입니다. 서버 업로드·다른 PC 공유·DWG/STEP 미리보기는 아직 지원하지 않습니다.',
              style: TextStyle(fontSize: 11)),
          for (final file in attachments)
            ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                    '${file.file.name} · ${file.drawingNumber} ${file.drawingRevision}'),
                subtitle: Text('선택 ${file.selectedAt.toLocal()} · 서버 미전송'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      tooltip: '선택 파일 다운로드',
                      onPressed: () => download(file),
                      icon: const Icon(Icons.download, size: 18)),
                  if (canEdit)
                    IconButton(
                        tooltip: '현재 요청서에서 첨부 제외',
                        onPressed: () {
                          setState(() {
                            attachments.remove(file);
                            if (drawing?.id == file.id) drawing = null;
                            dirty = true;
                          });
                        },
                        icon: const Icon(Icons.close, size: 18))
                ])),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 12, children: [
            SizedBox(
                width: 360,
                child: DropdownButtonFormField<String>(
                    key: ValueKey('review-drawing-$formEpoch'),
                    initialValue: drawing?.id ?? '',
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: '연결 도면 파일·Rev',
                        isDense: true,
                        border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(
                          value: '', child: Text('미연결 (최초 요청 가능)')),
                      for (final d in drawings.values)
                        DropdownMenuItem(
                            value: d.id,
                            child: Text(
                                '${d.fileName} · ${d.revision}${d.demo ? ' · 시연' : ''}'))
                    ],
                    onChanged: !canEdit && !canReply
                        ? null
                        : (id) => setState(() {
                              drawing = drawings[id];
                              drawingNumber.text = drawing?.number ?? '';
                              dirty = true;
                            }))),
            SizedBox(
                width: 230,
                child: TextField(
                    key: const ValueKey('review-drawing-number'),
                    controller: drawingNumber,
                    enabled: canEdit || canReply,
                    onChanged: (_) => changed(),
                    decoration: const InputDecoration(
                        labelText: '연결 도면번호',
                        isDense: true,
                        border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),
          TextField(
              key: const ValueKey('review-reason'),
              controller: reason,
              enabled: canEdit || canReply,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                  labelText: '처리·수정 사유 (수정/재요청/반려/완료 시 필수)',
                  isDense: true,
                  border: OutlineInputBorder())),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (canEdit) ...[
              OutlinedButton(
                  key: const ValueKey('review-save'),
                  onPressed: !editableState
                      ? null
                      : () => run(RobotReviewAction.saveDraft),
                  child: const Text('요청서 임시 저장')),
              FilledButton(
                  key: const ValueKey('review-submit'),
                  onPressed: () => run(RobotReviewAction.submit),
                  child: Text(editableState
                      ? (record.status == RobotReviewStatus.draft
                          ? '검토 요청'
                          : '수정 후 재요청')
                      : '영업 수정 요청서 제출')),
            ],
            if (canReply) ...[
              OutlinedButton(
                  key: const ValueKey('review-start'),
                  onPressed: record.status != RobotReviewStatus.requested
                      ? null
                      : () => run(RobotReviewAction.start),
                  child: const Text('검토 시작')),
              OutlinedButton(
                  key: const ValueKey('review-changes'),
                  onPressed: !active
                      ? null
                      : () => run(RobotReviewAction.requestChanges),
                  child: const Text('영업에 수정 요청')),
              OutlinedButton(
                  key: const ValueKey('review-reject'),
                  onPressed:
                      !active ? null : () => run(RobotReviewAction.reject),
                  child: const Text('반려')),
              FilledButton(
                  key: const ValueKey('review-complete'),
                  onPressed:
                      !active ? null : () => run(RobotReviewAction.complete),
                  child: const Text('검토 완료')),
            ],
          ]),
          const SizedBox(height: 10),
          ExpansionTile(
              key: const ValueKey('review-history'),
              tilePadding: EdgeInsets.zero,
              title: Text('검토 요청·수정 이력 ${record.history.length}건'),
              children: [
                for (final event in record.history.reversed)
                  ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                          'Rev.${event.revision} · ${event.from.label} → ${event.to.label}'),
                      subtitle: Text(
                          '${event.author} · ${event.role == RobotReviewRole.sales ? '영업' : '설계'} · ${event.at.toLocal()}\n${event.reason}\n연결 도면: ${event.snapshot.drawing?.label ?? '없음'}'),
                      onTap: () => viewEvent(event),
                      trailing: const Icon(Icons.open_in_new, size: 16))
              ]),
        ]));
  }
}

class _ReviewAttachmentMetadata extends StatefulWidget {
  const _ReviewAttachmentMetadata();
  @override
  State<_ReviewAttachmentMetadata> createState() =>
      _ReviewAttachmentMetadataState();
}

class _ReviewAttachmentMetadataState extends State<_ReviewAttachmentMetadata> {
  final number = TextEditingController();
  final revision = TextEditingController();
  String? error;
  @override
  void dispose() {
    number.dispose();
    revision.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
          title: const Text('첨부 파일 정보'),
          content: SizedBox(
              width: 480,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('일반 참고자료는 비워두세요. 도면으로 연결하려면 도면번호와 Rev를 모두 입력해주세요.'),
                const SizedBox(height: 12),
                TextField(
                    controller: number,
                    decoration: const InputDecoration(labelText: '도면번호')),
                TextField(
                    controller: revision,
                    decoration: const InputDecoration(labelText: '도면 Rev')),
                if (error != null)
                  Text(error!,
                      style: const TextStyle(color: RobinTheme.signalRed)),
              ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소')),
            FilledButton(
                onPressed: () {
                  if (number.text.trim().isEmpty !=
                      revision.text.trim().isEmpty) {
                    setState(() => error = '도면번호와 Rev를 함께 입력해주세요.');
                    return;
                  }
                  Navigator.pop(
                      context, (number.text.trim(), revision.text.trim()));
                },
                child: const Text('첨부 추가'))
          ]);
}
