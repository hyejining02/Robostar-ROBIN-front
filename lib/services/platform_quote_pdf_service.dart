import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'platform_pipeline_service.dart';

/// An immutable quote snapshot: preview, printing and saving share these values.
class PlatformQuoteDocument {
  final Map<String, String> fields;
  final List<Map<String, String>> lines;
  final String pipelineNumber;
  final int? revision;

  PlatformQuoteDocument._(Map<String, String> fields,
      Iterable<Map<String, String>> lines, this.pipelineNumber, this.revision)
      : fields = Map.unmodifiable(fields),
        lines = List.unmodifiable(
            lines.map((l) => Map<String, String>.unmodifiable(l)));

  factory PlatformQuoteDocument.current(PlatformPipelineData data) =>
      PlatformQuoteDocument._(
          data.quote, data.quoteLines.map((l) => l.fields), data.key.$2, null);

  factory PlatformQuoteDocument.saved(
      PlatformProposalRevision revision, String pipelineNumber) {
    final saved = revision.data;
    return PlatformQuoteDocument._(
        Map<String, String>.from(saved['quote'] as Map),
        (saved['lines'] as List).map((l) => Map<String, String>.from(l as Map)),
        pipelineNumber,
        revision.revision);
  }

  String value(String key) => fields[key]?.trim() ?? '';
  String get currency => value('currency').isEmpty ? 'KRW' : value('currency');
  double? amount(Map<String, String> line) {
    final price = platformNumber(line['price']);
    final qty = platformNumber(line['qty']);
    if (price == null || qty == null) return null;
    final result = price * qty;
    return result.isFinite ? result : null;
  }

  double? get total {
    if (lines.isEmpty) return null;
    var result = 0.0;
    for (final line in lines) {
      final a = amount(line);
      if (a == null) return null;
      result += a;
    }
    return result.isFinite ? result : null;
  }

  String number(num? amount) => amount == null
      ? '미산출'
      : NumberFormat(
              currency == 'KRW' || currency == 'JPY' ? '#,##0.##' : '#,##0.00',
              'en_US')
          .format(amount);

  String get fileName {
    final name = [
      value('number').isEmpty ? pipelineNumber : value('number'),
      value('title'),
      if (revision != null) 'Rev$revision'
    ].join('_').replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_');
    return '견적서_${name.length > 120 ? name.substring(0, 120) : name}.pdf';
  }
}

/// A4 recreation of the supplied VRB workbook's 견적서 worksheet.
/// Only quotation fields are exposed; internal VRB costs are never exported.
class PlatformQuotePdfService {
  PlatformQuotePdfService._();

