import 'package:flutter/material.dart';
import '../services/platform_pipeline_service.dart';
import '../services/desktop_file_service.dart';
import '../theme/robin_theme.dart';
import 'platform_assess_form.dart';
import 'robin_dialog.dart';
import 'user_profile.dart';
import 'platform_form_layout.dart';
import '../services/platform_quote_pdf_service.dart';
import 'platform_quote_preview.dart';

part 'platform_proposal_tables.dart';

class PlatformProposalForm extends StatefulWidget {
  final PlatformPipelineData data;
  final Future<bool> Function(int stage) onAdvance;
  final VoidCallback onDesignReview;
  final VoidCallback onSaved;
  const PlatformProposalForm(
      {super.key,
      required this.data,
      required this.onAdvance,
      required this.onDesignReview,
      required this.onSaved});
  @override
  State<PlatformProposalForm> createState() => _PlatformProposalFormState();
}

class _PlatformProposalFormState extends State<PlatformProposalForm> {
  PlatformPipelineData get data => widget.data;
  int tab = 0;
  int epoch = 0;
  String error = '';
  void refreshLayout() => setState(() {});
  void selectTab(int index) => setState(() => tab = index);
  void changed({bool vrb = true}) {
    final saved = data.vrbSaved;
    data.touchProposal();
    if (!vrb) data.vrbSaved = saved;
    setState(() {});
  }

