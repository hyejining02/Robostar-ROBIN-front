import 'package:flutter/material.dart';

import '../services/product_identity_service.dart';
import '../theme/robin_theme.dart';
import 'robin_dialog.dart';
import 'user_profile.dart';

class ProductIdentityPanel extends StatelessWidget {
  final ProductIdentityKey recordKey;
  final String? projectModel;
  final bool readOnly;
  const ProductIdentityPanel(
      {super.key,
      required this.recordKey,
      this.projectModel,
      this.readOnly = false});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: productIdentities,
        builder: (context, _, child) {
          final data = identityFor(recordKey);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('제품 식별·코드 생성', style: RobinTheme.headingSm),
                  Text(data.status, style: RobinTheme.bodySm),
                  if (!readOnly && !robinUserProfile.value.isDealer)
                    OutlinedButton.icon(
                      key: ValueKey('edit-product-identity-${recordKey.$2}'),
                      onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => _IdentityEditor(
                              recordKey: recordKey,
                              projectModel: projectModel)),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('식별정보·사양 편집'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 20, runSpacing: 8, children: [
                for (final entry in {
                  '제품코드': data.productCode,
                  '제품번호': data.productNumber,
                  '도면번호': data.drawingNumber,
                  '모델': data.specification.model,
                }.entries)
                  SizedBox(
                      width: 180,
                      child: Text(
                          '${entry.key}: ${entry.value.isEmpty ? '미등록' : entry.value}')),
              ]),
              const SizedBox(height: 6),
              Text('PDM 연계 전 별도 관리 · 공식 채번 규칙 미등록 · ERP/SmartOrder 미연동',
                  style: RobinTheme.labelXs),
              Text('동일 사업부·관리번호 기준 임시 저장 (앱 종료 시 초기화)',
                  style: RobinTheme.labelXs),
              if (data.revision > 0)
                Text(
                    'Rev.${data.revision} · ${data.author} · ${data.savedAt!.toLocal()}',
                    style: RobinTheme.labelXs),
            ]),
          );
        },
      );
}

class _IdentityEditor extends StatefulWidget {
  final ProductIdentityKey recordKey;
  final String? projectModel;
  const _IdentityEditor({required this.recordKey, this.projectModel});
  @override
  State<_IdentityEditor> createState() => _IdentityEditorState();
}

class _IdentityEditorState extends State<_IdentityEditor> {
  final form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> fields;
  late String source;
  String message = '';
  Map<String, String> smartOrderOptions = const {};

  @override
  void initState() {
    super.initState();
    final old = identityFor(widget.recordKey);
    smartOrderOptions = old.specification.smartOrderOptions;
    source = old.source;
    fields = {
      for (final entry in {
        'code': old.productCode,
        'number': old.productNumber,
        'drawing': old.drawingNumber,
        'model': old.specification.model,
        'stroke': old.specification.stroke,
        'motor': old.specification.motorDirection,
        'sensor': old.specification.sensorDirection,
        'reference': old.reference,
      }.entries)
        entry.key: TextEditingController(text: entry.value),
    };
  }

