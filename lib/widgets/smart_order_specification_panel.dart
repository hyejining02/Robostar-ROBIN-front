import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/product_identity_service.dart';
import 'robin_dialog.dart';

/// SmartOrder's Specification layout, with ROBIN session-only draft storage.
/// Option masters and model-specific compatibility rules require its API.
class SmartOrderSpecificationPanel extends StatefulWidget {
  final ProductIdentityKey recordKey;
  final ValueChanged<ProductSpecification>? onApplied;
  const SmartOrderSpecificationPanel(
      {super.key, required this.recordKey, this.onApplied});

  @override
  State<SmartOrderSpecificationPanel> createState() =>
      _SmartOrderSpecificationPanelState();
}

class _SmartOrderSpecificationPanelState
    extends State<SmartOrderSpecificationPanel> {
  static const accent = Color(0xFFAF0030);
  static const grey = Color(0xFF606164);
  static const labels = {
    'motorType': 'Motor Type',
    'axis': 'AXIS',
    'screwMount': 'BALL SCREW 장착방식',
    'screw': 'BALL SCREW',
    'baseMount': 'BASE 취부 방식',
    'cover': 'U/COVER',
    'maker': 'MOTOR MAKER',
    'series': 'MOTOR SERIES',
    'capacity': 'MOTOR 용량',
    'parallel': '직·병렬 옵션',
    'block': 'LM BLOCK 수 변경',
    'screwKey': 'BALL SCREW KEY 적용',
    'sensor': '센서',
    'sensorBkt': '센서BKT',
    'lubrication': '주유방식',
  };
  final inputs = <String, TextEditingController>{};
  bool maxStroke = false;
  bool sideWindow = false;
  bool backSpecial = false;
  bool requiredOpen = true;
  bool optionsOpen = true;
  bool applied = false;
  ProductSpecification? lastSaved;
  bool writing = false;

  @override
  void initState() {
    super.initState();
    final saved = proposalSpecifications.value[widget.recordKey] ??
        const ProductSpecification();
    for (final id in ['model', 'stroke', ...labels.keys]) {
      inputs[id] = TextEditingController();
    }
    load(saved);
    lastSaved = proposalSpecifications.value[widget.recordKey];
    proposalSpecifications.addListener(sourceChanged);
  }

  void sourceChanged() {
    if (!mounted || writing) return;
    final next = proposalSpecifications.value[widget.recordKey];
    if (identical(next, lastSaved)) return;
    setState(() {
      lastSaved = next;
      load(next ?? const ProductSpecification());
      applied = false;
    });
  }

  void load(ProductSpecification spec) {
    inputs['model']!.text = spec.model;
    inputs['stroke']!.text = spec.stroke;
    for (final entry in labels.entries) {
      inputs[entry.key]!.text = spec.smartOrderOptions[entry.value] ??
          switch (entry.key) {
            'block' => '4B(기본)',
            'screwKey' => '미적용',
            'sensorBkt' => '표준',
            _ => '',
          };
    }
    sideWindow = spec.smartOrderOptions['측면견시창'] == 'Y';
    backSpecial = spec.smartOrderOptions['배면특주'] == 'Y';
    maxStroke = spec.smartOrderOptions['STROKE max'] == 'Y';
  }

  @override
  void dispose() {
    proposalSpecifications.removeListener(sourceChanged);
    for (final input in inputs.values) {
      input.dispose();
    }
    super.dispose();
  }

  String value(String id) => inputs[id]!.text.trim();
  bool get motorSelected => value('motorType').isNotEmpty;
  bool get ready =>
      [
        'model',
        'motorType',
        'axis',
        'stroke',
        'screwMount',
        'screw',
        'baseMount',
        'cover',
        'maker',
        'series',
        'capacity'
      ].every((id) => value(id).isNotEmpty) &&
      strokeError == null;
  String? get strokeError {
    if (value('stroke').isEmpty) return null;
    final n = int.tryParse(value('stroke'));
    return n == null || n < 50 || n > 2000 || (n - 50) % 10 != 0
        ? '50~2000mm, 10mm 단위로 입력해주세요.'
        : null;
  }

  void changed() => setState(() => applied = false);

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
          visualDensity: VisualDensity.standard,
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: accent),
          inputDecorationTheme: const InputDecorationTheme(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            filled: false,
          ),
        ),
        child: Container(
          key: const ValueKey('smartorder-specification'),
          padding: const EdgeInsets.all(10),
          color: const Color(0xFFF5F5F5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(
                  child: Text('Specification',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600))),
              OutlinedButton.icon(
                key: const ValueKey('smartorder-presets'),
                onPressed: presets,
                style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    foregroundColor: accent,
                    side: const BorderSide(color: accent),
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 10)),
                icon: const Icon(Icons.star, size: 17),
                label: const Text('추천 프리셋'),
              ),
            ]),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (context, constraints) {
              final required = section('필수 선택 항목', accent, requiredOpen,
                  (open) => setState(() => requiredOpen = open), [
                row(
                    1,
                    'Model',
                    combo('model', options: const [
                      'RS-N12',
                      'RS-N14',
                      'RS-N17',
                      'RS-N21'
                    ])),
                row(2, 'Motor Type', combo('motorType')),
                row(3, 'AXIS', combo('axis')),
                row(
                    4,
                    "STROKE '50~2000mm (gap:10)'",
                    Row(children: [
                      Expanded(
                          child: TextField(
                        key: ValueKey('proposal-stroke-${widget.recordKey.$2}'),
                        controller: inputs['stroke'],
                        onChanged: (_) {
                          maxStroke = false;
                          changed();
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(fontSize: 13),
                        decoration: decoration(
                            hint: 'STROKE 값을 입력해주세요', error: strokeError),
                      )),
                      SizedBox(
                          width: 25,
                          height: 34,
                          child: Checkbox(
                            value: maxStroke,
                            onChanged: (checked) {
                              setState(() {
                                maxStroke = checked!;
                                if (checked) inputs['stroke']!.text = '2000';
                                applied = false;
                              });
                            },
                          )),
                      const Text('max',
                          style: TextStyle(fontSize: 10, color: grey)),
                    ])),
                row(5, 'BALL SCREW 장착방식', combo('screwMount')),
                row(6, 'BALL SCREW', combo('screw')),
                row(7, 'BASE 취부 방식', combo('baseMount')),
                row(8, 'U/COVER', combo('cover')),
                row(
                    9,
                    'MOTOR',
                    Row(children: [
                      Expanded(child: combo('maker', hint: 'MAKER')),
                      const SizedBox(width: 4),
                      Expanded(
                          child: combo('series',
                              hint: 'SERIES',
                              enabled: value('maker').isNotEmpty)),
                      const SizedBox(width: 4),
                      Expanded(
                          child: combo('capacity',
                              hint: '용량', enabled: value('series').isNotEmpty)),
                    ])),
              ]);
              final options = section('선택 옵션', grey, optionsOpen,
                  (open) => setState(() => optionsOpen = open), [
                row(10, '직·병렬 옵션', combo('parallel', enabled: motorSelected),
                    optional: true),
                row(11, 'LM BLOCK 수 변경',
                    combo('block', options: const ['4B(기본)']),
                    optional: true),
                row(12, 'BALL SCREW KEY 적용',
                    combo('screwKey', options: const ['미적용', '적용']),
                    optional: true),
                row(13, '센서', combo('sensor', enabled: motorSelected),
                    optional: true),
                row(14, '센서BKT', combo('sensorBkt', options: const ['표준']),
                    optional: true),
                row(15, '주유방식', combo('lubrication', enabled: motorSelected),
                    optional: true),
                row(
                    16,
                    'BASE특주',
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                          borderRadius: BorderRadius.circular(5)),
                      child: Column(children: [
                        yesNo(
                            '측면견시창',
                            sideWindow,
                            (v) => setState(() {
                                  sideWindow = v;
                                  applied = false;
                                })),
                        yesNo(
                            '배면특주',
                            backSpecial,
                            (v) => setState(() {
                                  backSpecial = v;
                                  applied = false;
                                })),
                      ]),
                    ),
                    optional: true),
              ]);
              return constraints.maxWidth < 540
                  ? Column(
                      children: [required, const SizedBox(height: 12), options])
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Expanded(child: required),
                          const SizedBox(width: 12),
                          Expanded(child: options),
                        ]);
            }),
            const SizedBox(height: 10),
            SizedBox(
                width: double.infinity,
                height: 36,
                child: FilledButton(
                  key: const ValueKey('smartorder-apply'),
                  onPressed: ready ? apply : null,
                  style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      disabledBackgroundColor: const Color(0xFFDDDDDD),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7))),
                  child: Text(applied ? '적용 완료' : '적　　용'),
                )),
          ]),
        ),
      );

  InputDecoration decoration(
          {String? hint, String? error, bool enabled = true, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        errorText: error,
        errorMaxLines: 2,
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF333333))),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(
            minWidth: 24, maxWidth: 24, minHeight: 32, maxHeight: 32),
      );

  // Editable combos preserve free-entered legacy specs while the option API is absent.
  Widget combo(String id,
          {List<String> options = const [],
          String? hint,
          bool enabled = true}) =>
      TextField(
        key: ValueKey(
            'proposal-${id == 'motorType' ? 'motor' : id}-${widget.recordKey.$2}'),
        controller: inputs[id],
        enabled: enabled,
        onChanged: (_) {
          if (id == 'maker') {
            inputs['series']!.clear();
            inputs['capacity']!.clear();
          }
          if (id == 'series') inputs['capacity']!.clear();
          changed();
        },
        style: const TextStyle(fontSize: 13),
        decoration: decoration(
          hint: enabled
              ? hint
              : (['parallel', 'sensor', 'lubrication'].contains(id)
                  ? 'Motor Type 을 먼저 선택하세요'
                  : hint),
          enabled: enabled,
          suffix: enabled
              ? PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  tooltip: '선택 또는 직접 입력',
                  icon:
                      const Icon(Icons.arrow_drop_down, size: 16, color: grey),
                  itemBuilder: (_) => options.isEmpty
                      ? [
                          const PopupMenuItem(
                              enabled: false,
                              child: Text('옵션 목록 연동 전 · 직접 입력 가능'))
                        ]
                      : options
                          .map((option) =>
                              PopupMenuItem(value: option, child: Text(option)))
                          .toList(),
                  onSelected: (selected) {
                    inputs[id]!.text = selected;
                    changed();
                  },
                )
              : const Icon(Icons.arrow_drop_down,
                  size: 16, color: Color(0xFFBBBBBB)),
        ),
      );

  Widget section(String title, Color color, bool open,
          ValueChanged<bool> toggle, List<Widget> children) =>
      Container(
        decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: .6), width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ]),
        child: Column(children: [
          InkWell(
              onTap: () => toggle(!open),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(title,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: color))),
                  Icon(
                      open
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: accent),
                ]),
              )),
          if (open)
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                child: Column(children: children)),
        ]),
      );

  Widget row(int number, String label, Widget child, {bool optional = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: label.startsWith('STROKE ') ? 'STROKE ' : label),
                    if (label.startsWith('STROKE '))
                      const TextSpan(
                          text: "'50~2000mm (gap:10)'",
                          style: TextStyle(color: accent)),
                  ]),
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500))),
          const SizedBox(height: 1),
          Row(children: [
            Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: optional ? grey : accent, width: 1.4),
                    color: (optional ? grey : accent).withValues(alpha: .1)),
                alignment: Alignment.center,
                child: Text('$number',
                    style: TextStyle(
                        fontSize: 12, color: optional ? grey : accent))),
            const SizedBox(width: 10),
            Expanded(child: child),
          ]),
        ]),
      );

  Widget yesNo(String label, bool selected, ValueChanged<bool> onChanged) =>
      RadioGroup<bool>(
          groupValue: selected,
          onChanged: (value) => onChanged(value!),
          child: Row(children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600))),
            for (final entry in [(true, 'Y'), (false, 'N')]) ...[
              SizedBox(
                  width: 24,
                  height: 30,
                  child: Radio<bool>(value: entry.$1, activeColor: accent)),
              Text(entry.$2,
                  style: TextStyle(
                      fontSize: 12,
                      color: selected == entry.$1 ? accent : grey)),
              const SizedBox(width: 8),
            ],
          ]));

  void apply() {
    if (!ready) return;
    final previous = proposalSpecifications.value[widget.recordKey] ??
        const ProductSpecification();
    writing = true;
    proposalSpecifications.value = {
      ...proposalSpecifications.value,
      widget.recordKey: ProductSpecification(
        model: value('model'),
        stroke: value('stroke'),
        motorDirection: previous.motorDirection,
        sensorDirection: previous.sensorDirection,
        smartOrderOptions: {
          ...previous.smartOrderOptions,
          for (final entry in labels.entries) entry.value: value(entry.key),
          '측면견시창': sideWindow ? 'Y' : 'N',
          '배면특주': backSpecial ? 'Y' : 'N',
          'STROKE max': maxStroke ? 'Y' : 'N',
        },
      ),
    };
    writing = false;
    lastSaved = proposalSpecifications.value[widget.recordKey];
    setState(() => applied = true);
    widget.onApplied?.call(proposalSpecifications.value[widget.recordKey]!);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('컨셉도면 사양을 적용했습니다.')));
  }

  Future<void> presets() async {
    final saved = proposalSpecifications.value.entries
        .where((entry) =>
            entry.key.$1 == widget.recordKey.$1 &&
            entry.value.smartOrderOptions.isNotEmpty)
        .toList();
    final selected = await showDialog<ProductSpecification>(
        context: context,
        builder: (context) =>
            RobinSimpleDialog(title: const Text('추천 프리셋 · 적용한 사양'), children: [
              if (saved.isEmpty)
                const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('아직 적용한 사양이 없습니다. 사양을 적용한 뒤 다시 선택할 수 있습니다.')),
              for (final entry in saved)
                SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, entry.value),
                    child: Text(
                        '${entry.key.$2} · ${entry.value.model} · ${entry.value.stroke}mm')),
            ]));
    if (selected == null || !mounted) return;
    setState(() {
      load(selected);
      applied = false;
    });
  }
}