  void run(VoidCallback action) {
    try {
      action();
      setState(() => error = '');
      widget.onSaved();
    } on StateError catch (e) {
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        buildProposalHeading(),
        buildProposalSummary(),
        buildProposalTabs(),
        if (tab == 0) vrb() else if (tab == 1) quote() else progress(),
        if (error.isNotEmpty)
          Padding(
              padding: const EdgeInsets.all(8),
              child: Text(error, style: const TextStyle(color: Colors.red))),
        if (tab < 2) buildProposalSaveBar(),
        if (data.revisions.isNotEmpty)
          ExpansionTile(
              title: Text('저장된 견적·VRB Rev ${data.revisions.length}건'),
              children: [
                for (final rev in data.revisions.reversed)
                  ListTile(
                      dense: true,
                      title: Text(
                          'Rev.${rev.revision} · ${rev.author} · ${rev.at.toString().substring(0, 16)}',
                          style: RobinTheme.bodySm),
                      subtitle: Text(
                          '견적 ${platformMoney((rev.data['result'] as Map)['revenue'] as num?)} · 재료비 ${platformMoney((rev.data['result'] as Map)['material'] as num?)}',
                          style: RobinTheme.labelXs),
                      trailing: TextButton(
                          onPressed: () => showSaved(rev),
                          child: const Text('저장본 보기'))),
              ]),
      ]);
  Widget vrb() => buildVrbTables();
  Widget mappedField(
          Map<String, String> fields, String id, String label, String key,
          {bool numeric = false, bool vrb = true, int lines = 1}) =>
      TextFormField(
          key: ValueKey('$key-$epoch'),
          initialValue: fields[id],
          maxLines: lines,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
              labelText: label,
              isDense: true,
              border: const OutlineInputBorder()),
          onChanged: (v) {
            fields[id] = v;
            changed(vrb: vrb);
          });
  Widget resultLine(String label, num? amount, {bool percent = false}) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Expanded(child: Text(label, style: RobinTheme.bodySm)),
            Text(percent ? platformPercent(amount) : platformMoney(amount),
                style: RobinTheme.headingSm)
          ]));
  Widget bidDifference() {
    final a = data.revenue, b = data.quoteKrw;
    if (a == null || b == null || (a - b).abs() < 1) {
      return const SizedBox.shrink();
    }
    return Text('VRB 제출가와 견적서 합계 차이 ${platformMoney(b - a)} · 일치 여부를 확인하세요.',
        style: const TextStyle(color: Colors.deepOrange, fontSize: 12));
  }

  Widget quote() => buildQuoteTable();
  Widget progress() => buildProgressLayout();
  void syncSingleQuote() {
    if (data.quoteLines.length != 1) return;
    final qty = platformNumber(data.quoteLines.first.fields['qty']),
        q = platformNumber(data.bid);
    final fx = data.quote['currency'] == 'KRW'
        ? 1.0
        : platformNumber(data.quote['fx']);
    if (qty != null && qty > 0 && q != null && fx != null && fx > 0) {
      data.quoteLines.first.fields['price'] = '${q / qty / fx}';
      epoch++;
    }
  }

  Widget attachment(String id, String label) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextButton(
            onPressed: () async {
              try {
                final f = await DesktopFileService.pickReferenceDocument(
                    extensions: const [
                      'pdf',
                      'xlsx',
                      'xlsm',
                      'xls',
                      'dwg',
                      'step',
                      'png',
                      'jpg'
                    ]);
                if (f != null && mounted) {
                  setState(() => data.files[id]!.add(f));
                }
              } catch (e) {
                if (mounted) setState(() => error = '$e');
              }
            },
            child: Text('$label 첨부')),
        for (final f in data.files[id]!)
          Row(children: [
            Expanded(
                child: TextButton(
                    onPressed: () async {
                      try {
                        await DesktopFileService.saveSelectedDocument(f);
                      } catch (e) {
                        if (mounted) setState(() => error = '$e');
                      }
                    },
                    child: Text(f.name))),
            IconButton(
                onPressed: () => setState(() => data.files[id]!.remove(f)),
                icon: const Icon(Icons.close, size: 16))
          ]),
      ]);
  Future<void> pasteMaterials() async {
    var text = '';
    final input = await showDialog<String>(
        context: context,
        builder: (context) => RobinAlertDialog(
                title: const Text('엑셀 재료비 붙여넣기 · 품목/단가/수량/비고'),
                content: SizedBox(
                    width: 620,
                    child: TextField(
                        maxLines: 8,
                        onChanged: (v) => text = v,
                        decoration: const InputDecoration(
                            hintText: 'HAND\t3500000\t2\t협력사 견적'))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, text),
                      child: const Text('추가'))
                ]));
    if (input == null || !mounted) return;
    final rows = <PlatformAmountLine>[];
    for (final raw in input.trim().split('\n')) {
      final c = raw.trim().split('\t');
      if (c.length < 3 ||
          c[0].isEmpty ||
          platformNumber(c[1]) == null ||
          platformNumber(c[2]) == null) {
        setState(() => error = '품목·단가·수량을 3열 이상으로 입력해주세요. 잘못된 행은 등록하지 않았습니다.');
        return;
      }
      rows.add(PlatformAmountLine(fields: {
        'name': c[0],
        'price': c[1],
        'qty': c[2],
        'note': c.length > 3 ? c[3] : ''
      }));
    }
    data.groups.add(PlatformMaterialGroup('엑셀 입력', rows));
    changed();
  }

  Future<void> importPast() async {
    final sources = platformPipelineRecords.values
        .where((d) => d.key != data.key && d.revisions.isNotEmpty)
        .toList();
    final source = await showDialog<PlatformPipelineData>(
        context: context,
        builder: (context) => RobinSimpleDialog(
                title: const Text('과거 VRB 불러오기 · 저장본'),
                children: [
                  if (sources.isEmpty)
                    const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('다른 프로젝트의 저장된 견적·VRB Rev가 없습니다.')),
                  for (final source in sources)
                    SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, source),
                        child: Text(
                            '${source.key.$2} · ${source.projectName} · Rev.${source.revisions.last.revision}')),
                ]));
    if (source == null || !mounted) return;
    // Explicit import copies numeric cost inputs; customer/identity and approvals are retained.
    final r = source.revisions.last.data;
    data.groups
      ..clear()
      ..addAll((r['groups'] as List).map((g) => PlatformMaterialGroup(
          g['name'] as String,
          (g['rows'] as List)
              .map((l) => PlatformAmountLine(
                  fields: Map<String, String>.from(l as Map)))
              .toList())));
    data.rates
      ..clear()
      ..addAll(Map<String, String>.from(r['rates'] as Map));
    for (final e in (r['costs'] as Map).entries) {
      data.costs[e.key]!.fields
        ..clear()
        ..addAll(Map<String, String>.from(e.value as Map));
    }
    data.rateReference = r['rateReference'] as String;
    data.reserve = r['reserve'] as bool;
    data.reserveRate = r['reserveRate'] as String;
    data.importSource =
        '${source.key.$2} Rev.${source.revisions.last.revision}';
    epoch++;
    changed();
    setState(() => error =
        '${data.importSource} 재료비·비용·요율을 가져왔습니다. 현재 제품류와 요율 근거를 확인하세요.');
  }

  void previewQuote() =>
      PlatformQuotePreview.open(context, PlatformQuoteDocument.current(data));

  Future<void> printQuote() async {
    try {
      await PlatformQuotePreview.printDocument(
          PlatformQuoteDocument.current(data));
    } catch (e) {
      if (mounted) setState(() => error = '견적서 인쇄 실패: $e');
    }
  }

  void showSaved(PlatformProposalRevision rev) => showDialog<void>(
      context: context,
      builder: (context) => RobinAlertDialog(
              title: Text('Rev.${rev.revision} 저장본'),
              content: SizedBox(
                  width: 680,
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            '과제 유형: ${rev.data['type']} · ${rev.data['domestic']}'),
                        for (final group in rev.data['groups'] as List) ...[
                          const Divider(),
                          Text(group['name'] as String,
                              style: RobinTheme.headingSm),
                          for (final line in group['rows'] as List)
                            Text(
                                '${line['name']} · 단가 ${line['price']}원 × 수량 ${line['qty']} · ${line['note']}'),
                        ],
                        const Divider(),
                        for (final e in platformVrbCostLabels.entries)
                          Text(
                              '${e.value}: ${(rev.data['costs'] as Map)[e.key]['price']}원 × ${(rev.data['costs'] as Map)[e.key]['qty']}'),
                        for (final e in platformVrbRateLabels.entries)
                          Text(
                              '${e.value}: ${(rev.data['rates'] as Map)[e.key] ?? '미입력'}%'),
                        const Divider(),
                        for (final e in platformQuoteLabels.entries)
                          Text(
                              '${e.value}: ${(rev.data['quote'] as Map)[e.key] ?? ''}'),
                        Text(
                            '영업이익: ${platformMoney((rev.data['result'] as Map)['op'] as num?)}'),
                      ]))),
              actions: [
                OutlinedButton(
                    onPressed: () => PlatformQuotePreview.open(
                        context, PlatformQuoteDocument.saved(rev, data.key.$2)),
                    child: const Text('견적서 미리보기·출력')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'))
              ]));
}

String platformMoney(num? value) => value == null
    ? '미산출'
    : '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';
String platformPercent(num? value) =>
    value == null ? '미산출' : '${value.toStringAsFixed(1)}%';
