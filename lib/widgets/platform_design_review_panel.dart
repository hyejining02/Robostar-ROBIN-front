part of 'platform_review_workspace.dart';

/// Project-specific design request form from platform HTML designReqHTML/pjDetail.
/// The existing request/reply store remains the source for design work and To-Dos.
class PlatformDesignReviewPanel extends StatefulWidget {
  final PlatformPipelineData data;
  const PlatformDesignReviewPanel({super.key, required this.data});
  @override
  State<PlatformDesignReviewPanel> createState() =>
      _PlatformDesignReviewPanelState();
}

class _PlatformDesignReviewPanelState extends State<PlatformDesignReviewPanel> {
  PlatformPipelineData get data => widget.data;
  PlatformReviewAccess get access => PlatformReviewAccess.current();
  final due = TextEditingController();
  final requestText = TextEditingController();
  final reason = TextEditingController();
  final question = TextEditingController();
  final references = <PlatformReviewFile>[];
  Set<PlatformReviewKind> kinds = PlatformReviewKind.values.toSet();
  int tab = 0;
  int formEpoch = 0;
  int? targetRevision;
  String? selectedId;
  PlatformReview? editing;
  String message = '';
  bool formOpen = false;
  bool busy = false;

  List<PlatformReview> get reviews => platformReviews.value
      .where((r) => r.request.fields['sl'] == data.key.$2)
      .toList();
  String get designer => data.designer.isNotEmpty
      ? data.designer
      : reviews.lastOrNull?.request.fields['designer'] ?? '';
  bool get canAssign =>
      access.read &&
      (robinUserProfile.value.isAdmin ||
          (robinUserProfile.value.departmentPermission ==
                  RobinDepartmentPermission.engineering &&
              robinTeams.value
                  .any((t) => t.leaderId == robinUserProfile.value.username)));

  @override
  void initState() {
    super.initState();
    due.text = DateTime.now()
        .add(const Duration(days: 5))
        .toIso8601String()
        .substring(0, 10);
  }

  @override
  void dispose() {
    for (final c in [due, requestText, reason, question]) {
      c.dispose();
    }
    super.dispose();
  }

  String kindLabel(Set<PlatformReviewKind> types) => types.length == 2
      ? '재료비 + Layout'
      : types.contains(PlatformReviewKind.material)
          ? '재료비'
          : 'Layout';
  String statusLabel(PlatformReview review) => switch (review.status) {
        '미확인' => '요청',
        '검토중' => '검토 중',
        _ => '회신',
      };

