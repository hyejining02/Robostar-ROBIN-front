import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/services.dart';

class SelectedDesktopFile {
  final String path;
  final String name;

  const SelectedDesktopFile({required this.path, required this.name});
}

class DesktopFileService {
  const DesktopFileService._();

  static const _fileDialog = MethodChannel('robin_portal/file_dialog');

  static Future<SelectedDesktopFile?> pickDocument({
    List<String> extensions = const ['pdf', 'xlsx', 'xls', 'dwg', 'step'],
  }) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('ROBIN 파일 대화상자는 현재 Windows에서 지원됩니다.');
    }
    final receiptOnly = extensions.every(
      (extension) => const ['pdf', 'png', 'jpg', 'jpeg'].contains(extension),
    );
    final path = await _fileDialog.invokeMethod<String>(
      'openFile',
      {'receiptOnly': receiptOnly},
    );
    if (path == null) return null;
    return SelectedDesktopFile(
      path: path,
      name: path.split(Platform.pathSeparator).last,
    );
  }

  static Future<String?> saveWorkbook({
    required String suggestedName,
    required String sheetName,
    required List<String> headers,
    required List<List<Object?>> rows,
  }) async {
    final path = await _fileDialog.invokeMethod<String>(
      'saveFile',
      {'suggestedName': suggestedName},
    );
    if (path == null) return null;
    final bytes = createWorkbookBytes(
      sheetName: sheetName,
      headers: headers,
      rows: rows,
    );
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  static List<int> createWorkbookBytes({
    required String sheetName,
    required List<String> headers,
    required List<List<Object?>> rows,
  }) {
    final workbook = Excel.createExcel();
    final defaultSheet = workbook.getDefaultSheet();
    final sheet = workbook[sheetName];
    if (defaultSheet != null && defaultSheet != sheetName) {
      workbook.delete(defaultSheet);
    }
    sheet.appendRow(headers.map(TextCellValue.new).toList());
    for (final row in rows) {
      sheet.appendRow(row.map(_cellValue).toList());
    }
    return workbook.encode() ?? const [];
  }

  static CellValue _cellValue(Object? value) => switch (value) {
        int number => IntCellValue(number),
        double number => DoubleCellValue(number),
        bool flag => BoolCellValue(flag),
        _ => TextCellValue(value?.toString() ?? ''),
      };

  static Future<String?> saveCopy({
    required String sourcePath,
    required String suggestedName,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) return null;
    final path = await _fileDialog.invokeMethod<String>(
      'saveFile',
      {'suggestedName': suggestedName},
    );
    if (path == null) return null;
    await source.copy(path);
    return path;
  }

  static Future<void> openWithDefaultApp(String path) async {
    if (!await File(path).exists()) {
      throw FileSystemException('파일을 찾을 수 없습니다.', path);
    }
    if (Platform.isWindows) {
      await Process.start('explorer.exe', [path],
          mode: ProcessStartMode.detached);
      return;
    }
    if (Platform.isMacOS) {
      await Process.start('open', [path], mode: ProcessStartMode.detached);
      return;
    }
    await Process.start('xdg-open', [path], mode: ProcessStartMode.detached);
  }
}
