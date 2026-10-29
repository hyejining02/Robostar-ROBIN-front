import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/services/desktop_file_service.dart';
import 'package:robin_portal/services/traffic_excel_service.dart';
import 'package:xml/xml.dart';

List<Object?> trafficTestRow({String project = '신규 프로젝트', String erp = ''}) {
  final row = List<Object?>.filled(47, null);
  row[1] = 202610;
  row[2] = '2026-11';
  row[3] = erp;
  row[6] = 'ROBOT';
  row[18] = '신규고객';
  row[20] = project;
  row[24] = 'WON';
  row[28] = 12;
  row[30] = 15.24;
  row[31] = 9.812334;
  return row;
}

void main() {
  TrafficImportResult parse(List<List<Object?>> rows,
          {Set<String> existing = const {}}) =>
      TrafficExcelService.parse(
          DesktopFileService.createWorkbookBytes(
              sheetName: '물동', headers: trafficHeaders, rows: rows),
          existingFingerprints: existing,
          existingErpNumbers: {},
          divisionAliases: {'ROBOT'});

  test('금액의 만원/백만원/억원을 정확하게 환산한다', () {
    expect(millionToManwon(15.24), closeTo(1524, 0.000001));
    expect(manwonToMillion(1524), 15.24);
    expect(manwonToEok(1524), .1524);
    expect(manwonToEok(0), 0);
  });
  test('47열과 원본값을 보존하고 YYYYMM을 정규화한다', () {
    final row = trafficTestRow();
    row[35] = '원본 메모';
    row[46] = 100000000;
    final result = parse([row]);
    expect(result.accepted.single.orderMonth, '2026-10');
    expect(result.accepted.single.salesMillion, 15.24);
    expect(result.accepted.single.values[35], '원본 메모');
    expect(result.accepted.single.values.length, 47);
    expect(result.accepted.single.values[46], '100000000');
  });
  test('고객 원본의 164 미만 사용자 서식 번호를 메모리에서만 호환 처리한다', () {
    final bytes = DesktopFileService.createWorkbookBytes(
        sheetName: '물동', headers: trafficHeaders, rows: [trafficTestRow()]);
    final archive = ZipDecoder().decodeBytes(bytes);
    final styles = archive.findFile('xl/styles.xml')!;
    final document =
        XmlDocument.parse(utf8.decode(styles.content as List<int>));
    final formats = XmlElement(XmlName('numFmts'));
    document.rootElement.children.insert(0, formats);
    formats.children.add(XmlElement(XmlName('numFmt'), [
      XmlAttribute(XmlName('numFmtId'), '41'),
      XmlAttribute(XmlName('formatCode'), '#,##0.00'),
    ]));
    formats.setAttribute('count', '${formats.findElements('numFmt').length}');
    for (final xf in document.findAllElements('xf')) {
      if (xf.getAttribute('numFmtId') == '0') xf.setAttribute('numFmtId', '41');
    }
    final styleBytes = utf8.encode(document.toXmlString());
    final fixture = Archive();
    for (final entry in archive.files) {
      fixture.addFile(entry.name == styles.name
          ? ArchiveFile(entry.name, styleBytes.length, styleBytes)
          : entry);
    }
    final customerBytes = ZipEncoder().encode(fixture)!;
    final before = List<int>.from(customerBytes);
    final result = TrafficExcelService.parse(customerBytes,
        existingFingerprints: {},
        existingErpNumbers: {},
        divisionAliases: {'ROBOT'});
    expect(result.accepted.single.salesMillion, 15.24);
    expect(customerBytes, before);
  });
  test('기존/파일 내 중복은 자동 등록/수정하지 않는다', () {
    final result = parse(
        [trafficTestRow(), trafficTestRow(), trafficTestRow(project: '기존')],
        existing: {trafficFingerprint('기존', '신규고객', '2026-10')});
    expect(result.accepted.length, 1);
    expect(result.rows.where((r) => r.duplicate).length, 2);
  });
  test('중복 ERP 번호도 검토 대상으로 보류한다', () {
    final result = parse([
      trafficTestRow(erp: 'A-001'),
      trafficTestRow(project: '다른건', erp: 'a-001')
    ]);
    expect(result.accepted.length, 1);
  });
  test('빈값/날짜/사업부/숫자/단계 오류는 행과 열을 표시한다', () {
    final row = trafficTestRow();
    row[1] = '202613';
    row[6] = '플랫폼';
    row[18] = '';
    row[21] = 'Proposal';
    row[28] = 0;
    row[30] = 'abc';
    final result = parse([row]);
    expect(result.accepted, isEmpty);
    expect(result.rows.single.errors.join(), contains('AE2'));
    expect(result.rows.single.errors.join(), contains('B2'));
    expect(result.rows.single.errors.join(), contains('G2'));
  });
  test('수식 금액/무한대/빈 금액은 0으로 등록하지 않는다', () {
    for (final value in ['=A1*2', 'Infinity', null, -1, '1e308']) {
      final row = trafficTestRow();
      row[30] = value;
      expect(parse([row]).accepted, isEmpty);
    }
    final zero = trafficTestRow();
    zero[30] = 0;
    zero[31] = 0;
    expect(parse([zero]).accepted.length, 1);
  });
  test('외화는 양의 환율과 명시적 원화 합계가 필요하며 원본을 보존한다', () {
    final row = trafficTestRow();
    row[24] = 'USD';
    row[26] = 100;
    expect(parse([row]).accepted, isEmpty);
    row[25] = 1300;
    expect(parse([row]).accepted.single.values[26], '100');
    expect(parse([row]).accepted.single.warnings, isNotEmpty);
  });
  test('원본처럼 3행 헤더를 인식하고 수식 보조열은 그대로 보존한다', () {
    final workbook = Excel.createExcel();
    final sheet = workbook['물동 입력'];
    sheet.appendRow([TextCellValue('안내')]);
    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow(trafficHeaders.map(TextCellValue.new).toList());
    sheet.appendRow(trafficTestRow()
        .map((v) => TextCellValue(v?.toString() ?? ''))
        .toList());
    sheet.cell(CellIndex.indexByString('AQ4')).value =
        const FormulaCellValue('AE4*100000');
    final result = TrafficExcelService.parse(workbook.encode()!,
        existingFingerprints: {},
        existingErpNumbers: {},
        divisionAliases: {'ROBOT'});
    expect(result.accepted.single.row, 4);
    expect(result.accepted.single.values[42], contains('AE4*100000'));
  });
  test('다른 스키마/56열 예시/빈 양식은 등록하지 않는다', () {
    expect(
        () => TrafficExcelService.parse(
            DesktopFileService.createWorkbookBytes(
                sheetName: '물동', headers: List.filled(56, '다른 항목'), rows: []),
            existingFingerprints: {},
            existingErpNumbers: {},
            divisionAliases: {'ROBOT'}),
        throwsFormatException);
    expect(() => parse([]), throwsFormatException);
  });
}
