import 'package:flutter/material.dart';
import '../theme/robin_theme.dart';

Widget platformTable(
        {required Key key,
        required List<String> headers,
        required List<TableRow> rows,
        required List<double> widths,
        double minWidth = 820}) =>
    LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: c.maxWidth < minWidth ? minWidth : c.maxWidth,
                child: Table(
                  key: key,
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    for (var i = 0; i < widths.length; i++)
                      i: FlexColumnWidth(widths[i])
                  },
                  border: const TableBorder(
                      horizontalInside:
                          BorderSide(color: RobinTheme.border, width: .6)),
                  children: [
                    TableRow(
                        decoration:
                            const BoxDecoration(color: RobinTheme.background),
                        children: [
                          for (final h in headers)
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 7),
                                child: Text(h,
                                    style: RobinTheme.labelXs.copyWith(
                                        fontWeight: FontWeight.w600))),
                        ]),
                    ...rows
                  ],
                ),
              ),
            ));

Widget platformTableCell(Widget child, {bool right = false}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: Align(
        alignment: right ? Alignment.centerRight : Alignment.centerLeft,
        child: child));

Widget platformTableText(String value,
        {bool right = false, bool strong = false}) =>
    platformTableCell(
        Text(value,
            style: strong
                ? RobinTheme.bodySm.copyWith(fontWeight: FontWeight.w600)
                : RobinTheme.bodySm),
        right: right);

Widget platformInlineFields(List<Widget> fields, {int columns = 2}) =>
    LayoutBuilder(builder: (context, c) {
      final count = c.maxWidth < 540 ? 1 : columns;
      return Wrap(spacing: 10, runSpacing: 10, children: [
        for (final f in fields)
          SizedBox(width: (c.maxWidth - (count - 1) * 10) / count, child: f)
      ]);
    });

Widget platformActionBar({required Widget actions, Widget? status}) =>
    Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(color: RobinTheme.primary, width: 2),
              bottom: BorderSide(color: RobinTheme.border),
              left: BorderSide(color: RobinTheme.border),
              right: BorderSide(color: RobinTheme.border))),
      child: LayoutBuilder(
          builder: (context, c) => c.maxWidth < 540
              ? Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if (status != null) status,
                  const SizedBox(height: 6),
                  actions
                ])
              : Row(children: [
                  if (status != null)
                    Expanded(child: status)
                  else
                    const Spacer(),
                  const SizedBox(width: 8),
                  actions
                ])),
    );
