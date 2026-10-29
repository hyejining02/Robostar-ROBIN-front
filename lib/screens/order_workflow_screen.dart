import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/order_workflow_schema.dart';
import '../models/access_control.dart';
import '../services/desktop_file_service.dart';
import '../services/business_division_scope.dart';
import '../services/order_workflow_service.dart';
import '../widgets/robin_dialog.dart';
import '../widgets/user_profile.dart';

class OrderWorkflowButton extends StatelessWidget {
  final OrderWorkKey recordKey;
  final String projectName, section, label;
  const OrderWorkflowButton(
      {super.key,
      required this.recordKey,
      required this.projectName,
      this.section = 'documents',
      this.label = '수주 업무 상세'});
  @override
  Widget build(BuildContext context) => canReadWorkflow(recordKey)
      ? OutlinedButton.icon(
          key: ValueKey('workflow-open-$section'),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => OrderWorkflowScreen(
                      recordKey: recordKey,
                      projectName: projectName,
                      initialSection: section))),
          icon: const Icon(Icons.workspaces_outline, size: 17),
          label: Text(label))
      : const SizedBox.shrink();
}

class OrderWorkflowScreen extends StatefulWidget {
  final OrderWorkKey recordKey;
  final String projectName, initialSection;
  final String? initialRecordId;
  const OrderWorkflowScreen(
      {super.key,
      required this.recordKey,
      required this.projectName,
      this.initialSection = 'documents',
      this.initialRecordId});
  @override
  State<OrderWorkflowScreen> createState() => _OrderWorkflowScreenState();
}

