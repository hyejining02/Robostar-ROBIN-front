part of 'platform_proposal_form.dart';

extension _PlatformProgressLayout on _PlatformProposalFormState {
  Widget buildProgressLayout() => platformCard('진행 체크', [
        stepRow('VRB 재료비', data.vrbSaved),
        stepRow('견적서·Rev 저장', data.quoteSaved,
            detail: data.quoteSaved ? '최신 견적 저장됨' : '견적서를 저장해주세요.'),
        stepRow('Proposal 승인', data.approval == '승인',
            detail: '결재 상태: ${data.approval}',
            action: Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                      width: 150,
                      child: TextFormField(
                          initialValue: data.floor,
                          enabled:
                              data.approval == '작성중' || data.approval == '반려',
                          decoration: const InputDecoration(
                              labelText: '방어선 (%)',
                              isDense: true,
                              border: OutlineInputBorder()),
                          onChanged: (v) => data.floor = v)),
                  OutlinedButton(
                      onPressed: () => run(() {
                            if (!data.vrbSaved ||
                                !data.quoteSaved ||
                                data.result['opRatio'] == null) {
                              throw StateError(
                                  'VRB·견적서를 저장하고 모든 비용·요율을 입력해주세요.');
                            }
                            final floor = double.tryParse(data.floor);
                            if (floor == null ||
                                !floor.isFinite ||
                                floor > data.result['opRatio']!) {
                              throw StateError('현재 영업이익률 이하의 방어선을 입력해주세요.');
                            }
                            data.approval = '승인 대기';
                          }),
                      child: const Text('승인 요청')),
                  if (robinUserProfile.value.isAdmin) ...[
                    TextButton(
                        onPressed: data.approval != '승인 대기'
                            ? null
                            : () {
                                data.approval = '승인';
                                refreshLayout();
                              },
                        child: const Text('관리자 시연 승인')),
                    TextButton(
                        onPressed: data.approval != '승인 대기'
                            ? null
                            : () {
                                data.approval = '반려';
                                refreshLayout();
                              },
                        child: const Text('관리자 시연 반려')),
                  ],
                ])),
        stepRow('고객 제출', data.submittedDate.isNotEmpty,
            detail: '제출일 기준으로 유효기간을 확인하세요.',
            action: Wrap(
                spacing: 8,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Checkbox(
                        value: data.submittedDate.isNotEmpty,
                        onChanged: data.approval != '승인'
                            ? null
                            : (v) {
                                data.submittedDate = v!
                                    ? DateTime.now()
                                        .toIso8601String()
                                        .substring(0, 10)
                                    : '';
                                refreshLayout();
                              }),
                    const Text('제출함')
                  ]),
                  if (data.submittedDate.isNotEmpty)
                    SizedBox(
                        width: 165,
                        child: TextFormField(
                            initialValue: data.submittedDate,
                            decoration: const InputDecoration(
                                labelText: '제출일 YYYY-MM-DD',
                                isDense: true,
                                border: OutlineInputBorder()),
                            onChanged: (v) => data.submittedDate = v)),
                ])),
        const SizedBox(height: 12),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: RobinTheme.background,
                border: Border.all(color: RobinTheme.border),
                borderRadius: BorderRadius.circular(8)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('고객 회신 → Negotiation', style: RobinTheme.headingSm),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [
                for (final value in ['금액 승인', '금액 협의', '사양 협의'])
                  ChoiceChip(
                      label: Text(value),
                      selected: data.reply == value,
                      onSelected: (_) {
                        data.reply = value;
                        refreshLayout();
                      })
              ]),
              const SizedBox(height: 8),
              TextFormField(
                  initialValue: data.replyMemo,
                  decoration: const InputDecoration(
                      labelText: '회신 메모',
                      isDense: true,
                      border: OutlineInputBorder()),
                  onChanged: (v) => data.replyMemo = v),
              const SizedBox(height: 8),
              Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                      key: const ValueKey('platform-proposal-to-negotiation'),
                      onPressed: !data.readyToNegotiate
                          ? null
                          : () => widget.onAdvance(2),
                      child: const Text('회신 등록 → Negotiation'))),
            ])),
        const SizedBox(height: 8),
        Text('결재는 관리자 계정으로 흐름을 확인하는 세션 시연입니다. 실제 결재 시스템·고객 전송은 미연동입니다.',
            style: RobinTheme.labelXs),
      ]);
  Widget stepRow(String title, bool complete,
          {String? detail, Widget? action}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: RobinTheme.border))),
        child: LayoutBuilder(builder: (context, c) {
          final label = Row(children: [
            Icon(complete ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20, color: complete ? Colors.green : Colors.grey),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title, style: RobinTheme.headingSm),
                  if (detail != null) Text(detail, style: RobinTheme.labelXs)
                ]))
          ]);
          if (action == null) return label;
          return c.maxWidth < 680
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [label, const SizedBox(height: 8), action])
              : Row(children: [
                  Expanded(child: label),
                  const SizedBox(width: 12),
                  SizedBox(width: c.maxWidth * .62, child: action)
                ]);
        }),
      );
}

