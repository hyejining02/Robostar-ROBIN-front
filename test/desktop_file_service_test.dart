import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/services/desktop_file_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FileSelectorPlatform original;
  late _FileDialogs dialogs;
  setUp(() {
    original = FileSelectorPlatform.instance;
    dialogs = _FileDialogs();
    FileSelectorPlatform.instance = dialogs;
  });
  tearDown(() => FileSelectorPlatform.instance = original);

  test('Excel 파일 선택 취소를 처리한다', () async {
    expect(await DesktopFileService.pickWorkbook(), isNull);
    expect(dialogs.extensions, ['xlsx']);
  });

  test('웹 Blob/네이티브 XFile을 파일 경로에 의존하지 않고 읽는다', () async {
    final bytes =
        DesktopFileService.createWorkbookBytes(sheetName: '입력', headers: [
      'PJT명'
    ], rows: [
      ['테스트']
    ]);
    dialogs.selected = XFile.fromData(Uint8List.fromList(bytes),
        name: '입력.xlsx', path: '입력.xlsx');
    final file = (await DesktopFileService.pickWorkbook())!;
    expect(file.name, '입력.xlsx');
    expect(await DesktopFileService.readWorkbook(file), bytes);
  });

  test('다른 파일 형식과 20MB 초과 파일을 거부한다', () async {
    await expectLater(
        DesktopFileService.readWorkbook(
            const SelectedDesktopFile(path: 'wrong.xls', name: 'wrong.xls')),
        throwsFormatException);
    await expectLater(
        DesktopFileService.readWorkbook(SelectedDesktopFile(
            path: '', name: 'large.xlsx', source: _LargeFile())),
        throwsFormatException);
  });

  test('웹은 Windows 채널 없이 다운로드, 네이티브는 선택한 경로에 저장한다', () async {
    Directory? temp;
    if (!kIsWeb) {
      temp = await Directory.systemTemp.createTemp('robin_excel_test_');
      dialogs.savePath = '${temp.path}${Platform.pathSeparator}양식.xlsx';
    }
    try {
      final result = await DesktopFileService.saveWorkbook(
          suggestedName: 'ROBIN_file_service_test.xlsx',
          sheetName: '물동',
          headers: ['PJT명'],
          rows: []);
      if (kIsWeb) {
        expect(result, 'ROBIN_file_service_test.xlsx');
        expect(dialogs.saveCalled, isFalse);
      } else {
        expect(result, dialogs.savePath);
        final workbook = Excel.decodeBytes(await File(result!).readAsBytes());
        expect(workbook.tables['물동']!.rows.first.first!.value,
            TextCellValue('PJT명'));
      }
    } finally {
      if (temp != null) await temp.delete(recursive: true);
    }
  });

  test('네이티브 저장 취소는 파일을 생성하지 않는다', () async {
    if (kIsWeb) return;
    expect(
        await DesktopFileService.saveWorkbook(
            suggestedName: '취소.xlsx', sheetName: '입력', headers: [], rows: []),
        isNull);
  });

  test('PDF 저장 취소와 선택한 경로의 바이트 보존을 처리한다', () async {
    if (kIsWeb) return;
    final bytes = Uint8List.fromList([37, 80, 68, 70, 45]);
    expect(await DesktopFileService.savePdfBytes(bytes, '견적서.pdf'), isNull);
    final temp = await Directory.systemTemp.createTemp('robin_pdf_test_');
    try {
      dialogs.savePath = '${temp.path}${Platform.pathSeparator}견적서.pdf';
      final saved = await DesktopFileService.savePdfBytes(bytes, '견적서.pdf');
      expect(saved, dialogs.savePath);
      expect(await File(saved!).readAsBytes(), bytes);
    } finally {
      await temp.delete(recursive: true);
    }
  });

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

class _FileDialogs extends FileSelectorPlatform {
  XFile? selected;
  String? savePath;
  List<String>? extensions;
  bool saveCalled = false;
  @override
  Future<XFile?> openFile(
      {List<XTypeGroup>? acceptedTypeGroups,
      String? initialDirectory,
      String? confirmButtonText}) async {
    extensions = acceptedTypeGroups?.single.extensions;
    return selected;
  }

  @override
  Future<FileSaveLocation?> getSaveLocation(
      {List<XTypeGroup>? acceptedTypeGroups,
      SaveDialogOptions options = const SaveDialogOptions()}) async {
    saveCalled = true;
    return savePath == null ? null : FileSaveLocation(savePath!);
  }
}

class _LargeFile extends XFile {
  _LargeFile() : super('unused');
  @override
  Future<int> length() async => 20 * 1024 * 1024 + 1;
}
