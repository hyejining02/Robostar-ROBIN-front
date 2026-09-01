import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/services/desktop_file_service.dart';

void main() {
  test('Excel 다운로드용 XLSX 데이터를 생성한다', () {
    final bytes = DesktopFileService.createWorkbookBytes(
      sheetName: '마감이력',
      headers: const ['수주번호', '고객사', '금액'],
      rows: const [
        ['SO-2608-014', 'A사', 1450],
        ['SO-2608-011', 'B사', 1180],
      ],
    );

    expect(bytes, isNotEmpty);
    final workbook = Excel.decodeBytes(bytes);
    final sheet = workbook.tables['마감이력'];
    expect(sheet, isNotNull);
    expect(sheet!.maxColumns, 3);
    expect(sheet.maxRows, 3);
    expect(sheet.rows.first.first?.value, TextCellValue('수주번호'));
    expect(sheet.rows[1][2]?.value, const IntCellValue(1450));
  });
}