extension _PlatformProposalTables on _PlatformProposalFormState {
  Widget buildProposalHeading() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            color: RobinTheme.background,
            border: Border.all(color: RobinTheme.border),
            borderRadius: BorderRadius.circular(8)),
        child: LayoutBuilder(builder: (context, c) {
          final info = Wrap(
              spacing: 16,
              runSpacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(data.projectName, style: RobinTheme.headingSm),
                Text(
                    data.equipment.entries
                        .where((e) => e.value > 0)
                        .map((e) => '${e.key} ${e.value}대')
                        .join(' · '),
                    style: RobinTheme.bodySm),
                if (data.materials.isNotEmpty)
                  Text(data.materials.join(' · '), style: RobinTheme.bodySm),
              ]);
          final review = OutlinedButton.icon(
              onPressed: widget.onDesignReview,
              icon: const Icon(Icons.architecture, size: 16),
              label: const Text('설계 검토 의뢰 · 회신 확인'));
          return c.maxWidth < 620
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [info, const SizedBox(height: 6), review])
              : Row(children: [
                  Expanded(child: info),
                  const SizedBox(width: 12),
                  review
                ]);
        }),
      );
  Widget buildProposalSummary() => LayoutBuilder(builder: (context, c) {
        final entries = const {
          'revenue': '견적가',
          'material': '재료비',
          'materialRatio': '재료비율',
          'marginRatio': '한계이익률',
          'opRatio': '영업이익률'
        }.entries;
        final columns = c.maxWidth < 540
            ? 2
            : c.maxWidth < 850
                ? 3
                : 5;
        return Container(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: RobinTheme.border),
                borderRadius: BorderRadius.circular(8)),
            child: Wrap(children: [
              for (final e in entries)
                Container(
                    width: (c.maxWidth - 2) / columns,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                color: RobinTheme.border, width: .6))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value, style: RobinTheme.labelXs),
                          const SizedBox(height: 3),
                          Text(
                              e.key.endsWith('Ratio')
                                  ? platformPercent(data.result[e.key])
                                  : platformMoney(data.result[e.key]),
                              style: RobinTheme.headingSm),
                        ]))
            ]));
      });
  Widget buildProposalTabs() => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: RobinTheme.border, width: 2))),
        child: LayoutBuilder(builder: (context, c) {
          final tabs = Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < 3; i++)
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: tab == i
                                ? RobinTheme.primary
                                : Colors.transparent,
                            width: 2))),
                child: TextButton(
                    key: ValueKey('platform-proposal-tab-$i'),
                    onPressed: () => selectTab(i),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        foregroundColor: tab == i
                            ? RobinTheme.primary
                            : RobinTheme.textSecondary),
                    child: Text(['① VRB', '② 견적서', '③ 진행 체크'][i])),
              )
          ]);
          final past = TextButton.icon(
              onPressed: importPast,
              icon: const Icon(Icons.history, size: 16),
              label: const Text('과거 VRB 불러오기'));
          return c.maxWidth < 580
              ? Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [tabs, past])
              : Row(children: [tabs, const Spacer(), past]);
        }),
      );
  Widget buildProposalSaveBar() => platformActionBar(
        status: Text(
            tab == 0
                ? (data.vrbSaved ? 'VRB 저장됨' : 'VRB 입력 후 견적서로 진행하세요.')
                : '견적 조건과 합계를 확인한 뒤 저장하세요.',
            style: RobinTheme.labelXs),
        actions: FilledButton(
            key: ValueKey('platform-proposal-save-$tab'),
            onPressed: () => run(() {
                  if (tab == 0) {
                    data.saveVrb(robinUserProfile.value.name);
                    tab = 1;
                  } else {
                    data.saveQuote(robinUserProfile.value.name);
                    tab = 2;
                  }
                }),
            child: Text(tab == 0 ? 'VRB 저장 → ② 견적서' : '견적서 저장 → ③ 진행 체크')),
      );

  Widget tableField(Map<String, String> fields, String id, String key,
          {bool vrb = true,
          bool enabled = true,
          int lines = 1,
          bool multiline = false,
          String? hint}) =>
      TextFormField(
        key: ValueKey('$key-$epoch'),
        initialValue: fields[id],
        enabled: enabled,
        minLines: multiline ? 1 : null,
        maxLines: multiline ? null : lines,
        textInputAction: multiline ? TextInputAction.newline : null,
        keyboardType:
            ['price', 'qty', 'fx'].contains(id) || identical(fields, data.rates)
                ? TextInputType.number
                : multiline
                    ? TextInputType.multiline
                    : TextInputType.text,
        style: RobinTheme.bodySm,
        decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: RobinTheme.border))),
        onChanged: (v) {
          fields[id] = v;
          changed(vrb: vrb);
        },
      );
  TableRow tableRow(List<Widget> cells, {bool total = false, LocalKey? key}) =>
      TableRow(
          key: key,
          decoration:
              total ? const BoxDecoration(color: RobinTheme.background) : null,
          children: cells);
  Widget emptyCell() => platformTableText('');
  String quoteNumber(num? value) => value == null
      ? '미산출'
      : value.toStringAsFixed(value % 1 == 0 ? 0 : 2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  Widget amountCell(num? amount, {bool strong = false}) =>
      platformTableText(platformMoney(amount), right: true, strong: strong);
  Widget ratioCell(num? amount) => platformTableText(
      data.revenue == null || data.revenue! <= 0 || amount == null
          ? '—'
          : platformPercent(amount / data.revenue! * 100),
      right: true);
  double? rateAmount(String key) {
    final rate = platformNumber(data.rates[key]), q = data.revenue;
    return rate == null || q == null ? null : q * rate / 100;
  }

  Widget buildVrbTables() => Column(children: [
        platformCard('VRB 수익성', [
          platformInlineFields([
            DropdownButtonFormField<String>(
                initialValue: data.projectType,
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: '과제 유형',
                    isDense: true,
                    border: OutlineInputBorder()),
                items: platformProjectTypes
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) {
                  data.projectType = v!;
                  changed();
                }),
            DropdownButtonFormField<String>(
                initialValue: data.domestic,
                decoration: const InputDecoration(
                    labelText: '내수/수출',
                    isDense: true,
                    border: OutlineInputBorder()),
                items: ['내수', '수출']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) {
                  data.domestic = v!;
                  changed();
                }),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text('직접재료비', style: RobinTheme.headingSm)),
            TextButton(onPressed: pasteMaterials, child: const Text('엑셀 붙여넣기')),
            TextButton(
                onPressed: () {
                  data.groups.add(
                      PlatformMaterialGroup('새 그룹', [PlatformAmountLine()]));
                  changed();
                },
                child: const Text('+ 그룹 추가'))
          ]),
          materialTable(),
          const SizedBox(height: 16),
          Text('비용 · 수익성', style: RobinTheme.headingSm),
          const SizedBox(height: 6),
          costsTable(),
          const SizedBox(height: 10),
          TextFormField(
              key: ValueKey('platform-rate-reference-${data.key.$2}'),
              initialValue: data.rateReference,
              onChanged: (v) {
                data.rateReference = v;
                changed();
              },
              decoration: const InputDecoration(
                  labelText: '적용 요율 근거·버전',
                  isDense: true,
                  border: OutlineInputBorder())),
          const SizedBox(height: 6),
          Text('단가·금액: 원 · 공수: MD · 요율: %. 미입력 비용·요율은 미산출로 표시합니다.',
              style: RobinTheme.labelXs),
          bidDifference(),
        ]),
        platformCard('Layout · 재료비 근거 (선택)', [
          platformInlineFields([
            for (final e in {'layout': 'Layout', 'material': '재료비 근거'}.entries)
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      border: Border.all(color: RobinTheme.border),
                      borderRadius: BorderRadius.circular(6)),
                  child: attachment(e.key, e.value))
          ]),
        ]),
      ]);

  Widget materialTable() => platformTable(
      key: const ValueKey('platform-material-table'),
      headers: const ['품목', '단가 (원)', '수량', '금액 (원)', '비고', ''],
      widths: const [2.3, 1.4, .8, 1.4, 2.3, .4],
      minWidth: 760,
      rows: [
        for (var g = 0; g < data.groups.length; g++) ...[
          tableRow([
            platformTableCell(TextFormField(
                key: ValueKey('platform-group-$g-$epoch-${data.key.$2}'),
                initialValue: data.groups[g].name,
                style: RobinTheme.bodySm,
                decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(7),
                    hintText: '그룹명'),
                onChanged: (v) {
                  data.groups[g].name = v;
                  changed();
                })),
            platformTableCell(TextButton(
                onPressed: () {
                  data.groups[g].rows.add(PlatformAmountLine());
                  changed();
                },
                child: const Text('+ 행'))),
            emptyCell(),
            amountCell(_groupTotal(data.groups[g]), strong: true),
            emptyCell(),
            platformTableCell(IconButton(
                tooltip: '그룹 삭제',
                onPressed: data.groups.length <= 1
                    ? null
                    : () {
                        data.groups.removeAt(g);
                        epoch++;
                        changed();
                      },
                icon: const Icon(Icons.close, size: 15))),
          ], total: true),
          for (final line in data.groups[g].rows)
            tableRow([
              platformTableCell(tableField(
                  line.fields, 'name', 'platform-line-${line.id}-name',
                  hint: '품목')),
              platformTableCell(tableField(
                  line.fields, 'price', 'platform-line-${line.id}-price',
                  hint: '단가')),
              platformTableCell(tableField(
                  line.fields, 'qty', 'platform-line-${line.id}-qty',
                  hint: '수량')),
              amountCell(line.amount),
              platformTableCell(tableField(
                  line.fields, 'note', 'platform-line-${line.id}-note',
                  hint: '비고')),
              platformTableCell(IconButton(
                  tooltip: '행 삭제',
                  onPressed: data.groups[g].rows.length <= 1
                      ? null
                      : () {
                          data.groups[g].rows.remove(line);
                          changed();
                        },
                  icon: const Icon(Icons.close, size: 15))),
            ], key: ValueKey(line.id)),
        ],
        tableRow([
          platformTableText('직접재료비 합계', strong: true),
          emptyCell(),
          emptyCell(),
          amountCell(data.materialTotal, strong: true),
          emptyCell(),
          emptyCell()
        ], total: true)
      ]);
  double? _groupTotal(PlatformMaterialGroup group) {
    var total = 0.0;
    for (final r in group.rows) {
      if (r.amount == null) return null;
      total += r.amount!;
    }
    return total;
  }

  Widget costsTable() {
    final full = data.projectType == platformProjectTypes.first;
    TableRow summary(String group, String key) => tableRow([
          platformTableText(group, strong: true),
          emptyCell(),
          emptyCell(),
          emptyCell(),
          amountCell(data.result[key], strong: true),
          ratioCell(data.result[key]),
          emptyCell()
        ], total: true);
    TableRow cost(String category, String id, {bool enabled = true}) {
      final line = data.costs[id]!,
          amount = enabled ? data.costs[id]!.amount : 0.0;
      return tableRow([
        platformTableText(category),
        platformTableText(platformVrbCostLabels[id]!),
        platformTableCell(tableField(
            line.fields, 'price', 'platform-cost-$id-price-${data.key.$2}',
            enabled: enabled)),
        platformTableCell(tableField(
            line.fields, 'qty', 'platform-cost-$id-qty-${data.key.$2}',
            enabled: enabled)),
        amountCell(amount),
        ratioCell(amount),
        platformTableCell(tableField(
            line.fields, 'note', 'platform-cost-$id-note-${data.key.$2}',
            enabled: enabled, hint: enabled ? '비고' : '계산 제외')),
      ]);
    }

    TableRow rate(String category, String id, {bool enabled = true}) =>
        tableRow([
          platformTableText(category),
          platformTableText(platformVrbRateLabels[id]!),
          emptyCell(),
          emptyCell(),
          amountCell(enabled ? rateAmount(id) : 0),
          platformTableCell(tableField(
              data.rates, id, 'platform-rate-$id-${data.key.$2}',
              enabled: enabled, hint: '%')),
          platformTableText(enabled ? '견적금액 × 비율' : '해당 과제 유형 제외'),
        ]);
    return platformTable(
        key: const ValueKey('platform-vrb-cost-table'),
        headers: const [
          '구분',
          '항목',
          '단가 (원)',
          '수량/MD',
          '금액 (원)',
          '비율 (%)',
          '비고'
        ],
        widths: const [1.4, 2.2, 1.3, .8, 1.5, .9, 2],
        minWidth: 920,
        rows: [
          tableRow([
            platformTableText('견적금액', strong: true),
            platformTableText('제출 견적가 (총액)'),
            emptyCell(),
            emptyCell(),
            platformTableCell(TextFormField(
                key: ValueKey('platform-vrb-bid-${data.key.$2}'),
                initialValue: data.bid,
                keyboardType: TextInputType.number,
                style: RobinTheme.bodySm,
                decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(7),
                    hintText: '원'),
                onChanged: (v) {
                  data.bid = v;
                  syncSingleQuote();
                  changed();
                })),
            ratioCell(data.revenue),
            emptyCell()
          ], total: true),
          summary('직접재료비', 'material'),
          cost('직접제조경비', 'outside', enabled: full),
          rate('', 'consumables', enabled: full),
          cost('', 'mfgTravel', enabled: full),
          summary('제조경비 소계', 'manufacturing'),
          cost('직접판매경비', 'export'),
          rate('', 'warranty'),
          cost('', 'salesTravel'),
          rate('', 'agent'),
          summary('판매경비 소계', 'selling'),
          tableRow([
            platformTableText('예비비'),
            platformTableCell(Row(children: [
              SizedBox(
                  width: 24,
                  height: 28,
                  child: Checkbox(
                      value: data.reserve,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (v) {
                        data.reserve = v!;
                        changed();
                      })),
              const SizedBox(width: 4),
              Expanded(child: Text('초도개발', style: RobinTheme.bodySm))
            ])),
            emptyCell(),
            emptyCell(),
            amountCell(data.result['reserve']),
            platformTableCell(TextFormField(
                key: ValueKey('platform-reserve-${data.key.$2}'),
                initialValue: data.reserveRate,
                keyboardType: TextInputType.number,
                enabled: data.reserve,
                style: RobinTheme.bodySm,
                decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(7)),
                onChanged: (v) {
                  data.reserveRate = v;
                  changed();
                })),
            platformTableText('견적금액 × 비율 (기본 3%)')
          ]),
          summary('총 변동비', 'variable'),
          summary('한계이익', 'margin'),
          cost('직접제조인건비', 'design', enabled: full),
          cost('', 'make', enabled: full),
          cost('', 'setup', enabled: full),
          rate('공통제조인건비', 'commonMfg', enabled: full),
          rate('고정성 제조경비', 'fixedMfg', enabled: full),
          rate('공통 판관비', 'sga'),
          summary('총 고정비', 'fixed'),
          summary('영업이익', 'op'),
        ]);
  }

  Widget buildQuoteTable() => platformCard('', [
        Row(children: [
          Expanded(child: Text('견적서', style: RobinTheme.headingSm)),
          Wrap(spacing: 8, children: [
            OutlinedButton(onPressed: previewQuote, child: const Text('미리보기')),
            OutlinedButton.icon(
                onPressed: printQuote,
                icon: const Icon(Icons.print, size: 16),
                label: const Text('인쇄·PDF')),
          ])
        ]),
        const SizedBox(height: 10),
        platformInlineFields([
          mappedField(data.quote, 'equipment', '장비명 *',
              'platform-quote-equipment-${data.key.$2}',
              vrb: false),
          DropdownButtonFormField<String>(
              initialValue: data.quote['currency'],
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: '통화', isDense: true, border: OutlineInputBorder()),
              items: ['KRW', 'USD', 'JPY', 'EUR', 'CNY']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) {
                data.quote['currency'] = v!;
                if (v == 'KRW') data.quote['fx'] = '1';
                changed(vrb: false);
              }),
          if (data.quote['currency'] != 'KRW')
            mappedField(data.quote, 'fx', '환율 (원/${data.quote['currency']})',
                'platform-quote-fx-${data.key.$2}',
                vrb: false, numeric: true),
        ], columns: data.quote['currency'] == 'KRW' ? 2 : 3),
        const SizedBox(height: 12),
        platformTable(
            key: const ValueKey('platform-quote-table'),
            headers: [
              'No',
              '품명',
              '규격·사양',
              '단위',
              '수량',
              '단가 (${data.quote['currency']})',
              '금액 (${data.quote['currency']})',
              ''
            ],
            widths: const [.4, 1.8, 2.5, .6, .8, 1.4, 1.4, .4],
            minWidth: 920,
            rows: [
              for (var i = 0; i < data.quoteLines.length; i++)
                tableRow([
                  platformTableText('${i + 1}'),
                  for (final id in ['name', 'spec', 'unit', 'qty', 'price'])
                    platformTableCell(tableField(data.quoteLines[i].fields, id,
                        'platform-line-${data.quoteLines[i].id}-$id',
                        vrb: false, multiline: id == 'spec')),
                  platformTableText(quoteNumber(data.quoteLines[i].amount),
                      right: true),
                  platformTableCell(IconButton(
                      tooltip: '견적 품목 삭제',
                      onPressed: data.quoteLines.length <= 1
                          ? null
                          : () {
                              data.quoteLines.removeAt(i);
                              changed(vrb: false);
                            },
                      icon: const Icon(Icons.close, size: 15))),
                ], key: ValueKey(data.quoteLines[i].id)),
              tableRow([
                emptyCell(),
                platformTableCell(TextButton(
                    onPressed: () {
                      data.quoteLines.add(PlatformAmountLine());
                      changed(vrb: false);
                    },
                    child: const Text('+ 품목 추가'))),
                emptyCell(),
                emptyCell(),
                platformTableText(
                    quoteNumber(data.quoteLines.fold<double>(0,
                        (n, l) => n + (platformNumber(l.fields['qty']) ?? 0))),
                    right: true),
                platformTableText('합계 · VAT 별도', strong: true),
                platformTableText(quoteNumber(data.quoteTotal),
                    right: true, strong: true),
                emptyCell()
              ], total: true),
            ]),
        resultLine('원화 환산 합계', data.quoteKrw),
        bidDifference(),
        ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('견적 조건', style: RobinTheme.headingSm),
            subtitle: Text(
                '${data.quote['number'] ?? '견적 No. 미입력'} · ${data.quote['date'] ?? ''} · 유효 ${data.quote['validDays'] ?? ''}일',
                style: RobinTheme.labelXs),
            children: [
              platformInlineFields([
                for (final e in platformQuoteLabels.entries
                    .where((e) => !['equipment', 'notes'].contains(e.key)))
                  mappedField(data.quote, e.key, e.value,
                      'platform-quote-${e.key}-${data.key.$2}',
                      vrb: false)
              ], columns: 3),
              const SizedBox(height: 10),
              mappedField(data.quote, 'notes', '특기사항',
                  'platform-quote-notes-${data.key.$2}',
                  vrb: false, lines: 3)
            ]),
      ]);
}
