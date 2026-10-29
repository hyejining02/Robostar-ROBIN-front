import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_selector/file_selector.dart' as selector;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SelectedDesktopFile {
  final String path;
  final String name;
  final selector.XFile? source;

  const SelectedDesktopFile(
      {required this.path, required this.name, this.source});
}

class DesktopFileService {
  const DesktopFileService._();

  static const _fileDialog = MethodChannel('robin_portal/file_dialog');

  /// Cross-platform Excel picker, including Chrome/Edge debug sessions.
  static Future<SelectedDesktopFile?> pickWorkbook() async {
    return pickReferenceDocument(extensions: const ['xlsx']);
  }

  static Future<SelectedDesktopFile?> pickReferenceDocument({
    List<String> extensions = const [
      'pdf',
      'xlsx',
      'xls',
      'dwg',
      'step',
      'stp',
      'png',
      'jpg',
      'jpeg'
    ],
  }) async {
    final file = await selector.openFile(acceptedTypeGroups: [
      selector.XTypeGroup(label: 'ROBIN 첨부', extensions: extensions),
    ]);
    if (file == null) return null;
    if (await file.length() > 20 * 1024 * 1024) {
      throw const FormatException('20MB 이하 파일만 첨부할 수 있습니다.');
    }
    return SelectedDesktopFile(path: file.path, name: file.name, source: file);
  }

  static Future<String?> saveSelectedDocument(SelectedDesktopFile file) async {
    final source = file.source ?? selector.XFile(file.path);
    final String path;
    if (kIsWeb) {
      path = file.name;
    } else {
      final location = await selector.getSaveLocation(suggestedName: file.name);
      if (location == null) return null;
      path = location.path;
    }
    await source.saveTo(path);
    return path;
  }

  static Future<String?> savePdfBytes(
      Uint8List bytes, String suggestedName) async {
    final String path;
    if (kIsWeb) {
      path = suggestedName;
    } else {
      final location = await selector.getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: const [
          selector.XTypeGroup(label: 'PDF (.pdf)', extensions: ['pdf']),
        ],
      );
      if (location == null) return null;
      path = location.path;
    }
    await selector.XFile.fromData(bytes,
            name: suggestedName, mimeType: 'application/pdf')
        .saveTo(path);
    return path;
  }

  static Future<SelectedDesktopFile?> pickDocument({
    List<String> extensions = const ['pdf', 'xlsx', 'xls', 'dwg', 'step'],
  }) async {
    if (kIsWeb || !Platform.isWindows) {
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

  static Future<List<int>> readWorkbook(SelectedDesktopFile file) async {
    if (!file.name.toLowerCase().endsWith('.xlsx')) {
      throw const FormatException(
          '.xlsx 파일만 지원합니다. .xls는 Excel에서 .xlsx로 저장해주세요.');
    }
    final source = file.source ?? selector.XFile(file.path);
    if (await source.length() > 20 * 1024 * 1024) {
      throw const FormatException('20MB 이하 파일만 불러올 수 있습니다.');
    }
    return source.readAsBytes();
  }

  static Future<String?> saveWorkbook({
    required String suggestedName,
    required String sheetName,
    required List<String> headers,
    required List<List<Object?>> rows,
  }) async {
    // A browser downloads a Blob; it cannot invoke the Windows saveFile channel.
    // Select the native target before generating bytes so cancel has no side effects.
    final String path;
    if (kIsWeb) {
      path = suggestedName;
    } else {
      final location = await selector.getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: const [
          selector.XTypeGroup(label: 'Excel (.xlsx)', extensions: ['xlsx']),
        ],
      );
      if (location == null) return null;
      path = location.path;
    }
    final bytes = createWorkbookBytes(
      sheetName: sheetName,
      headers: headers,
      rows: rows,
    );
    await selector.XFile.fromData(
      Uint8List.fromList(bytes),
      name: suggestedName,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ).saveTo(path);
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
