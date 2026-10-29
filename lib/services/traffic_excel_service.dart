import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:xml/xml.dart';

/// The agreed legacy A:AU layout. The newer 56-column example is not a schema.
const trafficHeaders = <String>[
  '주차',
  '수주월',
  '입고월',
  'ERP 수주번호',
  '제품코드',
  '담당자',
  '사업부',
  'Item',
  '내수/수출',
  '제조구분',
  '제품류',
  '수익성구분',
  '매출구분',
  '생기원구분',
  '향지',
  '향지구분',
  '채널',
  '채널구분',
  '거래처',
  'End User',
  'PJT명',
  '단계',
  '전주등급',
  '등급',
  '통화',
  '환율',
  '외화단가',
  '외화매출액',
  '수량',
  '판가',
  '매출액(백만원)',
  '재료비(백만원)',
  '재료비율',
  '지급수수료(백만원)',
  '커미션(백만원)',
  '비고',
  'ITEM구분',
  'BEST',
  '반영등급',
  'WORST',
  '수주',
  '입고',
  '조정 매출액(억원)',
  '조정 재료비(억원)',
  'AS (헤더 없음)',
  'AT (헤더 없음)',
  'AU (헤더 없음)',
];

double millionToManwon(num value) => value * 100.0;
double manwonToMillion(num value) => value / 100.0;
double manwonToEok(num value) => value / 10000.0;

class TrafficImportRow {
  final String sheet;
  final int row;
  final List<String> values;
  final List<String> errors;
  final List<String> warnings;
  final bool duplicate;
  final double salesMillion;
  final double materialMillion;
  final int quantity;
  final String orderMonth;
  final String arrivalMonth;

  const TrafficImportRow(
      {required this.sheet,
      required this.row,
      required this.values,
      required this.errors,
      required this.warnings,
      required this.duplicate,
      required this.salesMillion,
      required this.materialMillion,
      required this.quantity,
      required this.orderMonth,
      required this.arrivalMonth});

  bool get canImport => errors.isEmpty && !duplicate;
  String get status => errors.isNotEmpty
      ? '오류'
      : duplicate
          ? '중복 검토'
          : '신규';
  String get fingerprint =>
      trafficFingerprint(values[20], values[18], orderMonth);
}

String trafficFingerprint(String project, String customer, String month) =>
    '${project.trim().toLowerCase()}\u0000${customer.trim().toLowerCase()}\u0000$month';

class TrafficImportResult {
  final List<TrafficImportRow> rows;
  const TrafficImportResult(this.rows);
  List<TrafficImportRow> get accepted =>
      rows.where((r) => r.canImport).toList();
}

class TrafficExcelService {
  /// Some customer workbooks redefine built-in format 41 as a custom format.
  /// excel rejects IDs <164. Remap just those format IDs in memory, preserving
  /// format strings, cell values, formulas and the original on-disk workbook.
  static Excel _decode(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final styles = archive.findFile('xl/styles.xml');
    if (styles == null) return Excel.decodeBytes(bytes);
    final document =
        XmlDocument.parse(utf8.decode(styles.content as List<int>));
    final formats = document.findAllElements('numFmt').toList();
    final used =
        formats.map((f) => int.parse(f.getAttribute('numFmtId')!)).toSet();
    final remapped = <int, int>{};
    var next = 164;
    for (final format in formats) {
      final id = int.parse(format.getAttribute('numFmtId')!);
      if (id >= 164) continue;
      while (used.contains(next)) {
        next++;
      }
      remapped[id] = next;
      used.add(next);
      format.setAttribute('numFmtId', '${next++}');
    }
    if (remapped.isEmpty) return Excel.decodeBytes(bytes);
    for (final xf in document.findAllElements('xf')) {
      final id = int.tryParse(xf.getAttribute('numFmtId') ?? '');
      if (remapped.containsKey(id)) {
        xf.setAttribute('numFmtId', '${remapped[id]}');
      }
    }
    final normalized = utf8.encode(document.toXmlString());
    final compatible = Archive();
    for (final entry in archive.files) {
      compatible.addFile(entry.name == styles.name
          ? ArchiveFile(entry.name, normalized.length, normalized)
          : entry);
    }
    return Excel.decodeBytes(ZipEncoder().encode(compatible)!);
  }

  static String _normalized(String text) => text.replaceAll(RegExp(r'\s+'), '');

