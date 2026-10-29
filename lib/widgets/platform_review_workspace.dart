import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/desktop_file_service.dart';
import '../services/platform_review_service.dart';
import '../services/platform_pipeline_service.dart';
import '../models/access_control.dart';
import '../theme/robin_theme.dart';
import '../utils/search_query.dart';
import 'robin_dialog.dart';
import 'user_profile.dart';
import 'platform_form_layout.dart';
import 'platform_assess_form.dart' show platformCard;

part 'platform_design_review_panel.dart';

class PlatformReviewWorkspace extends StatefulWidget {
  final bool initiallyExpanded;
  final String? initialSelectedId;
  final Map<String, String> initialRequestFields;
  const PlatformReviewWorkspace(
      {super.key,
      this.initiallyExpanded = false,
      this.initialSelectedId,
      this.initialRequestFields = const {}});
  @override
  State<PlatformReviewWorkspace> createState() =>
      _PlatformReviewWorkspaceState();
}

class _PlatformReviewWorkspaceState extends State<PlatformReviewWorkspace> {
  String query = '';
  String status = '전체';
  String? selected;
  @override
  void initState() {
    super.initState();
    selected = widget.initialSelectedId;
  }

  PlatformReviewAccess get access => PlatformReviewAccess.current();
  void error(Object error) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', ''))));

  Future<void> edit(PlatformReview? record) => showDialog<void>(
      context: context,
      builder: (_) => _PlatformRequestDialog(
          record: record, initialFields: widget.initialRequestFields));
  Future<void> priority(PlatformReview row, int delta) async {
    final reason = await _platformText(context, '우선순위 변경 사유');
    if (reason == null || !mounted) return;
    try {
      movePlatformPriority(
          actor: access, id: row.id, delta: delta, reason: reason);
    } catch (e) {
      error(e);
    }
  }