class _OrderWorkflowScreenState extends State<OrderWorkflowScreen> {
  late String selected;
  String query = '';
  String basisId = '';
  String stockDate = DateTime.now().toIso8601String().substring(0, 10);
  bool withForecast = false;
  String? stockError;
  OrderWorkKey get recordKey => widget.recordKey;
  OrderWorkflow get data => workflowFor(recordKey);
  List<WorkSection> get sections => sectionsFor(recordKey.$1);
  @override
  void initState() {
    super.initState();
    selected = sections
            .where((s) =>
                s.id == widget.initialSection ||
                s.modules.contains(widget.initialSection))
            .firstOrNull
            ?.id ??
        sections.first.id;
    if (widget.initialRecordId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final r = data.find(widget.initialRecordId!);
        if (mounted && r != null && canReadWorkflow(recordKey)) detail(r);
      });
    }
  }

  void error(Object e) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))));
  Future<void> attempt(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (mounted) error(e);
    }
  }

  Future<String?> reason(String title) => showDialog<String>(
      context: context, builder: (_) => _ReasonDialog(title: title));
  List<WorkRecord> rows(String module) =>
      ['price', 'inventory', 'stockEvent'].contains(module)
          ? divisionRows(recordKey.$1, module)
          : data.rows(module);
  List<WorkRecord> visible(String module) => rows(module)
      .where((r) => '${r.values.values.join(' ')} ${r.author}'
          .toLowerCase()
          .contains(query.toLowerCase()))
      .toList();
  Future<void> edit(String module, [WorkRecord? record]) async {
    OrderWorkKey key = recordKey;
    if (['price', 'inventory', 'stockEvent'].contains(module) &&
        record != null) {
      key = orderWorkflows.value.entries
          .firstWhere((e) => e.value.find(record.id) != null)
          .key;
    }
    await showDialog<void>(
        context: context,
        builder: (_) =>
            _WorkRecordEditor(recordKey: key, module: module, record: record));
  }

  Future<void> detail(WorkRecord record) => showDialog<void>(
      context: context,
      builder: (context) => RobinAlertDialog(
              title: Text(
                  '${record['title'].isEmpty ? moduleTitles[record.module] : record['title']} · v${record.version}'),
              content: SizedBox(
                  width: 720,
                  child: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                        '시안 ID: ${record.id}\n등록·수정: ${record.author} · ${record.at.toLocal()}'),
                    const Divider(),
                    for (final e in record.values.entries)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SelectableText(
                              '${fieldsFor(record.module).where((f) => f.id == e.key).firstOrNull?.label ?? e.key}: ${e.value.isEmpty ? '미입력' : e.value}')),
                    if (record.file != null &&
                        !kIsWeb &&
                        record.file!.name != 'ROBIN_DEMO.txt')
                      TextButton.icon(
                          onPressed: () => attempt(() =>
                              DesktopFileService.openWithDefaultApp(
                                  record.file!.path)),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('PC 기본앱으로 원본 열기')),
                    if (record.file != null)
                      TextButton.icon(
                          onPressed: () => attempt(() async {
                                await DesktopFileService.saveSelectedDocument(
                                    record.file!);
                              }),
                          icon: const Icon(Icons.download),
                          label: Text('원본 다운로드 · ${record.file!.name}')),
                    if (record.module == 'vrb')
                      Text('총원가 ${vrbCost(record).toStringAsFixed(0)}원 · '
                          '이익 ${(workNumber(record['proposalAmount'], '제안가') - vrbCost(record)).toStringAsFixed(0)}원 · '
                          '이익률 ${((1 - vrbCost(record) / workNumber(record['proposalAmount'], '제안가')) * 100).toStringAsFixed(2)}%'),
                    if (record.module == 'poCompare')
                      Text(
                          '금액: ${workNumber(record['poAmount'], '금액') == workNumber(record['registeredAmount'], '금액') ? '일치' : '불일치'} · '
                          '납기: ${record['poDate'] == record['registeredDate'] ? '일치' : '불일치'} · 수동 대조'),
                    const Divider(),
                    const Text('이 항목의 변경 전후 이력'),
                    for (final event in (orderWorkflows.value.entries
                                .where((e) => e.value.find(record.id) != null)
                                .firstOrNull
                                ?.value
                                .history ??
                            data.history)
                        .where((e) => e.after.id == record.id)
                        .toList()
                        .reversed)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                              '${event.after.author} · ${event.after.at.toLocal()} · ${event.reason}\n'
                              '${event.after.values.entries.where((e) => event.before?[e.key] != e.value).map((e) => '${e.key}: ${event.before?[e.key] ?? '미입력'} → ${e.value}').join('\n')}')),
                  ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'))
              ]));

  Widget action(String label, Future<void> Function() callback) =>
      OutlinedButton(onPressed: () => attempt(callback), child: Text(label));
  Widget materialSummary() {
    final candidates = rows('costBasis');
    final chosen = candidates.where((r) => r.id == basisId).firstOrNull ??
        candidates.firstOrNull;
    if (chosen == null) {
      return const Text('유사실적 기준과 BOM을 등록하면 산출 결과를 확인할 수 있습니다.');
    }
    final calc = calculateMaterial(recordKey, chosen.id);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DropdownButton<String>(
          key: const ValueKey('cost-basis-select'),
          isExpanded: true,
          value: chosen.id,
          items: [
            for (final c in candidates)
              DropdownMenuItem(
                  value: c.id,
                  child:
                      Text('${c['title']} · ${c['reference']} · ${c['model']}'))
          ],
          onChanged: (v) => setState(() => basisId = v!)),
      Text(
          '기준 ${calc.base.toStringAsFixed(0)} + 추가 ${calc.added.toStringAsFixed(0)} − 제외 ${calc.removed.toStringAsFixed(0)} + 대체차액 ${calc.replaced.toStringAsFixed(0)}원'),
      Text(calc.total == null
          ? '계산 보류: ${calc.missing.join(' / ')}'
          : '예상 재료비 ${calc.total!.toStringAsFixed(0)}원'),
      action('산출 버전 저장', () async {
        final why = await reason('산출 저장 사유');
        if (why != null) saveMaterialSnapshot(recordKey, chosen.id, why);
      }),
      for (final close in data
          .rows('closing')
          .where((r) => r['actualMaterialAmount'].isNotEmpty))
        Text(
            '실제 마감 참조 ${close['actualMaterialAmount']}원 · ${close['evidence']} · '
            '현재 산출과 차이 ${calc.total == null ? '미확인' : (workNumber(close['actualMaterialAmount'], '실제원가') - calc.total!).toStringAsFixed(0)}원'),
    ]);
  }

  Widget stockSummary() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                  width: 200,
                  child: TextField(
                      decoration: const InputDecoration(
                          labelText: '예측 기준일 YYYY-MM-DD', isDense: true),
                      controller: null,
                      onChanged: (v) => setState(() => stockDate = v.trim()))),
              Text('기준일 $stockDate'),
              FilterChip(
                  label: const Text('Forecast 시나리오 포함'),
                  selected: withForecast,
                  onSelected: (v) => setState(() => withForecast = v))
            ]),
        for (final r in rows('inventory'))
          Builder(builder: (_) {
            double? qty;
            String? problem;
            try {
              qty = projectedStock(recordKey, r['part'], stockDate,
                  forecast: withForecast);
            } catch (e) {
              problem = e.toString();
            }
            final threshold = double.tryParse(r['safetyQty']) ?? 0;
            return ListTile(
                dense: true,
                title: Text('${r['part']} · ${r['title']}'),
                subtitle: Text(
                    '현재고 ${r['onHandQty']} · 기준 ${r['snapshotDate']} · ${r['snapshotReference']}'),
                trailing: Text(
                    problem != null
                        ? '날짜 확인 필요'
                        : qty == null
                            ? '기준일 이전·미확인'
                            : '예상 ${qty.toStringAsFixed(1)}${qty < threshold ? ' · 부족 경고' : ''}',
                    style: TextStyle(
                        color: qty != null && qty < threshold
                            ? Colors.red
                            : null)));
          }),
      ]);

  Widget approvalSummary() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, children: [
          action('시연 결재 요청', () async {
            await showDialog<void>(
                context: context,
                builder: (_) => _ApprovalRequestDialog(recordKey: recordKey));
          }),
          Text(mayTransferOrder(recordKey)
              ? '시연 이관 조건 충족'
              : '미결재/근거 변경 · 시연 이관 제한'),
        ]),
        for (final r in data.rows('approval'))
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                        '${r['state']} · ${r['approvers']} · ${r['step']}단계 처리 · ${r.at.toLocal()}'),
                    if (r['state'] == '진행') ...[
                      for (final approve in [true, false])
                        action(approve ? '현재 순서 승인(시연)' : '반려(시연)', () async {
                          final why = await reason('결재 처리 사유');
                          if (why != null) {
                            decideOrderApproval(
                                recordKey, r.id, r.version, approve, why);
                          }
                        })
                    ],
                  ])),
      ]);

  Widget closingSummary() {
    final totals = paymentTotals(recordKey);
    final expected = totals.expected, paid = totals.paid;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          '입력된 계약금액 ${expected.toStringAsFixed(0)}원 · 실제 입금 ${paid.toStringAsFixed(0)}원 · 미수 ${(expected - paid).toStringAsFixed(0)}원 · '
          '수금률 ${expected == 0 ? '미확인' : (paid / expected * 100).toStringAsFixed(1)}% (입금 근거 수동 입력)'),
      const Text('아래는 요청 이력만 남깁니다. ERP 성공·실패·매출/회계 실적을 임의로 만들지 않습니다.'),
      if (robinUserProfile.value.isAdmin)
        Wrap(spacing: 8, children: [
          for (final operation in ['수주 이관', '출하 요청', '마감 조회'])
            action('$operation 시안', () async {
              final why = await reason('ERP 요청 시안 사유');
              if (why != null) queueErpRequest(recordKey, operation, why);
            })
        ]),
    ]);
  }

  Widget purchaseSummary() {
    final groups = <(String, String), List<WorkRecord>>{};
    for (final r in visible('purchase')) {
      (groups[(r['unit'], r['module'])] ??= []).add(r);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final entry in groups.entries)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
                '${entry.key.$1.isEmpty ? '호기 미입력' : entry.key.$1} / ${entry.key.$2.isEmpty ? '모듈 미입력' : entry.key.$2} · '
                '필요 ${entry.value.fold<double>(0, (s, r) => s + workNumber(r['requiredQty'], '수량'))} · '
                '발주 ${entry.value.fold<double>(0, (s, r) => s + workNumber(r['orderedQty'], '수량'))} · '
                '입고 ${entry.value.fold<double>(0, (s, r) => s + workNumber(r['receivedQty'], '수량'))} · '
                '미입고 ${entry.value.fold<double>(0, (s, r) => s + workNumber(r['unreceivedQty'], '수량'))}')),
      const Text('입고량/발주량을 별도 표시합니다. 실제 진척률의 분모·반품·취소 기준은 미확정입니다.'),
    ]);
  }

  Widget module(String name) {
    final list = visible(name);
    final fields = fieldsFor(name);
    final immutable = [
      'quote',
      'vrb',
      'costSnapshot',
      'budget',
      'payment',
      'integration'
    ].contains(name);
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('${moduleTitles[name]} · ${list.length}건',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (fields.isNotEmpty && canEditWorkflow(recordKey, name))
                      OutlinedButton.icon(
                          key: ValueKey('add-$name'),
                          onPressed: () => edit(name),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(immutable ? '새 버전 등록' : '등록')),
                    action('조회 결과 Excel', () async {
                      final headers = [
                        'ID',
                        '버전',
                        '등록자',
                        '시각',
                        '처리상태',
                        ...fields.map((f) => f.label),
                        if (fields.isEmpty) '내용'
                      ];
                      final path = await DesktopFileService.saveWorkbook(
                          suggestedName: 'ROBIN_${recordKey.$2}_$name.xlsx',
                          sheetName: '조회결과',
                          headers: headers,
                          rows: [
                            for (final r in list)
                              [
                                r.id,
                                r.version,
                                r.author,
                                r.at.toIso8601String(),
                                r['state'].isEmpty ? r['status'] : r['state'],
                                ...fields.map((f) => r[f.id]),
                                if (fields.isEmpty) r.values.toString()
                              ]
                          ]);
                      if (path != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('현재 조회 결과를 저장했습니다.')));
                      }
                    }),
                  ]),
              if (list.isEmpty)
                const Padding(
                    padding: EdgeInsets.all(12),
                    child:
                        Text('등록된 데이터가 없습니다. ERP 조회값을 대신하는 예시는 자동 생성하지 않습니다.')),
              if (list.isNotEmpty)
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                        columnSpacing: 18,
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 76,
                        columns: [
                          for (final label in [
                            '업무/품목',
                            '상태/요약',
                            '최근 변경',
                            '파일',
                            '작업'
                          ])
                            DataColumn(label: Text(label))
                        ],
                        rows: [
                          for (final r in list)
                            DataRow(key: ValueKey(r.id), cells: [
                              DataCell(SizedBox(
                                  width: 200,
                                  child: Tooltip(
                                      message: r.values.toString(),
                                      child: Text(
                                          '${r['title'].isEmpty ? r['part'] : r['title']}\n${r['serial'].isNotEmpty ? r['serial'] : r['part']}',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis)))),
                              DataCell(SizedBox(
                                  width: 330,
                                  child: Text(summary(r),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis))),
                              DataCell(Text(
                                  '${r['revision'].isEmpty ? 'v${r.version}' : r['revision']} · ${r.author}\n${r.at.toLocal().toString().substring(0, 16)}')),
                              DataCell(Text(r.file?.name ?? '—')),
                              DataCell(Row(children: [
                                TextButton(
                                    onPressed: () => detail(r),
                                    child: const Text('상세·이력')),
                                if (!immutable &&
                                    fields.isNotEmpty &&
                                    canEditWorkflow(recordKey, name))
                                  TextButton(
                                      onPressed: () => edit(name, r),
                                      child: const Text('수정')),
                                if (name == 'allocation' &&
                                    r['state'] != '회수' &&
                                    canEditWorkflow(recordKey, name))
                                  TextButton(
                                      onPressed: () => attempt(() async {
                                            final why =
                                                await reason('배포 회수 사유');
                                            if (why != null) {
                                              recallAllocation(recordKey, r.id,
                                                  r.version, why);
                                            }
                                          }),
                                      child: const Text('배포 회수')),
                                if (name == 'product' &&
                                    canEditWorkflow(recordKey, name))
                                  PopupMenuButton<String>(
                                      tooltip: '생산 상태 처리',
                                      onSelected: (action) => attempt(() async {
                                            final why =
                                                await reason('$action 사유');
                                            if (why != null) {
                                              productAction(recordKey, r.id,
                                                  r.version, action, why);
                                            }
                                          }),
                                      itemBuilder: (_) => [
                                            for (final a in [
                                              '명판 스캔 시연',
                                              '불량대기',
                                              '도급자재대기',
                                              '사급자재대기',
                                              '사급모터대기',
                                              '기타대기',
                                              '생산재개',
                                              '포장 스캔 시연'
                                            ])
                                              PopupMenuItem(
                                                  value: a, child: Text(a))
                                          ]),
                              ])),
                            ])
                        ])),
            ])));
  }

  String summary(WorkRecord r) => switch (r.module) {
        'price' =>
          '${r['unitAmount']} ${r['currency']}/${r['unit']} · ${r['effectiveDate']} · ${r['maker']} · ${r['exception']} ${r['unitAmount'] == '0' ? '단가 확인 필요' : ''}',
        'costSnapshot' => '${r['totalAmount']}원 · ${r['reference']}',
        'quote' =>
          '${r['proposalAmount']}원 · ${r['spec']} · ${data.rows('quote').lastOrNull?.id == r.id ? '최신 진행 기준' : '과거 Rev'}',
        'vrb' =>
          '총원가 ${vrbCost(r).toStringAsFixed(0)}원 · 제안가 ${r['proposalAmount']}원 · ${r['rateVersion']}',
        'purchase' =>
          '호기 ${r['unit']} / ${r['module']} · 필요 ${r['requiredQty']} / 발주 ${r['orderedQty']} / 입고 ${r['receivedQty']} / 미입고 ${r['unreceivedQty']}\n예정 ${r['latestDate']} · 적용 ${r['applicationState']}',
        'consignment' =>
          '${r['type']} · 입고 ${r['receivedQty']}/${r['plannedQty']} · 투입 ${r['usedQty']} · ${r['costTreatment']}',
        'allocation' =>
          '${r['supplier']} · ${r['workCenter']} · ${r['quantityQty']}/${r['orderQty']}대',
        'schedule' =>
          '${r['unit']} / ${r['module']} · ${r['planStartDate']} ~ ${r['planEndDate']} · ${r['actualEndDate'].isNotEmpty ? '완료' : r['planEndDate'].compareTo(DateTime.now().toIso8601String().substring(0, 10)) < 0 ? '계획일 초과' : '진행/대기'}',
        'hierarchy' =>
          '${r['type']} ${r['reference']} · ${r['state']} · 진척 ${r['progressRate'].isEmpty ? '미확인' : '${r['progressRate']}%'} · 납기 ${r['risk']}',
        'integration' => '${r['state']} · ${r['result']}',
        _ => r.values.entries
            .where((e) => e.key != 'title' && e.value.isNotEmpty)
            .take(5)
            .map((e) => e.value)
            .join(' · '),
      };

  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: Listenable.merge([
        orderWorkflows,
        robinUserProfile,
        selectedBusinessDivision,
        robinTeams
      ]),
      builder: (context, _) => Scaffold(
          appBar:
              AppBar(title: Text('${widget.projectName} · ${recordKey.$2}')),
          body: !canReadWorkflow(recordKey)
              ? const Center(child: Text('해당 수주의 내부 업무 조회 권한이 없습니다.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${recordKey.$1.label} · 수주 업무 상세',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text(
                            '프론트 시안 · 앱 실행 중 임시 저장 · ERP/서버 미연동 · 금액은 원, 날짜는 YYYY-MM-DD'),
                        if (robinUserProfile.value.isAdmin)
                          action('빈 수주에 시연 데이터 채우기', () async {
                            final why = await reason(
                                '시연 데이터 생성 확인 · 기존 입력이 있으면 실행하지 않습니다.');
                            if (why != null) seedWorkflowDemo(recordKey);
                          }),
                        action('수주 전체 변경이력 Excel', () async {
                          await DesktopFileService.saveWorkbook(
                              suggestedName:
                                  'ROBIN_${recordKey.$2}_history.xlsx',
                              sheetName: '업무이력',
                              headers: [
                                '항목ID',
                                '업무',
                                '버전',
                                '처리자',
                                '시각',
                                '사유',
                                '변경 전',
                                '변경 후'
                              ],
                              rows: [
                                for (final e in data.history)
                                  [
                                    e.after.id,
                                    e.after.module,
                                    e.after.version,
                                    e.after.author,
                                    e.after.at.toIso8601String(),
                                    e.reason,
                                    e.before?.values.toString() ?? '',
                                    e.after.values.toString()
                                  ]
                              ]);
                        }),
                        const SizedBox(height: 10),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          for (final s in sections)
                            ChoiceChip(
                                key: ValueKey('section-${s.id}'),
                                label: Text(s.title),
                                selected: s.id == selected,
                                onSelected: (_) =>
                                    setState(() => selected = s.id))
                        ]),
                        const SizedBox(height: 12),
                        Builder(builder: (_) {
                          final s =
                              sections.firstWhere((s) => s.id == selected);
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('자료 근거: ${s.source}',
                                    style: const TextStyle(fontSize: 12)),
                                Text(s.notes),
                                const SizedBox(height: 8),
                                TextField(
                                    key: const ValueKey('workflow-search'),
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.search),
                                        hintText:
                                            '품번 / Maker / 연도 / 담당자 / 상태 검색',
                                        isDense: true,
                                        border: OutlineInputBorder()),
                                    onChanged: (v) =>
                                        setState(() => query = v.trim())),
                                if (selected == 'vrb')
                                  action('같은 수주번호의 SL 검토완 도면 연결', () async {
                                    final why = await reason('검토완 도면 연결 사유');
                                    if (why != null) {
                                      final count =
                                          importPlatformReviewedDrawings(
                                              recordKey, why);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    '$count건 연결 · SL 요청서의 수주 참조번호가 일치해야 합니다.')));
                                      }
                                    }
                                  }),
                                if (selected == 'material') materialSummary(),
                                if (selected == 'inventory') stockSummary(),
                                if (selected == 'purchase') purchaseSummary(),
                                if (selected == 'approvals') approvalSummary(),
                                if (selected == 'closing') closingSummary(),
                                if (selected == 'shipment')
                                  Text(
                                      '출하 준비: ${shipmentIssues(recordKey).isEmpty ? '시안 체크 완료 (ERP 출하 미확정)' : shipmentIssues(recordKey).join(' / ')}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                if (selected == 'production')
                                  Text(
                                      '수량 현황: 활성 배포 ${data.rows('allocation').where((r) => r['state'] != '회수').fold<double>(0, (sum, r) => sum + workNumber(r['quantityQty'], '수량')).toStringAsFixed(0)} · '
                                      '제품 ${data.rows('product').length} · 작업 중 ${data.rows('product').where((r) => r['state'] == '작업 중').length} · 포장완료 ${data.rows('product').where((r) => r['state'] == '포장완료').length} · ERP 출하 미조회'),
                                for (final m in s.modules) module(m),
                              ]);
                        }),
                      ]))));
}

