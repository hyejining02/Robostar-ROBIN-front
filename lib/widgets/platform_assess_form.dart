import 'package:flutter/material.dart';
import '../services/desktop_file_service.dart';
import '../services/platform_pipeline_service.dart';
import '../theme/robin_theme.dart';
import 'user_profile.dart';
import 'platform_form_layout.dart';

class PlatformAssessForm extends StatefulWidget {
  final PlatformPipelineData data;
  final VoidCallback onSaved;
  final Future<bool> Function(int stage) onAdvance;
  final VoidCallback onDesignReview;
  const PlatformAssessForm(
      {super.key,
      required this.data,
      required this.onSaved,
      required this.onAdvance,
      required this.onDesignReview});
  @override
  State<PlatformAssessForm> createState() => _PlatformAssessFormState();
}

class _PlatformAssessFormState extends State<PlatformAssessForm> {
  PlatformPipelineData get data => widget.data;
  String error = '';
  String? materialKind;
  Future<void> attach(String kind) async {
    try {
      final f = await DesktopFileService.pickReferenceDocument(
          extensions: const [
            'msg',
            'eml',
            'pdf',
            'xlsx',
            'xlsm',
            'png',
            'jpg',
            'dwg',
            'step',
            'stp'
          ]);
      if (f != null && mounted) setState(() => data.files[kind]!.add(f));
    } catch (e) {
      if (mounted) setState(() => error = '첨부 실패: $e');
    }
  }