  void history() => showDialog<void>(
      context: context,
      builder: (_) => RobinAlertDialog(
              title: const Text('플랫폼 우선순위 변경 이력'),
              content: SizedBox(
                  width: 800,
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        for (final event
                            in platformPriorityHistory.value.reversed)
                          Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                  '${event.author} · ${event.at.toLocal()}\n사유: ${event.reason}\n'
                                  '변경 전: ${event.before.map((id) => platformReviewById(id).request.fields['sl']).join(' → ')}\n'
                                  '변경 후: ${event.after.map((id) => platformReviewById(id).request.fields['sl']).join(' → ')}')),
                        if (platformPriorityHistory.value.isEmpty)
                          const Text('변경 이력이 없습니다.'),
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'))
              ]));
  @override
  Widget build(BuildContext context) {
    if (!access.read) return const SizedBox.shrink();
    return ValueListenableBuilder<List<PlatformReview>>(
        valueListenable: platformReviews,
        builder: (context, rows, _) {
          final visible = rows
              .where((r) =>
                  (widget.initialRequestFields['sl'] == null ||
                      r.request.fields['sl'] ==
                          widget.initialRequestFields['sl']) &&
                  (status == '전체' || status == r.status) &&
                  matchesSearchQuery(r.request.fields.values, query))
              .toList();
          final chosen = visible.where((r) => r.id == selected).firstOrNull ??
              visible.firstOrNull;
          return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: RobinTheme.border),
                  borderRadius: BorderRadius.circular(8)),
              child: ExpansionTile(
                  key: ValueKey(
                      'platform-review-space-${widget.initiallyExpanded}'),
                  initiallyExpanded: widget.initiallyExpanded,
                  title: const Text('플랫폼 수주 전 검토 · SL CODE'),
                  subtitle: Text('${rows.length}건 · 독립 검토 작업공간 (단계 위치 미확정)'),
                  childrenPadding: const EdgeInsets.all(12),
                  children: [
                    const Text(
                        '프론트 시안 · SL CODE는 수동 입력이며 공식 채번/ERP 등록이 아닙니다. '
                        '기존 Assess 단계는 유지합니다. 검토 상태·필수값·권한은 설계팀 협의 전 기준입니다.\n'
                        '첨부는 현재 PC/브라우저의 로컬 참조이며 서버 공유는 미연동입니다.',
                        style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 10),
                    Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                              width: 330,
                              child: TextField(
                                  key: const ValueKey('platform-review-search'),
                                  onChanged: (v) => setState(() => query = v),
                                  decoration: const InputDecoration(
                                      labelText:
                                          'SL CODE / 프로젝트 / 고객 / 참조번호 검색',
                                      isDense: true,
                                      border: OutlineInputBorder()))),
                          SizedBox(
                              width: 160,
                              child: DropdownButtonFormField<String>(
                                  initialValue: status,
                                  decoration: const InputDecoration(
                                      labelText: '검토 상태',
                                      isDense: true,
                                      border: OutlineInputBorder()),
                                  items: ['전체', '미확인', '검토중', '검토완']
                                      .map((s) => DropdownMenuItem(
                                          value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (s) =>
                                      setState(() => status = s!))),
                          if (access.request)
                            FilledButton.icon(
                                key: const ValueKey('platform-review-create'),
                                onPressed: () => edit(null),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('신규 SL 검토 요청')),
                          OutlinedButton(
                              onPressed: history, child: const Text('우선순위 이력')),
                        ]),
                    const SizedBox(height: 10),
                    if (visible.isEmpty)
                      const Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('플랫폼 검토 요청이 없습니다. 신규 SL 검토 요청으로 등록해주세요.'))
                    else
                      LayoutBuilder(
                          builder: (_, constraints) => SizedBox(
                              height: math.min(320, 45.0 + visible.length * 55),
                              child: SingleChildScrollView(
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                          width: math.max(
                                              1100, constraints.maxWidth),
                                          child: DataTable(
                                            showCheckboxColumn: false,
                                            headingRowHeight: 40,
                                            dataRowMinHeight: 48,
                                            dataRowMaxHeight: 55,
                                            horizontalMargin: 8,
                                            columnSpacing: 16,
                                            columns: [
                                              for (final label in [
                                                '순위',
                                                'SL CODE',
                                                '프로젝트 · 고객사',
                                                '회신 기한',
                                                '영업 / 설계',
                                                '재료비',
                                                '레이아웃',
                                                '전체 상태'
                                              ])
                                                DataColumn(label: Text(label))
                                            ],
                                            rows: [
                                              for (final row in visible)
                                                DataRow(
                                                    key: ValueKey(
                                                        'platform-review-row-${row.id}'),
                                                    selected:
                                                        chosen?.id == row.id,
                                                    onSelectChanged: (_) =>
                                                        setState(() =>
                                                            selected = row.id),
                                                    cells: [
                                                      DataCell(Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                                '${rows.indexOf(row) + 1}'),
                                                            IconButton(
                                                                tooltip:
                                                                    '우선순위 올리기',
                                                                onPressed: !access
                                                                            .prioritize ||
                                                                        rows.indexOf(row) ==
                                                                            0
                                                                    ? null
                                                                    : () =>
                                                                        priority(
                                                                            row,
                                                                            -1),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .arrow_upward,
                                                                    size: 16)),
                                                            IconButton(
                                                                tooltip:
                                                                    '우선순위 내리기',
                                                                onPressed: !access
                                                                            .prioritize ||
                                                                        rows.indexOf(row) ==
                                                                            rows.length -
                                                                                1
                                                                    ? null
                                                                    : () =>
                                                                        priority(
                                                                            row,
                                                                            1),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .arrow_downward,
                                                                    size: 16))
                                                          ])),
                                                      DataCell(Text(row.request
                                                          .fields['sl']!)),
                                                      DataCell(SizedBox(
                                                          width: 230,
                                                          child: Text(
                                                              '${row.request.fields['project']}\n${row.request.fields['customer']}',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis))),
                                                      DataCell(Text(row.request
                                                          .fields['due']!)),
                                                      DataCell(Text(
                                                          '${row.request.fields['sales']}\n${row.request.fields['designer']}')),
                                                      for (final kind
                                                          in PlatformReviewKind
                                                              .values)
                                                        DataCell(Text(!row
                                                                .request.kinds
                                                                .contains(kind)
                                                            ? '요청 대상 아님'
                                                            : row
                                                                    .replyFor(
                                                                        kind)
                                                                    ?.status
                                                                    .label ??
                                                                '미확인')),
                                                      DataCell(
                                                          Text(row.status)),
                                                    ])
                                            ],
                                          )))))),
                    if (chosen != null) ...[
                      const Divider(),
                      _PlatformReviewDetail(
                          key: ValueKey(chosen.id), record: chosen)
                    ],
                  ]));
        });
  }
}