class _WorkRecordEditor extends StatefulWidget {
  final OrderWorkKey recordKey;
  final String module;
  final WorkRecord? record;
  const _WorkRecordEditor(
      {required this.recordKey, required this.module, this.record});
  @override
  State<_WorkRecordEditor> createState() => _WorkRecordEditorState();
}

class _WorkRecordEditorState extends State<_WorkRecordEditor> {
  late final fields = fieldsFor(widget.module);
  late final controls = {
    for (final f in fields)
      f.id: TextEditingController(
          text: widget.record?[f.id] ?? (f.choices.firstOrNull ?? ''))
  };
  final reason = TextEditingController();
  SelectedDesktopFile? file;
  bool picking = false;
  String error = '';
  List<WorkRecord> links(WorkField f) {
    final data = workflowFor(widget.recordKey);
    return switch (f.linkModule) {
      'price' => divisionPrices(widget.recordKey.$1),
      'verifiedDrawing' => data
          .rows('document')
          .where((r) => r['type'] == '도면' && r['verified'] == '검토완')
          .toList(),
      'poDocument' =>
        data.rows('document').where((r) => r['type'] == '발주서 PO').toList(),
      _ => data.records
          .where((r) =>
              (f.linkModule?.split('|') ?? []).contains(r.module) &&
              r.id != widget.record?.id)
          .toList(),
    };
  }