  @override
  void dispose() {
    for (final controller in fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget field(String id, String label, {String? helper}) => SizedBox(
        width: 285,
        child: TextFormField(
          key: ValueKey('identity-$id'),
          controller: fields[id],
          decoration: InputDecoration(
              labelText: label,
              helperText: helper,
              border: const OutlineInputBorder(),
              isDense: true),
          validator: (value) {
            if (id != 'stroke' || (value?.trim().isEmpty ?? true)) return null;
            final number = double.tryParse(value!.trim());
            return number == null || !number.isFinite || number < 0
                ? '0 이상의 숫자를 입력해주세요.'
                : null;
          },
        ),
      );

  void loadSpecification() {
    final spec = proposalSpecifications.value[widget.recordKey];
    setState(() {
      if (spec == null && (widget.projectModel?.isEmpty ?? true)) {
        message = '연결된 컨셉/레이아웃 사양이 없습니다. 직접 보완해주세요.';
        return;
      }
      // Pull only known source fields; never overwrite with invented defaults.
      final available =
          spec ?? ProductSpecification(model: widget.projectModel!);
      smartOrderOptions = available.smartOrderOptions;
      for (final entry in {
        'model': available.model,
        'stroke': available.stroke,
        'motor': available.motorDirection,
        'sensor': available.sensorDirection
      }.entries) {
        if (entry.value.isNotEmpty) fields[entry.key]!.text = entry.value;
      }
      message = spec == null
          ? '프로젝트의 예시 모델만 불러왔습니다. 미확정 사양은 직접 보완해주세요.'
          : '입력된 컨셉/레이아웃 사양을 불러왔습니다. 번호는 변경하지 않았습니다.';
    });
  }

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
        title: const Text('제품 식별정보·사양 관리'),
        content: SizedBox(
            width: 620,
            child: Form(
              key: form,
              child: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.recordKey.$1.label} · ${widget.recordKey.$2}'),
                  const SizedBox(height: 10),
                  const Text(
                      '제품코드·제품번호·도면번호는 서로 다른 값입니다. 제품번호와 Serial의 관계도 확인 전에는 합치지 않습니다.'),
                  const SizedBox(height: 14),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    field('code', '제품코드', helper: '공식 코드 자동 발급 없음'),
                    field('number', '제품번호', helper: '제품코드·Serial과 별도 관리'),
                    field('drawing', '도면번호'),
                    SizedBox(
                        width: 285,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: source,
                          decoration: const InputDecoration(
                              labelText: '정보 출처 (연동 아님)',
                              border: OutlineInputBorder(),
                              isDense: true),
                          items: const [
                            '직접 입력',
                            'Excel 입력',
                            'ERP 자료 수동 확인',
                            'SmartOrder 자료 수동 확인'
                          ]
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (s) => setState(() => source = s!),
                        )),
                    field('reference', '근거 문서·참조번호'),
                  ]),
                  const SizedBox(height: 14),
                  OutlinedButton(
                      onPressed: loadSpecification,
                      key: const ValueKey('identity-load-spec'),
                      child: const Text('컨셉/레이아웃 사양 불러오기')),
                  const SizedBox(height: 10),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    field('model', '모델'),
                    field('stroke', 'Stroke(mm)'),
                    field('motor', '모터 방향'),
                    field('sensor', '센서 방향'),
                  ]),
                  const SizedBox(height: 12),
                  const Text(
                      '자동 생성: 규칙 확인 필요\n설계팀의 필수 사양·생성 규칙·채번 주체 확정 전에는 코드 후보도 임의 생성하지 않습니다. 입력값은 공식 검증 전 상태로 보관합니다.'),
                  if (message.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(message)),
                  if (identityFor(widget.recordKey).history.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ExpansionTile(title: const Text('수정 이력'), children: [
                      for (final entry
                          in identityFor(widget.recordKey).history.reversed)
                        ListTile(title: Text(entry, style: RobinTheme.bodySm)),
                    ]),
                  ],
                ],
              )),
            )),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
              key: const ValueKey('identity-save'),
              onPressed: () {
                if (!form.currentState!.validate()) return;
                String value(String name) => fields[name]!.text.trim();
                saveProductIdentity(
                    widget.recordKey,
                    ProductIdentity(
                      productCode: value('code'),
                      productNumber: value('number'),
                      drawingNumber: value('drawing'),
                      specification: ProductSpecification(
                          model: value('model'),
                          stroke: value('stroke'),
                          motorDirection: value('motor'),
                          sensorDirection: value('sensor'),
                          smartOrderOptions: smartOrderOptions),
                      source: source,
                      reference: value('reference'),
                    ),
                    author: robinUserProfile.value.name);
                Navigator.pop(context);
              },
              child: const Text('임시 저장')),
        ],
      );
}