class _PlatformReviewDetail extends StatefulWidget {
  final PlatformReview record;
  final VoidCallback? onEdit;
  const _PlatformReviewDetail({super.key, required this.record, this.onEdit});
  @override
  State<_PlatformReviewDetail> createState() => _PlatformReviewDetailState();
}

class _PlatformReviewDetailState extends State<_PlatformReviewDetail> {
  bool designMode = false;
  PlatformReviewAccess get access => PlatformReviewAccess.current();
  @override
  void initState() {
    super.initState();
    designMode = !access.request && access.reply;
  }

  void history() => showDialog<void>(
      context: context,
      builder: (_) => RobinAlertDialog(
              title: Text('${widget.record.request.fields['sl']} · 요청·회신 버전 이력'),
              content: SizedBox(
                  width: 900,
                  height: math.min(650, MediaQuery.sizeOf(context).height * .65),
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        for (final request in widget.record.requests.reversed)
                          ExpansionTile(
                              title: Text(
                                  '요청 Rev.${request.revision} · ${request.author} · ${request.at.toLocal()}'),
                              children: [
                                Text(
                                    '수정 사유: ${request.reason.isEmpty ? '최초 요청' : request.reason}'),
                                for (final entry
                                    in platformRequestLabels.entries)
                                  Text(
                                      '${entry.value}: ${request.fields[entry.key] ?? '미입력'}'),
                                Text(
                                    '요청 항목: ${request.kinds.map((k) => k.label).join(', ')}'),
                                for (final file in request.attachments)
                                  _PlatformFileLink(file: file),
                              ]),
                        for (final reply in widget.record.replies.reversed)
                          ListTile(
                              dense: true,
                              title: Text(
                                  '${reply.kind.label} · ${reply.status.label} · 요청 Rev.${reply.requestRevision}'),
                              subtitle: Text(
                                  '${reply.author} · ${reply.at.toLocal()}\n예정일: ${reply.expectedDate} · ${reply.note}'),
                              trailing: reply.result == null
                                  ? null
                                  : _PlatformFileLink(file: reply.result!)),
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'))
              ]));
  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
                '${record.request.fields['sl']} · 요청 Rev.${record.request.revision} · 전체 ${record.status}',
                style: RobinTheme.headingSm,
                key: const ValueKey('platform-review-overall')),
            if (robinUserProfile.value.isAdmin)
              SizedBox(
                  width: 210,
                  child: DropdownButtonFormField<bool>(
                      key: const ValueKey('platform-review-demo-role'),
                      initialValue: designMode,
                      decoration: const InputDecoration(
                          labelText: '관리자 시연 역할',
                          isDense: true,
                          border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: false, child: Text('영업 요청 시연')),
                        DropdownMenuItem(value: true, child: Text('설계 회신 시연'))
                      ],
                      onChanged: (v) => setState(() => designMode = v!))),
            OutlinedButton(
                key: const ValueKey('platform-review-edit'),
                onPressed: !access.request || designMode
                    ? null
                    : widget.onEdit ??
                        () => showDialog<void>(
                            context: context,
                            builder: (_) =>
                                _PlatformRequestDialog(record: record)),
                child: const Text('요청 수정·재요청')),
            OutlinedButton(
                key: const ValueKey('platform-review-history'),
                onPressed: history,
                child: const Text('요청·회신 이력')),
          ]),
      const SizedBox(height: 8),
      Text(
          '${record.request.fields['customer']} · ${record.request.fields['project']}\n'
          '참조자: ${record.request.fields['cc'] ?? ''} · 요청 기한: ${record.request.fields['due']}\n'
          '이재물: ${record.request.fields['object'] ?? ''} · Stroke ${record.request.fields['stroke'] ?? ''}mm · 하중 ${record.request.fields['load'] ?? ''}kg · Warpage ${record.request.fields['warpage'] ?? ''}mm\n'
          '요청: ${record.request.fields['spec']}\n견적 참조: ${record.request.fields['quote'] ?? ''} · 수주 참조: ${record.request.fields['order'] ?? ''} (수동 참조 · ERP 검증 전)'),
      for (final file in record.request.attachments)
        _PlatformFileLink(file: file),
      const SizedBox(height: 8),
      for (final kind in PlatformReviewKind.values)
        Card(
            elevation: 0,
            color: RobinTheme.surface,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                          '${kind.label}: ${!record.request.kinds.contains(kind) ? '요청 대상 아님' : record.replyFor(kind)?.status.label ?? '미확인'}'),
                      if (record.replyFor(kind) != null)
                        Text(
                            '완료 예정 ${record.replyFor(kind)!.expectedDate.isEmpty ? '-' : record.replyFor(kind)!.expectedDate}\n최근 회신 ${record.replyFor(kind)!.at.toLocal()}'),
                      if (record.replyFor(kind)?.result != null)
                        _PlatformFileLink(file: record.replyFor(kind)!.result!),
                      OutlinedButton(
                          key: ValueKey('platform-reply-${kind.name}'),
                          onPressed: !access.reply ||
                                  !designMode ||
                                  !record.request.kinds.contains(kind)
                              ? null
                              : () => showDialog<void>(
                                  context: context,
                                  builder: (_) => _PlatformReplyDialog(
                                      record: record, kind: kind)),
                          child: const Text('회신 입력')),
                    ]))),
      const Text(
          '현재 요청 Rev에 대해 요청한 모든 항목이 검토완이어야 전체 검토완입니다. 요청 수정 시 이전 회신은 이력에 남고 현재 검토 상태는 다시 미확인으로 시작합니다.',
          style: TextStyle(fontSize: 11)),
    ]);
  }
}

