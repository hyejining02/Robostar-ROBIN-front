import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../services/desktop_file_service.dart';
import '../services/platform_quote_pdf_service.dart';

/// The preview, print job and downloaded PDF use the exact same byte buffer.
class PlatformQuotePreview extends StatefulWidget {
  final PlatformQuoteDocument quote;
  const PlatformQuotePreview({super.key, required this.quote});

  static Future<void> open(BuildContext context, PlatformQuoteDocument quote) =>
      showDialog<void>(
          context: context, builder: (_) => PlatformQuotePreview(quote: quote));

  static Future<void> printDocument(PlatformQuoteDocument quote,
      {Uint8List? bytes}) async {
    final pdf = bytes ?? await PlatformQuotePdfService.generate(quote);
    await Printing.layoutPdf(
        onLayout: (_) async => pdf,
        name: quote.fileName,
        format: PdfPageFormat.a4,
        dynamicLayout: false);
  }

  @override
  State<PlatformQuotePreview> createState() => _PlatformQuotePreviewState();
}

class _PlatformQuotePreviewState extends State<PlatformQuotePreview> {
  late final Future<Uint8List> document =
      PlatformQuotePdfService.generate(widget.quote);
  bool busy = false;
  String message = '';

  Future<void> output({bool print = false}) async {
    setState(() {
      busy = true;
      message = '';
    });
    try {
      final bytes = await document;
      if (print) {
        await PlatformQuotePreview.printDocument(widget.quote, bytes: bytes);
      } else {
        final path =
            await DesktopFileService.savePdfBytes(bytes, widget.quote.fileName);
        if (mounted && path != null) {
          setState(() => message = 'PDF 저장 완료: $path');
        }
      }
    } catch (e) {
      if (mounted) setState(() => message = '견적서 출력 실패: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        child: SizedBox(
            width: 980,
            height: size.height * .9,
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 10),
                  child: Row(children: [
                    Expanded(
                        child: Text(
                            '견적서 미리보기${widget.quote.revision == null ? '' : ' · Rev.${widget.quote.revision}'}',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold))),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: '닫기',
                        icon: const Icon(Icons.close)),
                  ])),
              const Divider(height: 1),
              Expanded(
                  child: FutureBuilder<Uint8List>(
                      future: document,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('견적서 생성 실패: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return PdfPreview(
                            build: (_) async => snapshot.data!,
                            initialPageFormat: PdfPageFormat.a4,
                            maxPageWidth: 760,
                            canChangePageFormat: false,
                            canChangeOrientation: false,
                            canDebug: false,
                            useActions: false,
                            allowPrinting: false,
                            allowSharing: false,
                            onError: (_, error) => Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                        '미리보기를 표시하지 못했습니다. PDF 저장 후 확인할 수 있습니다.\n$error'))));
                      })),
              const Divider(height: 1),
              if (message.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: SelectableText(message)),
              Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('닫기')),
                        OutlinedButton.icon(
                            onPressed: busy ? null : () => output(),
                            icon: const Icon(Icons.download, size: 17),
                            label: const Text('PDF 저장')),
                        FilledButton.icon(
                            onPressed: busy ? null : () => output(print: true),
                            icon: const Icon(Icons.print, size: 17),
                            label: const Text('인쇄·PDF')),
                      ])),
            ])));
  }
}