  Future<void> attachReference() async {
    setState(() => busy = true);
    try {
      final file = await DesktopFileService.pickReferenceDocument();
      if (file != null && mounted) {
        setState(() => references.add(PlatformReviewFile(
            id: 'design-ref-${DateTime.now().microsecondsSinceEpoch}',
            file: file,
            revision: '요청 Rev.${(editing?.request.revision ?? 0) + 1}')));
      }
    } catch (e) {
      if (mounted) setState(() => message = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void send() {
    try {
      if (!data.assessSaved) throw StateError('Assess를 먼저 저장한 뒤 검토를 요청해주세요.');
      final saved = savePlatformRequest(
          actor: access,
          fields: {
            'pipeline': data.key.$2,
            'sl': data.key.$2,
            'project': data.projectName,
            'customer': data.assess['customer'] ?? '',
            'sales': data.owner,
            'designer': designer,
            'object': data.materials.join(', '),
            'due': due.text,
            'spec': requestText.text,
            'targetRevision': targetRevision?.toString() ?? '',
          },
          kinds: kinds,
          attachments: references,
          id: editing?.id,
          expectedVersion: editing?.version,
          reason: reason.text);
      data.history.insert(0,
          '${DateTime.now()} · ${access.author} · 설계 검토 요청 · ${kindLabel(kinds)}');
      setState(() {
        selectedId = saved.id;
        requestText.clear();
        reason.clear();
        references.clear();
        editing = null;
        formOpen = false;
        formEpoch++;
        message = '설계 검토를 요청했습니다.';
      });
    } catch (e) {
      setState(() => message = e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  void editRequest(PlatformReview record) => setState(() {
        editing = record;
        requestText.text = record.request.fields['spec'] ?? '';
        due.text = record.request.fields['due'] ?? '';
        kinds = {...record.request.kinds};
        targetRevision =
            int.tryParse(record.request.fields['targetRevision'] ?? '');
        references
          ..clear()
          ..addAll(record.request.attachments);
        reason.clear();
        formOpen = true;
        formEpoch++;
        message = '';
      });

  Future<void> uploadDocument(String category) async {
    try {
      final file = await DesktopFileService.pickReferenceDocument();
      if (file == null || !mounted) return;
      final previous = data.designDocuments
          .where((d) => d.category == category && d.file.name == file.name);
      final revision =
          previous.fold<int>(0, (n, d) => math.max(n, d.revision)) + 1;
      setState(() => data.designDocuments.add(
          PlatformDesignDocument(file, category, revision, access.author)));
    } catch (e) {
      if (mounted) setState(() => message = '$e');
    }
  }

  Widget fileLink(SelectedDesktopFile file, {String? label}) => TextButton.icon(
      icon: const Icon(Icons.download, size: 15),
      label: Text(label ?? file.name),
      onPressed: () async {
        try {
          await DesktopFileService.saveSelectedDocument(file);
        } catch (e) {
          if (mounted) setState(() => message = '$e');
        }
      });

  @override
  Widget build(BuildContext context) {
    if (!access.read) return const Text('설계 검토 조회 권한이 없습니다.');
    return ValueListenableBuilder<List<PlatformReview>>(
        valueListenable: platformReviews,
        builder: (_, __, ___) {
          final rows = reviews.reversed.toList();
          final chosen = rows.where((r) => r.id == selectedId).firstOrNull ??
              rows.firstOrNull;
          final replies = rows
              .expand((r) => r.replies.where((reply) =>
                  reply.requestRevision == r.request.revision &&
                  reply.status == PlatformReplyStatus.done))
              .toList()
            ..sort((a, b) => b.at.compareTo(a.at));
          final material = replies
              .where((r) => r.kind == PlatformReviewKind.material)
              .firstOrNull;
          final layout = replies
              .where((r) => r.kind == PlatformReviewKind.layout)
              .firstOrNull;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                platformCard('', [
                  Text(
                      '${data.key.$2} · ${data.assess['customer'] ?? ''} · ${data.projectName}',
                      style: RobinTheme.headingSm),
                  const SizedBox(height: 8),
                  Wrap(spacing: 20, runSpacing: 6, children: [
                    Text('영업  ${data.owner}'),
                    Text('설계  ${designer.isEmpty ? '배정 대기' : designer}'),
                    Text(
                        '이재물  ${data.materials.isEmpty ? '-' : data.materials.join(', ')}'),
                    Text('최신 재료비  ${material?.result?.revision ?? '-'}'),
                    Text('최신 Layout  ${layout?.result?.file.name ?? '-'}'),
                  ]),
                  if (data.units.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                            data.units
                                .where((u) => !u.excluded)
                                .map((u) => u.number)
                                .join(' · '),
                            style: RobinTheme.labelXs)),
                ]),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (var i = 0; i < 4; i++)
                    ChoiceChip(
                        key: ValueKey('platform-design-tab-$i'),
                        label: Text(
                            ['① 설계 요청', '② 사양 Q&A', '③ 자료실', '④ 재료비 버전'][i]),
                        selected: tab == i,
                        onSelected: (_) => setState(() => tab = i)),
                ]),
                const SizedBox(height: 12),
                if (message.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(message,
                          key: const ValueKey('platform-design-message'))),
                if (tab == 0) ...[
                  if (!data.assessSaved)
                    const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child:
                            Text('Assess를 저장한 뒤 설계 담당자를 지정하고 검토를 요청할 수 있습니다.')),
                  if (canAssign) assignment(),
                  if (access.request) requestForm(rows.isEmpty),
                  platformCard('검토 요청 · ${rows.length}건', [
                    if (rows.isEmpty)
                      const Text('아직 검토 요청이 없습니다.')
                    else
                      SizedBox(
                          height: math.min(300, 40.0 + rows.length * 45),
                          child: SingleChildScrollView(
                              child: platformTable(
                            key: const ValueKey('platform-design-request-list'),
                            minWidth: 850,
                            headers: const [
                              'No',
                              '유형',
                              '대상',
                              '요청',
                              '희망 회신',
                              '상태'
                            ],
                            widths: const [.5, 1.4, 1, 2, 1.4, 1],
                            rows: [
                              for (var i = 0; i < rows.length; i++)
                                TableRow(
                                    decoration: BoxDecoration(
                                        color: chosen?.id == rows[i].id
                                            ? RobinTheme.background
                                            : Colors.white),
                                    children: [
                                      platformTableCell(TextButton(
                                          onPressed: () => setState(
                                              () => selectedId = rows[i].id),
                                          child: Text(
                                              '#${reviews.indexOf(rows[i]) + 1}'))),
                                      platformTableText(
                                          kindLabel(rows[i].request.kinds)),
                                      platformTableText((rows[i].request.fields[
                                                      'targetRevision'] ??
                                                  '')
                                              .isEmpty
                                          ? '견적 전'
                                          : 'Rev.${rows[i].request.fields['targetRevision']}'),
                                      platformTableText(
                                          '${rows[i].request.author} · ${rows[i].request.at.toString().substring(0, 10)}'),
                                      platformTableText(
                                          rows[i].request.fields['due'] ?? ''),
                                      platformTableText(statusLabel(rows[i])),
                                    ])
                            ],
                          ))),
                  ]),
                  if (chosen != null)
                    platformCard('요청 상세 · ${kindLabel(chosen.request.kinds)}', [
                      _PlatformReviewDetail(
                          key: ValueKey(chosen.id),
                          record: chosen,
                          onEdit: () => editRequest(chosen)),
                    ]),
                ] else if (tab == 1)
                  qa()
                else if (tab == 2)
                  documents(rows)
                else
                  versions(rows),
              ]);
        });
  }