  static Future<Uint8List> generate(PlatformQuoteDocument quote) async {
    final regular =
        pw.Font.ttf(await rootBundle.load('assets/quote/LGSmartRegular.ttf'));
    final bold =
        pw.Font.ttf(await rootBundle.load('assets/quote/LGSmartBold.ttf'));
    final logoData = await rootBundle.load('assets/quote/logo.png');
    final sealData = await rootBundle.load('assets/quote/seal.png');
    final logo = pw.MemoryImage(logoData.buffer
        .asUint8List(logoData.offsetInBytes, logoData.lengthInBytes));
    final seal = pw.MemoryImage(sealData.buffer
        .asUint8List(sealData.offsetInBytes, sealData.lengthInBytes));
    final document =
        pw.Document(title: '견적서 ${quote.value('title')}', author: '주식회사 로보스타');
    final date = DateTime.tryParse(quote.value('date'));
    final dateText = date == null
        ? quote.value('date')
        : '${date.year}년 ${date.month}월 ${date.day}일';
    final conditions = [
      ['金    額', '견적 내역 참고 (VAT 별도 / ${quote.currency})'],
      ['見積 No.', quote.value('number')],
      ['見 積 日', dateText],
      ['引渡條件', quote.value('delivery')],
      ['納    期', quote.value('due')],
      ['支拂條件', quote.value('payment')],
      [
        '有效期間',
        quote.value('validDays').isEmpty
            ? ''
            : '견적일부터 ${quote.value('validDays')}일'
      ],
      ['見積內譯', '아래의 표와 같습니다.'],
    ];
    pw.Widget cell(String text,
            {bool bold = false,
            pw.TextAlign align = pw.TextAlign.left,
            double height = 0}) =>
        pw.Container(
            alignment: align == pw.TextAlign.right
                ? pw.Alignment.centerRight
                : align == pw.TextAlign.center
                    ? pw.Alignment.center
                    : pw.Alignment.centerLeft,
            constraints: pw.BoxConstraints(minHeight: height),
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
            child: pw.Text(text,
                textAlign: align,
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight:
                        bold ? pw.FontWeight.bold : pw.FontWeight.normal)));
    final rows = <pw.TableRow>[
      pw.TableRow(
          repeat: true,
          decoration: const pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border(bottom: pw.BorderSide(width: .8))),
          children: [
            for (final title in [
              '번호',
              '품명 및 규격',
              '단위',
              '수량',
              '단 가',
              '금 액',
              '특기사항'
            ])
              cell(title, bold: true, align: pw.TextAlign.center),
          ]),
    ];
    for (var i = 0; i < quote.lines.length; i++) {
      final line = quote.lines[i];
      rows.add(pw.TableRow(children: [
        cell('${i + 1}', align: pw.TextAlign.center),
        cell(line['name'] ?? '', bold: true),
        cell(line['unit'] ?? ''),
        cell(line['qty'] ?? '', align: pw.TextAlign.right),
        cell(quote.number(platformNumber(line['price'])),
            align: pw.TextAlign.right),
        cell(quote.number(quote.amount(line)), align: pw.TextAlign.right),
        cell(line['note'] ?? ''),
      ]));
      // Short specification rows can span pages, including a single long item.
      for (final spec in _paragraphs(line['spec'] ?? '', 65)) {
        rows.add(pw.TableRow(children: [
          cell(''),
          cell(spec),
          for (var n = 0; n < 5; n++) cell('')
        ]));
      }
    }
    if (rows.length < 7) {
      for (var i = rows.length; i < 7; i++) {
        rows.add(pw.TableRow(
            children: [for (var n = 0; n < 7; n++) cell('', height: 24)]));
      }
    }
    rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(
            color: PdfColors.grey100,
            border: pw.Border(top: pw.BorderSide(width: .8))),
        children: [
          cell(''),
          cell('${quote.value('equipment')} 금액', bold: true),
          cell('SET'),
          cell('1'),
          cell(''),
          cell(quote.number(quote.total),
              bold: true, align: pw.TextAlign.right),
          cell('')
        ]));
    document.addPage(pw.MultiPage(
      maxPages: 200,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 30, 36, 30),
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
      header: (context) => context.pageNumber == 1
          ? pw.SizedBox()
          : pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Text(
                  '견적서 · ${quote.value('number')} · ${quote.value('title')}',
                  style: const pw.TextStyle(fontSize: 9))),
      footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('http://www.robostar.co.kr',
                    style: const pw.TextStyle(fontSize: 9)),
                pw.Text('${context.pageNumber} / ${context.pagesCount}',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Text('㈜로보스타',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 16)),
              ])),
      build: (context) => [
        pw.Center(
            child: pw.Text('見  積  書',
                style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline))),
        pw.SizedBox(height: 20),
        pw.Text('견적명 : ${quote.value('title')}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(
              flex: 7,
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('[수신인 : ${quote.value('to')}]'),
                    pw.SizedBox(height: 14),
                    pw.Text('아래와 같이 見積을 提出하오니 검토하여 주시기 바랍니다.',
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.SizedBox(height: 10),
                    for (var i = 0; i < conditions.length; i++)
                      pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 3),
                          child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                    width: 14,
                                    child: pw.Text('${i + 1}.',
                                        style:
                                            const pw.TextStyle(fontSize: 9))),
                                pw.SizedBox(
                                    width: 58,
                                    child: pw.Text('${conditions[i][0]} :',
                                        style:
                                            const pw.TextStyle(fontSize: 9))),
                                pw.Expanded(
                                    child: pw.Text(conditions[i][1],
                                        style:
                                            const pw.TextStyle(fontSize: 9))),
                              ])),
                  ])),
          pw.SizedBox(width: 12),
          pw.Expanded(
              flex: 3,
              child: pw.Column(children: [
                pw.Image(logo, width: 140),
                pw.SizedBox(height: 16),
                pw.Text('주식회사 로보스타',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 36),
                pw.Image(seal, width: 60, height: 63),
              ])),
        ]),
        pw.SizedBox(height: 16),
        pw.Text(quote.value('equipment'),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table(
            border: const pw.TableBorder(
                top: pw.BorderSide(width: .8),
                bottom: pw.BorderSide(width: .8),
                left: pw.BorderSide(width: .5, color: PdfColors.grey500),
                right: pw.BorderSide(width: .5, color: PdfColors.grey500),
                verticalInside:
                    pw.BorderSide(width: .5, color: PdfColors.grey500)),
            columnWidths: const {
              0: pw.FlexColumnWidth(.6),
              1: pw.FlexColumnWidth(3.6),
              2: pw.FlexColumnWidth(.55),
              3: pw.FlexColumnWidth(.65),
              4: pw.FlexColumnWidth(1.4),
              5: pw.FlexColumnWidth(1.4),
              6: pw.FlexColumnWidth(1)
            },
            children: rows),
        pw.SizedBox(height: 12),
        pw.Text('※ 특기사항',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        pw.SizedBox(height: 5),
        for (final note in _paragraphs(quote.value('notes'), 100))
          pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Text(note, style: const pw.TextStyle(fontSize: 9))),
        pw.SizedBox(height: 14),
        pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: .8)),
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('최종 금액',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      '${quote.number(quote.total)} ${quote.currency} (VAT 별도)',
                      style: pw.TextStyle(
                          fontSize: 13, fontWeight: pw.FontWeight.bold)),
                ])),
      ],
    ));
    return document.save();
  }

  static Iterable<String> _paragraphs(String text, int limit) sync* {
    for (final line in text.split('\n')) {
      if (line.trim().isEmpty) continue;
      final chars = line.runes.toList();
      for (var i = 0; i < chars.length; i += limit) {
        yield String.fromCharCodes(chars.sublist(
            i, i + limit < chars.length ? i + limit : chars.length));
      }
    }
  }
}