  bool save() {
    try {
      data.saveAssess(robinUserProfile.value.name);
      setState(() => error = '');
      widget.onSaved();
      return true;
    } on StateError catch (e) {
      setState(() => error = e.message);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        platformCard('Assess · 필수 입력', [
          platformInlineFields([
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('등록 유형', style: RobinTheme.labelXs),
              const SizedBox(height: 4),
              Wrap(spacing: 8, runSpacing: 6, children: [
                for (final type in ['신규', 'Repeat / 양산'])
                  ChoiceChip(
                      label: Text(type),
                      selected: data.registrationType == type,
                      onSelected: data.assessSaved
                          ? null
                          : (_) => setState(() {
                                data.registrationType = type;
                                if (type == 'Repeat / 양산') {
                                  data.equipmentTbd = false;
                                }
                              })),
              ]),
            ]),
            assessField('customer')
          ]),
          if (data.registrationType == 'Repeat / 양산') ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
                key: ValueKey('platform-origin-${data.key.$2}'),
                initialValue: data.origin,
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: '원 프로젝트 *',
                    border: OutlineInputBorder(),
                    isDense: true),
                items: [
                  for (final source in platformPipelineRecords.values
                      .where((d) => d.key != data.key))
                    DropdownMenuItem(
                        value: source.key.$2,
                        child: Text('${source.key.$2} · ${source.projectName}'))
                ],
                onChanged: (v) => setState(() {
                      data.origin = v;
                      final source = platformPipelineRecords.values
                          .where((d) => d.key.$2 == v)
                          .firstOrNull;
                      if (source != null) {
                        data.category = source.category;
                        data.equipment
                          ..clear()
                          ..addAll(source.equipment);
                        data.materials
                          ..clear()
                          ..addAll(source.materials);
                      }
                    })),
            const Text('Repeat는 원 프로젝트 장비 구성을 가져옵니다. SL은 신규 발번하지 않습니다.',
                style: TextStyle(fontSize: 11)),
          ],
          const SizedBox(height: 12),
          Text('장비 · 대수 *', style: RobinTheme.headingSm),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4, children: [
            for (final category in platformEquipment.keys)
              ChoiceChip(
                  label: Text(category),
                  selected: data.category == category,
                  onSelected: data.equipmentTbd
                      ? null
                      : (_) {
                          if (data.category != category &&
                              data.equipment.values.any((n) => n > 0)) {
                            setState(() =>
                                error = '입력된 장비 대수를 0으로 줄인 뒤 대분류를 변경해주세요.');
                            return;
                          }
                          setState(() {
                            data.category = category;
                            data.materials.clear();
                            error = '';
                          });
                        })
          ]),
          const SizedBox(height: 6),
          if (data.category.isNotEmpty)
            LayoutBuilder(builder: (context, c) {
              final count = (c.maxWidth / 170)
                  .floor()
                  .clamp(1, platformEquipment[data.category]!.length)
                  .toInt();
              return Wrap(spacing: 8, runSpacing: 8, children: [
                for (final eq in platformEquipment[data.category]!)
                  Container(
                      padding: const EdgeInsets.all(8),
                      width: (c.maxWidth - (count - 1) * 8) / count,
                      decoration: BoxDecoration(
                          border: Border.all(color: RobinTheme.border),
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(children: [
                        Expanded(child: Text(eq, style: RobinTheme.bodySm)),
                        SizedBox(
                            width: 30,
                            height: 30,
                            child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: data.equipmentTbd ||
                                        (data.equipment[eq] ?? 0) == 0
                                    ? null
                                    : () => setState(() => data.equipment[eq] =
                                        (data.equipment[eq] ?? 0) - 1),
                                icon: const Icon(Icons.remove, size: 16))),
                        Text('${data.equipment[eq] ?? 0}'),
                        SizedBox(
                            width: 30,
                            height: 30,
                            child: IconButton(
                                padding: EdgeInsets.zero,
                                key: ValueKey('platform-equipment-add-$eq'),
                                onPressed: data.equipmentTbd
                                    ? null
                                    : () => setState(() => data.equipment[eq] =
                                        (data.equipment[eq] ?? 0) + 1),
                                icon: const Icon(Icons.add, size: 16))),
                      ])),
              ]);
            }),
          if (data.registrationType == '신규')
            CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('장비 미정'),
                value: data.equipmentTbd,
                onChanged: (v) => setState(() => data.equipmentTbd = v!)),
          if (data.equipmentTbd)
            const Text('장비 미정 상태로 문의를 저장할 수 있습니다. 장비 확정 후 Proposal로 진행하세요.'),
          materialReviewRow(),
        ]),
        platformCard('과제명 · 가수주번호', [
          if (!data.titleLocked)
            CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('업체·장비·이재물 기준으로 과제명 자동 구성'),
                value: data.autoTitle,
                onChanged: (v) => setState(() => data.autoTitle = v!)),
          if (data.autoTitle || data.titleLocked)
            Text(data.projectName, style: RobinTheme.headingSm)
          else
            TextFormField(
                key: ValueKey('platform-project-${data.key.$2}'),
                initialValue: data.assess['project'],
                onChanged: (v) => data.assess['project'] = v,
                decoration: const InputDecoration(
                    labelText: '과제명',
                    isDense: true,
                    border: OutlineInputBorder())),
          const SizedBox(height: 6),
          Text(
              '${data.key.$2} · ${data.createdAt.toString().substring(0, 10)} · ${data.owner}',
              style: RobinTheme.bodySm),
          const Text(
              '가수주번호·SL은 현재 시안의 로컬 관리번호입니다. ERP 등록·공식 번호 발급은 연결되지 않았습니다.',
              style: TextStyle(fontSize: 11)),
          if (data.titleLocked) const Text('Proposal 시작 시 고정된 과제명입니다.'),
        ]),
        if (data.units.isNotEmpty)
          platformCard('호기 예정 목록 (SL)', [
            for (final unit in data.units)
              ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${unit.number} · ${unit.equipment}',
                      style: RobinTheme.bodySm),
                  subtitle: Text(
                      unit.excluded ? '제외 · 번호와 이력 보존' : '진행 · SM은 수주 단계에서 연결',
                      style: RobinTheme.labelXs),
                  trailing: TextButton(
                      onPressed: () => setState(() {
                            unit.excluded = !unit.excluded;
                            data.equipment[unit.equipment] = data.units
                                .where((u) =>
                                    u.equipment == unit.equipment &&
                                    !u.excluded)
                                .length;
                          }),
                      child: Text(unit.excluded ? '복원' : '제외'))),
          ]),
        platformCard('고객 정보', [
          platformFields(context, [
            for (final k in ['contact', 'rank', 'phone', 'email'])
              assessField(k)
          ]),
          const SizedBox(height: 8),
          assessField('inquiry', lines: 2),
          fileSlot('mail', '문의 메일'),
        ]),
        ExpansionTile(
            title: const Text('추가 정보 · 고객 미팅 · 고객 Layout'),
            children: [
              platformCard('', [
                platformFields(context, [
                  for (final k in [
                    'endUser',
                    'seller',
                    'endUser2',
                    'site',
                    'maker',
                    'orderMonth',
                    'arrivalMonth'
                  ])
                    assessField(k)
                ]),
                const SizedBox(height: 8),
                assessField('note', lines: 2),
                fileSlot('layout', '고객 Layout'),
                for (var i = 0; i < data.meetings.length; i++)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: platformFields(context, [
                        for (final k in const {
                          'date': '미팅일',
                          'who': '고객 참석자',
                          'pain': 'Pain Point',
                          'request': '고객 요구사항'
                        }.entries)
                          TextFormField(
                              key: ValueKey(
                                  'platform-meeting-$i-${k.key}-${data.key.$2}'),
                              initialValue: data.meetings[i][k.key],
                              onChanged: (v) => data.meetings[i][k.key] = v,
                              decoration: InputDecoration(
                                  labelText: k.value,
                                  isDense: true,
                                  border: const OutlineInputBorder()))
                      ])),
                TextButton.icon(
                    onPressed: () => setState(() => data.meetings.add({})),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('고객 미팅 추가')),
              ])
            ]),
        if (error.isNotEmpty)
          Padding(
              padding: const EdgeInsets.all(8),
              child: Text(error, style: const TextStyle(color: Colors.red))),
        platformActionBar(
            actions: Wrap(spacing: 8, runSpacing: 6, children: [
          OutlinedButton(
              key: const ValueKey('platform-assess-save'),
              onPressed: save,
              child: const Text('Assess 저장')),
          FilledButton(
              key: const ValueKey('platform-assess-advance'),
              onPressed: () async {
                if (data.equipmentTbd) {
                  setState(() => error = '장비 미정을 해제하고 장비·대수를 확정해주세요.');
                  return;
                }
                if (!save()) return;
                final advanced = await widget
                    .onAdvance(data.registrationType == 'Repeat / 양산' ? 2 : 1);
                if (advanced) {
                  data.assess['project'] = data.projectName;
                  data.titleLocked = true;
                }
              },
              child: Text(data.registrationType == 'Repeat / 양산'
                  ? 'Repeat 등록 → Negotiation'
                  : 'Proposal 단계로 변경')),
        ])),
      ]);
  Widget materialReviewRow() => LayoutBuilder(builder: (context, c) {
        final kind = (data.materials.isNotEmpty
                ? platformMaterials[data.materials.first]
                : materialKind) ??
            '웨이퍼';
        final sizes =
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('이재물 *', style: RobinTheme.headingSm),
          const SizedBox(height: 5),
          Wrap(
              spacing: 5,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final type in ['웨이퍼', '패널', '해당 없음'])
                  ChoiceChip(
                      label: Text(type),
                      selected: kind == type,
                      onSelected: (_) => setState(() {
                            if (kind != type) data.materials.clear();
                            materialKind = type;
                          })),
                for (final e
                    in platformMaterials.entries.where((e) => e.value == kind))
                  FilterChip(
                      label: Text('${e.key} · ${e.value}'),
                      selected: data.materials.contains(e.key),
                      onSelected: (on) => setState(() {
                            if (on) {
                              data.materials.add(e.key);
                            } else {
                              data.materials.remove(e.key);
                            }
                          })),
              ]),
        ]);
        final review = OutlinedButton.icon(
            key: const ValueKey('platform-open-design-review'),
            onPressed: widget.onDesignReview,
            icon: const Icon(Icons.architecture, size: 16),
            label: const Text('설계 검토 의뢰 · 재료비 / Layout'));
        if (data.category != '반도체' || data.equipmentTbd) return review;
        return c.maxWidth < 760
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [sizes, const SizedBox(height: 8), review])
            : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: sizes),
                const SizedBox(width: 12),
                review
              ]);
      });
  Widget assessField(String id, {int lines = 1}) => TextFormField(
      key: ValueKey('platform-assess-$id-${data.key.$2}'),
      initialValue: data.assess[id],
      maxLines: lines,
      onChanged: (v) => setState(() => data.assess[id] = v),
      decoration: InputDecoration(
          labelText: platformAssessLabels[id],
          isDense: true,
          border: const OutlineInputBorder()));
  Widget fileSlot(String id, String label) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextButton.icon(
            onPressed: () => attach(id),
            icon: const Icon(Icons.attach_file, size: 16),
            label: Text('$label 첨부')),
        for (final file in data.files[id]!)
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
            TextButton(
                onPressed: () async {
                  try {
                    await DesktopFileService.saveSelectedDocument(file);
                  } catch (e) {
                    if (mounted) setState(() => error = '$e');
                  }
                },
                child: Text(file.name)),
            IconButton(
                onPressed: () => setState(() => data.files[id]!.remove(file)),
                icon: const Icon(Icons.close, size: 14)),
          ]),
      ]);
}

Widget platformCard(String title, List<Widget> children) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: RobinTheme.border),
        borderRadius: BorderRadius.circular(8)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title.isNotEmpty) ...[
        Text(title, style: RobinTheme.headingSm),
        const SizedBox(height: 10)
      ],
      ...children
    ]));
Widget platformFields(BuildContext context, List<Widget> fields) =>
    LayoutBuilder(
        builder: (context, c) => Wrap(spacing: 8, runSpacing: 10, children: [
              for (final f in fields)
                SizedBox(
                    width: c.maxWidth < 560 ? c.maxWidth : (c.maxWidth - 8) / 2,
                    child: f)
            ]));