class _PlatformRequestDialog extends StatefulWidget {
  final PlatformReview? record;
  final Map<String, String> initialFields;
  const _PlatformRequestDialog({this.record, this.initialFields = const {}});
  @override
  State<_PlatformRequestDialog> createState() => _PlatformRequestDialogState();
}

class _PlatformRequestDialogState extends State<_PlatformRequestDialog> {
  final fields = <String, TextEditingController>{};
  final reason = TextEditingController();
  Set<PlatformReviewKind> kinds = {};
  List<PlatformReviewFile> attachments = [];
  String? error;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    for (final key in platformRequestLabels.keys) {
      fields[key] = TextEditingController(
          text: widget.record?.request.fields[key] ??
              widget.initialFields[key] ??
              '');
    }
    if (widget.record == null) {
      fields['sales']!.text =
          '${robinUserProfile.value.name} ${robinUserProfile.value.rank}';
    }
    kinds = {
      ...widget.record?.request.kinds ?? PlatformReviewKind.values.toSet()
    };
    attachments = [...?widget.record?.request.attachments];
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    reason.dispose();
    super.dispose();
  }

  Future<void> attach() async {
    setState(() => busy = true);
    try {
      final file = await _pickPlatformFile(context);
      if (file != null && mounted) setState(() => attachments.add(file));
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
          title:
              Text(widget.record == null ? '신규 SL 검토 요청' : 'SL 검토 요청 수정·재요청'),
          content: SizedBox(
              width: 900,
              height: math.min(650, MediaQuery.sizeOf(context).height * .65),
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text(
                        'SL CODE는 기존 코드를 입력하세요. 공식 채번 규칙 미확정 · 요청 수정은 새 Rev로 저장합니다. *는 제출용 시안 필수값입니다.'),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 12, children: [
                      for (final key in platformRequestLabels.keys)
                        SizedBox(
                            width: key == 'spec' ? 720 : 230,
                            child: TextField(
                                key: ValueKey('platform-request-$key'),
                                controller: fields[key],
                                readOnly:
                                    widget.record?.request.fields['pipeline'] !=
                                            null &&
                                        [
                                          'sl',
                                          'project',
                                          'customer',
                                          'sales',
                                          'designer'
                                        ].contains(key),
                                maxLines: key == 'spec' ? 3 : 1,
                                decoration: InputDecoration(
                                    labelText: '${platformRequestLabels[key]}${[
                                      'sl',
                                      'project',
                                      'customer',
                                      'sales',
                                      'designer',
                                      'due',
                                      'spec'
                                    ].contains(key) ? ' *' : ''}',
                                    hintText:
                                        key == 'due' ? 'YYYY-MM-DD' : null,
                                    isDense: true,
                                    border: const OutlineInputBorder())))
                    ]),
                    const SizedBox(height: 12),
                    Wrap(spacing: 10, children: [
                      for (final kind in PlatformReviewKind.values)
                        FilterChip(
                            key: ValueKey('platform-request-kind-${kind.name}'),
                            label: Text('${kind.label} 검토 요청'),
                            selected: kinds.contains(kind),
                            onSelected: (v) => setState(() {
                                  if (v) {
                                    kinds.add(kind);
                                  } else {
                                    kinds.remove(kind);
                                  }
                                }))
                    ]),
                    const SizedBox(height: 10),
                    OutlinedButton(
                        onPressed: busy ? null : attach,
                        child: Text(busy ? '파일 선택 중…' : '회의록·사양 협의 자료 첨부')),
                    for (final file in attachments)
                      ListTile(
                          dense: true,
                          title: Text('${file.file.name} · ${file.revision}'),
                          trailing: IconButton(
                              onPressed: () =>
                                  setState(() => attachments.remove(file)),
                              icon: const Icon(Icons.close))),
                    const SizedBox(height: 10),
                    TextField(
                        key: const ValueKey('platform-request-reason'),
                        controller: reason,
                        maxLines: 2,
                        decoration: const InputDecoration(
                            labelText: '수정·재요청 사유',
                            border: OutlineInputBorder(),
                            isDense: true)),
                    if (error != null)
                      Text(error!,
                          style: const TextStyle(color: RobinTheme.signalRed)),
                  ]))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소')),
            FilledButton(
                key: const ValueKey('platform-request-save'),
                onPressed: busy
                    ? null
                    : () {
                        try {
                          savePlatformRequest(
                              actor: PlatformReviewAccess.current(),
                              fields: {
                                ...?widget.record?.request.fields,
                                for (final e in fields.entries)
                                  e.key: e.value.text
                              },
                              kinds: kinds,
                              attachments: attachments,
                              id: widget.record?.id,
                              expectedVersion: widget.record?.version,
                              reason: reason.text);
                          Navigator.pop(context);
                        } catch (e) {
                          setState(() => error =
                              e.toString().replaceFirst('Bad state: ', ''));
                        }
                      },
                child: const Text('검토 요청 저장'))
          ]);
}