  Widget assignment() {
    final people = <String>{
      if (designer.isNotEmpty) designer,
      for (final employee in robinEmployees.value)
        if (employee.departmentPermission ==
            RobinDepartmentPermission.engineering)
          '${employee.name} ${employee.rank}',
    };
    return platformCard('설계 담당 지정', [
      const Text('설계팀장이 담당자를 지정합니다. 설계는 재료비·Layout을 회신하고, 영업이 VRB와 견적서를 작성합니다.',
          style: TextStyle(fontSize: 12)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
          key: ValueKey('platform-design-assignee-$designer'),
          initialValue: designer.isEmpty ? null : designer,
          isExpanded: true,
          decoration: const InputDecoration(
              labelText: '설계 담당자', isDense: true, border: OutlineInputBorder()),
          items: [
            for (final person in people)
              DropdownMenuItem(value: person, child: Text(person))
          ],
          onChanged: !data.assessSaved
              ? null
              : (value) => setState(() {
                    data.designer = value ?? '';
                    data.history.insert(0,
                        '${DateTime.now()} · ${access.author} · 설계 담당 지정 · ${data.designer}');
                  })),
    ]);
  }

  Widget requestForm(bool empty) => platformCard('', [
        ExpansionTile(
            key: ValueKey('platform-design-request-$formEpoch'),
            initiallyExpanded: empty || formOpen,
            childrenPadding: const EdgeInsets.only(top: 8),
            tilePadding: EdgeInsets.zero,
            title: Text(editing == null ? '+ 설계 검토 요청' : '설계 검토 수정·재요청'),
            subtitle: Text(designer.isEmpty ? '설계 배정 대기' : '→ $designer'),
            children: [
              platformInlineFields([
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('요청 유형 *'),
                  const SizedBox(height: 4),
                  Wrap(spacing: 4, runSpacing: 4, children: [
                    for (final type in [
                      {PlatformReviewKind.material},
                      {PlatformReviewKind.layout},
                      PlatformReviewKind.values.toSet()
                    ])
                      ChoiceChip(
                          label: Text(kindLabel(type)),
                          selected: setEquals(type, kinds),
                          onSelected: (_) => setState(() => kinds = {...type})),
                  ]),
                ]),
                DropdownButtonFormField<int>(
                    key: ValueKey('platform-design-target-$formEpoch'),
                    initialValue: targetRevision,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: '대상',
                        isDense: true,
                        border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem<int>(child: Text('견적 전')),
                      for (final rev in data.revisions.reversed)
                        DropdownMenuItem(
                            value: rev.revision,
                            child: Text(
                                'Rev.${rev.revision} (${rev.at.toString().substring(0, 10)})'))
                    ],
                    onChanged: (value) =>
                        setState(() => targetRevision = value)),
                TextField(
                    key: const ValueKey('platform-design-due'),
                    controller: due,
                    decoration: InputDecoration(
                        labelText: '희망 회신일 *',
                        hintText: 'YYYY-MM-DD',
                        isDense: true,
                        border: const OutlineInputBorder(),
                        suffixIconConstraints: const BoxConstraints.tightFor(
                            width: 32, height: 32),
                        suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            onPressed: () async {
                              final date = await showDatePicker(
                                  context: context,
                                  initialDate: validPlatformDate(due.text)
                                      ? DateTime.parse(due.text)
                                      : DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100));
                              if (date != null && mounted) {
                                due.text =
                                    date.toIso8601String().substring(0, 10);
                              }
                            }))),
              ], columns: 3),
              const SizedBox(height: 12),
              TextField(
                  key: const ValueKey('platform-design-request-text'),
                  controller: requestText,
                  minLines: 2,
                  maxLines: null,
                  decoration: const InputDecoration(
                      labelText: '요청 내용 *',
                      hintText: '예: 고객 사양서 기준 TR 2대 재료비와 Layout 검토 부탁드립니다.',
                      isDense: true,
                      border: OutlineInputBorder())),
              const SizedBox(height: 8),
              Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                      onPressed: busy ? null : attachReference,
                      icon: const Icon(Icons.attach_file, size: 16),
                      label: const Text('참고 첨부'))),
              for (final file in references)
                Row(children: [
                  Expanded(child: Text(file.file.name)),
                  IconButton(
                      onPressed: () => setState(() => references.remove(file)),
                      icon: const Icon(Icons.close, size: 16))
                ]),
              if (editing != null)
                TextField(
                    controller: reason,
                    decoration:
                        const InputDecoration(labelText: '수정·재요청 사유 *')),
              Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                      key: const ValueKey('platform-design-send'),
                      onPressed: busy ? null : send,
                      child: const Text('검토 요청'))),
            ]),
      ]);

  Widget qa() => platformCard('사양 Q&A · 스펙 시트', [
        Wrap(spacing: 8, children: [
          if (access.request || access.reply)
            OutlinedButton(
                onPressed: () => uploadDocument('스펙 시트'),
                child: const Text('스펙 시트 업로드')),
          for (final doc
              in data.designDocuments.where((d) => d.category == '스펙 시트'))
            fileLink(doc.file, label: '${doc.file.name} · v${doc.revision}'),
        ]),
        if (data.designQuestions.isEmpty) const Text('아직 질문이 없습니다.'),
        for (final q in data.designQuestions.reversed)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Q. ${q.text} · ${q.answers.isEmpty ? '답변 대기' : '답변 완료'}',
                        style: RobinTheme.headingSm),
                    Text('${q.author} · ${q.at.toString().substring(0, 16)}',
                        style: RobinTheme.labelXs),
                    for (final answer in q.answers)
                      Padding(
                          padding: const EdgeInsets.only(left: 12, top: 6),
                          child: Text(
                              'A. ${answer['text']} · ${answer['author']} · ${answer['at']}')),
                    if (access.request || access.reply)
                      TextButton(
                          onPressed: () async {
                            final text =
                                await _platformText(context, '답변 또는 추가 코멘트');
                            if (text != null && mounted) {
                              setState(() => q.answers.add({
                                    'text': text,
                                    'author': access.author,
                                    'at': DateTime.now()
                                        .toString()
                                        .substring(0, 16)
                                  }));
                            }
                          },
                          child: const Text('답변 등록')),
                  ])),
        if (access.request || access.reply) ...[
          TextField(
              key: const ValueKey('platform-design-question'),
              controller: question,
              minLines: 2,
              maxLines: null,
              decoration: const InputDecoration(
                  labelText: '사양 관련 질문',
                  isDense: true,
                  border: OutlineInputBorder())),
          TextButton(
              onPressed: () {
                if (question.text.trim().isEmpty) {
                  setState(() => message = '질문을 입력해주세요.');
                  return;
                }
                setState(() {
                  data.designQuestions.add(PlatformDesignQuestion(
                      question.text.trim(), access.author));
                  question.clear();
                  message = '';
                });
              },
              child: const Text('질문 등록')),
        ],
      ]);

  Widget documents(List<PlatformReview> rows) => platformCard('자료실', [
        if (access.request || access.reply)
          Wrap(spacing: 8, children: [
            for (final category in ['고객 자료', '설계 산출물'])
              OutlinedButton(
                  onPressed: () => uploadDocument(category),
                  child: Text('$category 업로드')),
          ]),
        for (final entry in {
          'mail': '고객 자료 · Assess 이메일',
          'layout': '고객 자료 · Assess Layout',
          'material': '재료비 근거'
        }.entries)
          for (final file in data.files[entry.key]!)
            ListTile(
                dense: true,
                title: fileLink(file),
                subtitle: Text(entry.value)),
        for (final row in rows) ...[
          for (final file in row.request.attachments)
            ListTile(
                dense: true,
                title: _PlatformFileLink(file: file),
                subtitle: const Text('설계 요청 · 참고 첨부')),
          for (final reply in row.replies.where((r) => r.result != null))
            ListTile(
                dense: true,
                title: _PlatformFileLink(file: reply.result!),
                subtitle:
                    Text('설계 회신 · ${reply.kind.label} · ${reply.author}')),
        ],
        for (final doc in data.designDocuments.reversed)
          ListTile(
              dense: true,
              title: fileLink(doc.file,
                  label: '${doc.file.name} · v${doc.revision}'),
              subtitle: Text(
                  '${doc.category} · ${doc.author} · ${doc.at.toString().substring(0, 16)}')),
        if (data.designDocuments.isEmpty &&
            rows.isEmpty &&
            data.files.values.every((f) => f.isEmpty))
          const Padding(
              padding: EdgeInsets.all(12), child: Text('등록된 자료가 없습니다.')),
      ]);

  Widget versions(List<PlatformReview> rows) {
    final materials = rows
        .expand((r) => r.replies.where((p) =>
            p.kind == PlatformReviewKind.material &&
            p.status == PlatformReplyStatus.done &&
            p.result != null))
        .toList()
      ..sort((a, b) => b.at.compareTo(a.at));
    return platformCard('재료비 버전', [
      if (materials.isEmpty) const Text('아직 재료비 회신이 없습니다.'),
      for (final reply in materials)
        ListTile(
            dense: true,
            title: _PlatformFileLink(file: reply.result!),
            subtitle: Text(
                '요청 Rev.${reply.requestRevision} · ${reply.author} · ${reply.at.toString().substring(0, 16)}\n${reply.note}')),
    ]);
  }
}