  @override
  void dispose() {
    for (final c in controls.values) {
      c.dispose();
    }
    reason.dispose();
    super.dispose();
  }

  Future<void> pick() async {
    setState(() => picking = true);
    try {
      final result = await DesktopFileService.pickReferenceDocument();
      if (mounted && result != null) setState(() => file = result);
    } catch (e) {
      if (mounted) setState(() => error = '파일 선택 실패: $e');
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
          title: Text(
              '${moduleTitles[widget.module]} ${widget.record == null ? '등록' : '수정'}'),
          content: SizedBox(
              width: 780,
              child: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text(
                        '시안 입력 · ERP 원천값을 변경하지 않습니다. * 필수 · 날짜 YYYY-MM-DD'),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                        builder: (_, c) =>
                            Wrap(spacing: 12, runSpacing: 14, children: [
                              for (final f in fields)
                                SizedBox(
                                    width: c.maxWidth < 620
                                        ? c.maxWidth
                                        : (c.maxWidth - 12) / 2,
                                    child: f.choices.isNotEmpty ||
                                            f.linkModule != null
                                        ? DropdownButtonFormField<String>(
                                            key: ValueKey('work-${f.id}'),
                                            isExpanded: true,
                                            initialValue: controls[f.id]!.text,
                                            decoration: InputDecoration(
                                                labelText: f.label,
                                                isDense: true,
                                                border:
                                                    const OutlineInputBorder()),
                                            items: f.choices.isNotEmpty
                                                ? [
                                                    for (final choice
                                                        in f.choices)
                                                      DropdownMenuItem(
                                                          value: choice,
                                                          child: Text(choice))
                                                  ]
                                                : [
                                                    const DropdownMenuItem(
                                                        value: '',
                                                        child:
                                                            Text('선택 / 미연결')),
                                                    for (final r in links(f))
                                                      DropdownMenuItem(
                                                          value: r.id,
                                                          child: Text(
                                                              '${r['title']} · ${r['revision'].isEmpty ? 'v${r.version}' : r['revision']} · ${r['part']} ${r['unitAmount']}'))
                                                  ],
                                            onChanged: (v) => setState(() =>
                                                controls[f.id]!.text = v ?? ''))
                                        : TextField(
                                            key: ValueKey('work-${f.id}'),
                                            controller: controls[f.id],
                                            decoration: InputDecoration(
                                                labelText: f.label,
                                                isDense: true,
                                                border:
                                                    const OutlineInputBorder()),
                                            maxLines: [
                                              'before',
                                              'after',
                                              'spec',
                                              'requiredFields',
                                              'actionResult',
                                              'issue'
                                            ].contains(f.id)
                                                ? 3
                                                : 1))
                            ])),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                        key: const ValueKey('work-attach'),
                        onPressed: picking ? null : pick,
                        icon: const Icon(Icons.attach_file),
                        label: Text(file?.name ??
                            widget.record?.file?.name ??
                            '참조 파일 선택 (문서·성적서 필수)')),
                    TextField(
                        key: const ValueKey('work-reason'),
                        controller: reason,
                        decoration:
                            const InputDecoration(labelText: '등록·변경 사유 *')),
                    if (error.isNotEmpty)
                      Text(error, style: const TextStyle(color: Colors.red)),
                  ]))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소')),
            FilledButton(
                key: const ValueKey('work-save'),
                onPressed: picking
                    ? null
                    : () {
                        try {
                          saveWorkRecord(
                              key: widget.recordKey,
                              module: widget.module,
                              values: {
                                for (final e in controls.entries)
                                  e.key: e.value.text
                              },
                              id: widget.record?.id,
                              expectedVersion: widget.record?.version,
                              file: file,
                              reason: reason.text);
                          Navigator.pop(context);
                        } catch (e) {
                          setState(() => error =
                              e.toString().replaceFirst('Bad state: ', ''));
                        }
                      },
                child: const Text('임시 저장'))
          ]);
}