class _PlatformReplyDialog extends StatefulWidget {
  final PlatformReview record;
  final PlatformReviewKind kind;
  const _PlatformReplyDialog({required this.record, required this.kind});
  @override
  State<_PlatformReplyDialog> createState() => _PlatformReplyDialogState();
}

class _PlatformReplyDialogState extends State<_PlatformReplyDialog> {
  final expected = TextEditingController();
  final note = TextEditingController();
  PlatformReplyStatus status = PlatformReplyStatus.unchecked;
  PlatformReviewFile? result;
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final reply = widget.record.replyFor(widget.kind);
    status = reply?.status ?? PlatformReplyStatus.unchecked;
    expected.text = reply?.expectedDate ?? '';
    note.text = reply?.note ?? '';
    result = reply?.result;
  }

  @override
  void dispose() {
    expected.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final files = <String, PlatformReviewFile>{
      for (final reply in widget.record.replies)
        if (reply.kind == widget.kind && reply.result != null)
          reply.result!.id: reply.result!,
      if (result != null) result!.id: result!,
    };
    return RobinAlertDialog(
        title: Text(
            '${widget.kind.label} 회신 · 요청 Rev.${widget.record.request.revision}'),
        content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      'SL CODE ${widget.record.request.fields['sl']} · ${widget.record.request.fields['project']}'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PlatformReplyStatus>(
                      key: const ValueKey('platform-reply-status'),
                      initialValue: status,
                      decoration: const InputDecoration(
                          labelText: '검토 상태', border: OutlineInputBorder()),
                      items: PlatformReplyStatus.values
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s.label)))
                          .toList(),
                      onChanged: (s) => setState(() => status = s!)),
                  const SizedBox(height: 10),
                  TextField(
                      key: const ValueKey('platform-reply-date'),
                      controller: expected,
                      decoration: const InputDecoration(
                          labelText: '완료 예정일 (검토중 필수)',
                          hintText: 'YYYY-MM-DD',
                          border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                      key: ValueKey('platform-reply-file-${result?.id}'),
                      initialValue: result?.id ?? '',
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: '결과 파일 Rev 선택 (과거 Rev 재사용 시 직접 선택)',
                          border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('미첨부')),
                        for (final file in files.values)
                          DropdownMenuItem(
                              value: file.id,
                              child:
                                  Text('${file.file.name} · ${file.revision}'))
                      ],
                      onChanged: (id) => setState(() => result = files[id])),
                  OutlinedButton(
                      key: const ValueKey('platform-reply-attach'),
                      onPressed: busy
                          ? null
                          : () async {
                              setState(() => busy = true);
                              try {
                                final file = await _pickPlatformFile(context);
                                if (file != null && mounted) {
                                  setState(() => result = file);
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() => error = e.toString());
                                }
                              } finally {
                                if (mounted) setState(() => busy = false);
                              }
                            },
                      child: Text(busy ? '파일 선택 중…' : '새 결과 파일·Rev 첨부')),
                  const Text(
                      '검토완은 실제 선택한 결과 파일과 Rev가 필요합니다. 과거 요청의 회신은 자동 승계하지 않습니다. 서버 업로드는 아직 미연동입니다.',
                      style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 10),
                  TextField(
                      key: const ValueKey('platform-reply-note'),
                      controller: note,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          labelText: '회신 내용·상태 변경 사유',
                          border: OutlineInputBorder())),
                  if (error != null)
                    Text(error!,
                        style: const TextStyle(color: RobinTheme.signalRed)),
                ]))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
              key: const ValueKey('platform-reply-save'),
              onPressed: busy
                  ? null
                  : () {
                      try {
                        savePlatformReply(
                            actor: PlatformReviewAccess.current(),
                            id: widget.record.id,
                            expectedVersion: widget.record.version,
                            kind: widget.kind,
                            status: status,
                            expectedDate: expected.text,
                            note: note.text,
                            result: result);
                        Navigator.pop(context);
                      } catch (e) {
                        setState(() => error =
                            e.toString().replaceFirst('Bad state: ', ''));
                      }
                    },
              child: const Text('회신 저장'))
        ]);
  }
}

