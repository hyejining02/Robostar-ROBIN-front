import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/product_identity_service.dart';
import '../services/robot_proposal_catalog.dart';
import '../services/robot_proposal_service.dart';
import '../theme/robin_theme.dart';

class RobotMaterialSimulator extends StatefulWidget {
  final RobotProposalPart part;
  final VoidCallback onChanged;
  const RobotMaterialSimulator(
      {super.key, required this.part, required this.onChanged});
  @override
  State<RobotMaterialSimulator> createState() => _RobotMaterialSimulatorState();
}

class _RobotMaterialSimulatorState extends State<RobotMaterialSimulator> {
  String category = '전체';
  String search = '';
  RobotProposalPart get part => widget.part;
  void change(VoidCallback update) {
    setState(update);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final cost = part.cost;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: RobinTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('예상 재료비 시뮬레이터', style: RobinTheme.headingSm),
              const Chip(label: Text('DEMO 단가 · ERP 미연동')),
              OutlinedButton.icon(
                  key: const ValueKey('robot-cost-import-spec'),
                  onPressed: importSpecification,
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('적용 사양에서 계산 기준 불러오기')),
            ]),
        const SizedBox(height: 8),
        Text('계산 기준', style: RobinTheme.headingSm),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, c) {
          final columns = c.maxWidth < 500 ? 2 : 3;
          return Wrap(spacing: 8, runSpacing: 8, children: [
            for (final field in robotDemoMaster.entries)
              SizedBox(
                  width: (c.maxWidth - 8 * (columns - 1)) / columns,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('robot-cost-${part.id}-${field.key}'),
                    initialValue: part.costInputs[field.key],
                    isExpanded: true,
                    decoration: InputDecoration(
                        labelText: const {
                          'model': '모델',
                          'base': 'BASE 규격',
                          'axis': 'AXIS',
                          'type': '구동 타입',
                          'stroke': 'STROKE',
                          'drive': '구동방식',
                          'lead': 'B/S Lead',
                          'motorMaker': '모터 Maker·Series',
                          'motorCap': '모터 용량'
                        }[field.key],
                        border: const OutlineInputBorder(),
                        isDense: true),
                    items: field.value.keys
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged:
                        field.key == 'lead' && part.costInputs['type'] == 'BELT'
                            ? null
                            : (v) => change(() {
                                  part.costInputs[field.key] = v!;
                                  if (field.key == 'type') {
                                    part.costOptions.removeWhere((name, _) =>
                                        robotDemoOptions.any((o) =>
                                            o['name'] == name &&
                                            o['only'] != null &&
                                            o['only'] != v));
                                  }
                                }),
                  )),
          ]);
        }),
        const SizedBox(height: 10),
        Text('시연용 계산 기준입니다. 사양에서 일치하는 값만 불러오며, 없는 규격·단가는 추정하지 않습니다.',
            style: RobinTheme.labelXs),
        const Divider(height: 24),
        Wrap(spacing: 6, runSpacing: 6, children: [
          Text('고객사 옵션 프리셋', style: RobinTheme.bodySm),
          for (final preset in robotDemoPresets.keys)
            OutlinedButton(
                onPressed: () => applyPreset(preset), child: Text(preset)),
        ]),
        const SizedBox(height: 8),
        TextField(
            key: const ValueKey('robot-cost-option-search'),
            onChanged: (v) => setState(() => search = v),
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, size: 17),
                hintText: '옵션명·설명 검색',
                border: OutlineInputBorder(),
                isDense: true)),
        const SizedBox(height: 6),
        Wrap(spacing: 5, runSpacing: 4, children: [
          for (final cat in [
            '전체',
            ...robotDemoOptions.map((o) => o['cat'] as String).toSet()
          ])
            ChoiceChip(
                label: Text(cat),
                selected: category == cat,
                onSelected: (_) => setState(() => category = cat)),
        ]),
        const SizedBox(height: 6),
        SizedBox(
            height: 270,
            child: Scrollbar(
                child: ListView(children: [
              for (final option in robotDemoOptions)
                if ((category == '전체' || option['cat'] == category) &&
                    '${option['name']} ${option['detail']}'
                        .toLowerCase()
                        .contains(search.toLowerCase()))
                  optionRow(option),
            ]))),
        const Divider(height: 20),
        LayoutBuilder(builder: (context, c) {
          final results = [
            result('최종 예상 재료비', cost?.total, true),
            result('기본 사양 기준', cost?.base, false),
            result('옵션 보정액', cost?.options, false),
          ];
          return c.maxWidth < 440
              ? Column(children: results)
              : Row(children: [
                  for (final item in results) Expanded(child: item)
                ]);
        }),
        const SizedBox(height: 8),
        if (cost == null)
          Text('계산 기준을 모두 선택하면 예상 금액을 표시합니다. BELT는 B/S Lead를 사용하지 않습니다.',
              style: RobinTheme.bodySm)
        else ...[
          ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('기본 사양 산출 내역', style: RobinTheme.headingSm),
              children: [
                for (final line in cost.baseLines.entries)
                  lineRow(line.key, line.value)
              ]),
          Text('선택 옵션 ${cost.optionLines.length}건',
              style: RobinTheme.headingSm),
          for (final line in cost.optionLines.entries)
            lineRow(line.key, line.value),
          const SizedBox(height: 8),
          Text(
              '구성품 수량 ${part.quantity}개 · 합계 ${robotMoney(cost.total * part.quantity)}',
              style: RobinTheme.headingSm),
        ],
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          OutlinedButton(
              onPressed: () => change(() => part.costOptions.clear()),
              child: const Text('재료비 옵션 초기화')),
          OutlinedButton.icon(
              onPressed: cost == null
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(
                          text: '[ROBIN 예상 재료비 · DEMO]\n${part.name}\n'
                              '기본 ${robotMoney(cost.base)}\n옵션 ${robotMoney(cost.options)}\n'
                              '단위 재료비 ${robotMoney(cost.total)}\n수량 ${part.quantity} · 합계 ${robotMoney(cost.total * part.quantity)}\n'
                              '${cost.optionLines.entries.map((e) => '${e.key}: ${robotMoney(e.value)}').join('\n')}\n시연용 단가 · ERP 미연동'));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('재료비 요약을 복사했습니다.')));
                      }
                    },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('결과 요약 복사')),
        ]),
      ]),
    );
  }

  Widget result(String title, int? value, bool primary) => Container(
        width: double.infinity,
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: primary
                ? RobinTheme.primary.withValues(alpha: .06)
                : RobinTheme.background,
            borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: RobinTheme.labelXs),
          const SizedBox(height: 4),
          Text(value == null ? '계산 기준 미선택' : robotMoney(value),
              style: primary ? RobinTheme.headingSm : RobinTheme.bodySm),
        ]),
      );

  Widget lineRow(String title, int value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(title, style: RobinTheme.bodySm)),
        const SizedBox(width: 8),
        Text(robotMoney(value), style: RobinTheme.bodySm)
      ]));

  Widget optionRow(Map<String, dynamic> option) {
    final name = option['name'] as String;
    final selection = part.costOptions[name];
    final available =
        option['only'] == null || option['only'] == part.costInputs['type'];
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Checkbox(
              value: selection != null,
              onChanged: !available
                  ? null
                  : (on) => change(() {
                        if (on!) {
                          part.costOptions[name] = RobotCostOption(
                              choice: option['control'] == 'select'
                                  ? (option['choices'] as List).first[0]
                                      as String
                                  : null);
                        } else {
                          part.costOptions.remove(name);
                        }
                      })),
          Expanded(child: Text(name, style: RobinTheme.bodySm)),
          if (!available)
            Text('${option['only']} 전용', style: RobinTheme.labelXs),
          if (option['infoOnly'] == true)
            Text('기본 사양 반영', style: RobinTheme.labelXs),
        ]),
        Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text('${option['detail']} · ${option['form']}',
                style: RobinTheme.labelXs)),
        if (option['control'] == 'select')
          Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: DropdownButtonFormField<String>(
                key: ValueKey('${part.id}-$name-${selection?.choice}'),
                initialValue: selection?.choice,
                isExpanded: true,
                decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: '옵션 선택'),
                items: [
                  for (final choice in option['choices'] as List)
                    DropdownMenuItem(
                        value: choice[0] as String,
                        child: Text(
                            '${choice[0]} · ${robotMoney((choice[1] as num).toInt())}'))
                ],
                onChanged: selection == null || !available
                    ? null
                    : (v) => change(() =>
                        part.costOptions[name] = RobotCostOption(choice: v)),
              )),
        if (option['control'] == 'qty' && selection != null)
          Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(children: [
                IconButton(
                    onPressed: selection.quantity <= 1
                        ? null
                        : () => change(() => part.costOptions[name] =
                            RobotCostOption(quantity: selection.quantity - 1)),
                    icon: const Icon(Icons.remove, size: 16)),
                Text('${selection.quantity} ${option['unit'] ?? 'EA'}',
                    style: RobinTheme.bodySm),
                IconButton(
                    onPressed: () => change(() => part.costOptions[name] =
                        RobotCostOption(quantity: selection.quantity + 1)),
                    icon: const Icon(Icons.add, size: 16)),
              ])),
      ]),
    );
  }

  void applyPreset(String name) => change(() {
        part.costOptions.clear();
        for (final row in robotDemoPresets[name] as List) {
          final option =
              robotDemoOptions.singleWhere((o) => o['name'] == row[0]);
          if (option['only'] != null &&
              option['only'] != part.costInputs['type']) {
            continue;
          }
          part.costOptions[row[0] as String] =
              RobotCostOption(choice: row.length > 1 ? row[1] as String : null);
        }
      });

  void importSpecification() => change(() {
        final spec = proposalSpecifications.value[part.specificationKey];
        final classification = part.classification;
        final options = spec?.smartOrderOptions ?? {};
        final candidates = {
          'model': classification?.middle ?? spec?.model,
          'axis': options['AXIS'],
          'type': switch (classification?.minor) {
            'BS' => 'B/S',
            'BT' || 'BE' => 'BELT',
            _ => null
          },
          'stroke':
              spec?.stroke.isNotEmpty == true ? '${spec!.stroke}ST' : null,
          'drive': options['Motor Type'],
          'lead': options['BALL SCREW'],
          'motorMaker':
              '${options['MOTOR MAKER'] ?? ''} ${options['MOTOR SERIES'] ?? ''}'
                  .trim(),
          'motorCap': RegExp(r'^\d+$').hasMatch(options['MOTOR 용량'] ?? '')
              ? '${options['MOTOR 용량']}W'
              : options['MOTOR 용량'],
        };
        var count = 0;
        for (final entry in candidates.entries) {
          if (entry.value != null &&
              robotDemoMaster[entry.key]!.containsKey(entry.value)) {
            part.costInputs[entry.key] = entry.value!;
            count++;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('계산 기준 $count개를 불러왔습니다. 남은 항목을 선택하세요.')));
      });
}

String robotMoney(int amount) =>
    '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';