class _ReasonDialog extends StatefulWidget {
  final String title;
  const _ReasonDialog({required this.title});
  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final text = TextEditingController();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
          title: Text(widget.title),
          content: SizedBox(
              width: 480,
              child: TextField(
                  key: const ValueKey('action-reason'),
                  controller: text,
                  autofocus: true)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소')),
            FilledButton(
                key: const ValueKey('action-confirm'),
                onPressed: () {
                  if (text.text.trim().isNotEmpty) {
                    Navigator.pop(context, text.text.trim());
                  }
                },
                child: const Text('확인'))
          ]);
}

class _ApprovalRequestDialog extends StatefulWidget {
  final OrderWorkKey recordKey;
  const _ApprovalRequestDialog({required this.recordKey});
  @override
  State<_ApprovalRequestDialog> createState() => _ApprovalRequestDialogState();
}

class _ApprovalRequestDialogState extends State<_ApprovalRequestDialog> {
  final ratio = TextEditingController(), reason = TextEditingController();
  String rule = '';
  bool special = false;
  String error = '';
  @override
  void dispose() {
    ratio.dispose();
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
          title: const Text('조건별 결재 요청 · 시연'),
          content: SizedBox(
              width: 540,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<String>(
                    initialValue: rule,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                          value: '', child: Text('시연 규칙 선택')),
                      for (final r
                          in workflowFor(widget.recordKey).rows('approvalRule'))
                        DropdownMenuItem(
                            value: r.id,
                            child: Text(
                                '${r['title']} ${r['minRate']}~${r['maxRate']}%'))
                    ],
                    onChanged: (v) => rule = v!),
                TextField(
                    controller: ratio,
                    decoration:
                        const InputDecoration(labelText: '연결 견적/산출 기준 재료비율 %')),
                CheckboxListTile(
                    title: const Text('특주'),
                    value: special,
                    onChanged: (v) => setState(() => special = v!)),
                TextField(
                    controller: reason,
                    decoration: const InputDecoration(labelText: '요청 사유 *')),
                if (error.isNotEmpty)
                  Text(error, style: const TextStyle(color: Colors.red)),
              ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소')),
            FilledButton(
                onPressed: () {
                  try {
                    requestOrderApproval(widget.recordKey,
                        ruleId: rule,
                        ratio: workNumber(ratio.text, '재료비율'),
                        special: special,
                        reason: reason.text);
                    Navigator.pop(context);
                  } catch (e) {
                    setState(() =>
                        error = e.toString().replaceFirst('Bad state: ', ''));
                  }
                },
                child: const Text('시연 상신'))
          ]);
}