class _PlatformFileLink extends StatelessWidget {
  final PlatformReviewFile file;
  const _PlatformFileLink({required this.file});
  @override
  Widget build(BuildContext context) => TextButton.icon(
      icon: const Icon(Icons.download, size: 16),
      label: Text('${file.file.name} · ${file.revision}'),
      onPressed: () async {
        try {
          await DesktopFileService.saveSelectedDocument(file.file);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('파일 다운로드 실패: $e')));
          }
        }
      });
}

int _platformFileSequence = 0;
Future<PlatformReviewFile?> _pickPlatformFile(BuildContext context) async {
  final file = await DesktopFileService.pickReferenceDocument();
  if (file == null || !context.mounted) return null;
  final rev = await _platformText(context, '${file.name} · 파일 Rev 입력');
  if (rev == null) return null;
  return PlatformReviewFile(
      id: 'file-${DateTime.now().microsecondsSinceEpoch}-${++_platformFileSequence}',
      file: file,
      revision: rev);
}

Future<String?> _platformText(BuildContext context, String title) =>
    showDialog<String>(
        context: context, builder: (_) => _PlatformTextDialog(title: title));

class _PlatformTextDialog extends StatefulWidget {
  final String title;
  const _PlatformTextDialog({required this.title});
  @override
  State<_PlatformTextDialog> createState() => _PlatformTextDialogState();
}

class _PlatformTextDialogState extends State<_PlatformTextDialog> {
  final input = TextEditingController();
  String? error;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
          title: Text(widget.title),
          content: SizedBox(
              width: 450,
              child: TextField(
                  key: const ValueKey('platform-text-input'),
                  controller: input,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: '필수 입력',
                      border: const OutlineInputBorder(),
                      errorText: error))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소')),
            FilledButton(
                onPressed: () {
                  if (input.text.trim().isNotEmpty) {
                    Navigator.pop(context, input.text.trim());
                  } else {
                    setState(() => error = '내용을 입력해주세요.');
                  }
                },
                child: const Text('확인'))
          ]);
}
