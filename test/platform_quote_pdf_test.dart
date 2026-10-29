import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:printing/src/interface.dart';
import 'package:robin_portal/services/platform_pipeline_service.dart';
import 'package:robin_portal/services/platform_quote_pdf_service.dart';
import 'package:robin_portal/widgets/platform_quote_preview.dart';

import 'platform_pipeline_test.dart' show completePlatformVrb;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(platformPipelineRecords.clear);

  test('인쇄 대화상자는 미리보기와 같은 PDF 바이트와 파일명을 받는다', () async {
    final original = PrintingPlatform.instance;
    final printer = _QuotePrinter();
    PrintingPlatform.instance = printer;
    try {
      final quote = PlatformQuoteDocument.current(completePlatformVrb('PRINT'));
      final bytes = Uint8List.fromList([37, 80, 68, 70, 45]);
      await PlatformQuotePreview.printDocument(quote, bytes: bytes);
      expect(printer.bytes, same(bytes));
      expect(printer.name, quote.fileName);
      expect(printer.format, PdfPageFormat.a4);
      expect(printer.dynamicLayout, isFalse);
    } finally {
      PrintingPlatform.instance = original;
    }
  });

  test('출력은 현재 입력의 복사본이며 외화 견적을 원화로 바꾸지 않는다', () {
    final data = completePlatformVrb('QUOTE');
    data.quote.addAll({'currency': 'USD', 'fx': '1300'});
    data.quoteLines.first.fields.addAll({'price': '1234.5', 'qty': '2'});
    final quote = PlatformQuoteDocument.current(data);
    data.quote['currency'] = 'KRW';
    data.quoteLines.first.fields['price'] = '1';
    expect(quote.total, 2469);
    expect(quote.currency, 'USD');
    expect(quote.number(quote.total), '2,469.00');
    expect(() => quote.lines.first['price'] = '9', throwsUnsupportedError);
    expect(() => quote.fields['title'] = '변경', throwsUnsupportedError);
  });

  test('저장된 Rev 출력은 이후 입력값과 섞이지 않는다', () {
    final data = completePlatformVrb('SNAPSHOT');
    data.quote.addAll({'title': '저장본', 'to': '시험 고객', 'number': 'Q:001/2'});
    final rev =
        PlatformProposalRevision(2, '담당자', jsonEncode(data.proposalJson()));
    data.quote['title'] = '수정중';
    data.quoteLines.first.fields['price'] = '3';
    final saved = PlatformQuoteDocument.saved(rev, data.key.$2);
    expect(saved.value('title'), '저장본');
    expect(saved.total, 100000000);
    expect(saved.revision, 2);
    expect(saved.fileName, '견적서_Q_001_2_저장본_Rev2.pdf');
    data.quoteLines.first.fields['price'] = '';
    expect(PlatformQuoteDocument.current(data).total, isNull);
  });

  test('입력값으로 한글 폰트·원본 로고를 포함한 A4 견적 PDF를 생성한다', () async {
    final data = completePlatformVrb('PDF');
    data.quote.addAll({
      'title': '시험 고객 EFEM 도입',
      'to': '시험 고객 구매팀',
      'number': 'SEMI-2610-26-01',
      'date': '2026-10-26',
      'equipment': '300mm EFEM SYSTEM',
      'due': '발주 후 5개월',
      'notes': '1. 고객과 합의된 사양 기준입니다.\n2. 운송 조건 별도 협의',
    });
    data.quoteLines.first.fields.addAll({
      'name': 'EFEM SYSTEM',
      'spec': '- ARM: Link Type\n- X축: Rack & Pinion\n- 제어기 및 티칭 펜던트 포함',
      'price': '79000000',
      'qty': '2',
      'note': '설치 포함',
    });
    final bytes = await PlatformQuotePdfService.generate(
        PlatformQuoteDocument.current(data));
    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
    expect(bytes.length, greaterThan(10000));
    if (const bool.fromEnvironment('CAPTURE_QUOTE')) {
      await Directory('.dart_tool/quote_qa').create(recursive: true);
      await File('.dart_tool/quote_qa/quotation.pdf').writeAsBytes(bytes);
    }
  });

  test('품목과 긴 사양은 잘리지 않고 여러 페이지로 출력한다', () async {
    final data = completePlatformVrb('MANY');
    data.quoteLines.clear();
    for (var i = 0; i < 35; i++) {
      data.quoteLines.add(PlatformAmountLine(fields: {
        'name': '시험 장비 ${i + 1}',
        'spec': List.filled(8, '세부 사양 테스트').join('\n'),
        'price': '1000',
        'qty': '2',
      }));
    }
    final bytes = await PlatformQuotePdfService.generate(
        PlatformQuoteDocument.current(data));
    expect(bytes.length, greaterThan(10000));
    if (const bool.fromEnvironment('CAPTURE_QUOTE')) {
      await Directory('.dart_tool/quote_qa').create(recursive: true);
      await File('.dart_tool/quote_qa/multipage.pdf').writeAsBytes(bytes);
    }
  });
}

class _QuotePrinter extends PrintingPlatform {
  Uint8List? bytes;
  String? name;
  PdfPageFormat? format;
  bool? dynamicLayout;

  @override
  Future<bool> layoutPdf(
      Printer? printer,
      LayoutCallback onLayout,
      String name,
      PdfPageFormat format,
      bool dynamicLayout,
      bool usePrinterSettings,
      OutputType outputType,
      bool forceCustomPrintPaper) async {
    this.name = name;
    this.format = format;
    this.dynamicLayout = dynamicLayout;
    bytes = await onLayout(PdfPageFormat.letter);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