  static TrafficImportResult parse(
    List<int> bytes, {
    required Set<String> existingFingerprints,
    required Set<String> existingErpNumbers,
    required Set<String> divisionAliases,
  }) {
    final workbook = _decode(bytes);
    final candidates = <(Sheet, int)>[];
    for (final sheet in workbook.tables.values) {
      for (var r = 0; r < sheet.maxRows && r < 60; r++) {
        final cells = sheet.rows[r];
        if (cells.length < 44) continue;
        if (List.generate(44, (i) => i).every((i) =>
            _normalized(cells[i]?.value?.toString() ?? '') ==
            _normalized(trafficHeaders[i]))) {
          candidates.add((sheet, r));
        }
      }
    }
    if (candidates.length != 1) {
      throw const FormatException('기존 47열 양식의 헤더를 하나만 포함해야 합니다. '
          'A:AR 업무 열의 이름·순서를 확인해주세요. 56열 예시는 아직 지원하지 않습니다.');
    }
    final (sheet, headerRow) = candidates.single;
    if (sheet.maxRows > 10002) {
      throw const FormatException('한 번에 최대 10,000행까지 검증할 수 있습니다.');
    }
    final seen = {...existingFingerprints};
    final erpSeen = existingErpNumbers.map((e) => e.toUpperCase()).toSet();
    final result = <TrafficImportRow>[];
    for (var r = headerRow + 1; r < sheet.maxRows; r++) {
      final cells = sheet.rows[r];
      final values = List.generate(
          47,
          (i) =>
              i < cells.length ? cells[i]?.value?.toString().trim() ?? '' : '');
      // Ignore formatting-only rows and auxiliary formula-only trailing rows.
      if (values.take(42).every((s) => s.isEmpty)) continue;
      final errors = <String>[];
      final warnings = <String>[];
      void error(int column, String message) => errors.add(
          '${_column(column)}${r + 1} · ${trafficHeaders[column]}: $message');
      if (cells
          .skip(47)
          .any((c) => c?.value != null && c!.value.toString().isNotEmpty)) {
        error(46, 'AU 뒤의 입력값은 지원하지 않습니다. 열 구성을 확인해주세요.');
      }
      for (final i in [18, 20]) {
        if (values[i].isEmpty) error(i, '필수 입력입니다.');
      }
      if (values[6].isNotEmpty && !divisionAliases.contains(values[6])) {
        error(6, '선택한 사업부와 다르거나 알 수 없는 사업부입니다.');
      }
      if (values[21].isNotEmpty && values[21].toLowerCase() != 'assess') {
        error(21, '신규 물동은 Assess만 등록합니다. 다른 단계는 별도 검토해주세요.');
      }
      String month(int i) {
        final match = RegExp(r'^(\d{4})-?(\d{2})(?:-\d{2}(?:.*)?)?$')
            .firstMatch(values[i]);
        if (match == null ||
            int.parse(match[2]!) < 1 ||
            int.parse(match[2]!) > 12) {
          error(i, 'YYYY-MM 또는 YYYYMM 형식으로 입력해주세요.');
          return '';
        }
        return '${match[1]}-${match[2]}';
      }

      double? number(int i, {bool required = false}) {
        if (values[i].isEmpty && !required) return null;
        final n = double.tryParse(values[i].replaceAll(',', ''));
        if (n == null || !n.isFinite || n < 0) {
          error(i, '0 이상의 숫자 값이 필요합니다. 수식은 값으로 붙여넣어주세요.');
          return null;
        }
        return n;
      }

      final orderMonth = month(1);
      final arrivalMonth = month(2);
      final sales = number(30, required: true);
      final material = number(31, required: true);
      final qty = number(28, required: true);
      if (qty != null &&
          (qty <= 0 || qty > 2147483647 || qty != qty.roundToDouble())) {
        error(28, '현재 화면은 1~2,147,483,647 범위의 정수 수량만 지원합니다.');
      }
      if (sales != null && !millionToManwon(sales).isFinite) {
        error(30, '표시 가능한 금액 범위를 초과했습니다.');
      }
      if (material != null && !millionToManwon(material).isFinite) {
        error(31, '표시 가능한 금액 범위를 초과했습니다.');
      }
      if (sales != null && material != null && material > sales) {
        warnings.add('재료비가 매출액보다 큽니다. 입력값을 확인해주세요.');
      }
      for (final i in [25, 26, 27, 29, 33, 34]) {
        number(i);
      }
      if (values[24].isEmpty) error(24, '통화를 입력해주세요.');
      // Sales/material are explicitly KRW million, even for foreign-currency quotes.
      if (values[24].isNotEmpty &&
          !['WON', 'KRW', '원'].contains(values[24].toUpperCase())) {
        final fx = double.tryParse(values[25].replaceAll(',', ''));
        if (fx == null || !fx.isFinite || fx <= 0) {
          error(25, '외화 건은 양의 환율을 입력해주세요.');
        }
        warnings
            .add('외화는 원본 보존. 원화 매출액·재료비(백만원)를 기준으로 등록하며 환산 검증은 별도 확인이 필요합니다.');
      }
      if (values[29].isNotEmpty) {
        warnings.add('판가는 원본 값입니다. 단위 확정 전 자동 환산·재계산하지 않습니다.');
      }
      if (values.sublist(42, 44).any((v) => v.isNotEmpty)) {
        warnings.add('원본 조정금액은 별도 보존합니다. 상세의 단순 단위 환산값과 구분해 확인해주세요.');
      }
      final fingerprint =
          trafficFingerprint(values[20], values[18], orderMonth);
      final erp = values[3].toUpperCase();
      final duplicate = seen.contains(fingerprint) ||
          (erp.isNotEmpty && erpSeen.contains(erp));
      // Reserve valid rows only, so an erroneous first row cannot hide a valid one.
      if (errors.isEmpty) {
        seen.add(fingerprint);
        if (erp.isNotEmpty) erpSeen.add(erp);
      }
      result.add(TrafficImportRow(
          sheet: sheet.sheetName,
          row: r + 1,
          values: List.unmodifiable(values),
          errors: errors,
          warnings: warnings,
          duplicate: duplicate,
          salesMillion: sales ?? 0,
          materialMillion: material ?? 0,
          quantity: qty?.toInt() ?? 0,
          orderMonth: orderMonth,
          arrivalMonth: arrivalMonth));
    }
    if (result.isEmpty) throw const FormatException('등록할 데이터 행이 없습니다.');
    return TrafficImportResult(result);
  }

  static String _column(int index) {
    var n = index + 1;
    var result = '';
    while (n > 0) {
      n--;
      result = String.fromCharCode(65 + n % 26) + result;
      n ~/= 26;
    }
    return result;
  }
}
