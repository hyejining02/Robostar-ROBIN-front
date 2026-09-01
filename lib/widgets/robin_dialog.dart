// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

import '../theme/robin_theme.dart';

/// ROBIN 공통 브라우저형 팝업.
///
/// 기존 [AlertDialog]의 사용법은 유지하면서 제목/본문/버튼 영역을
/// 명확한 구분선으로 나눈다.
class RobinAlertDialog extends AlertDialog {
  RobinAlertDialog({
    super.key,
    Widget? icon,
    EdgeInsetsGeometry? iconPadding,
    Color? iconColor,
    Widget? title,
    EdgeInsetsGeometry? titlePadding,
    TextStyle? titleTextStyle,
    Widget? content,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? contentTextStyle,
    List<Widget>? actions,
    EdgeInsetsGeometry? actionsPadding,
    MainAxisAlignment? actionsAlignment,
    OverflowBarAlignment? actionsOverflowAlignment,
    VerticalDirection? actionsOverflowDirection,
    double? actionsOverflowButtonSpacing,
    EdgeInsetsGeometry? buttonPadding,
    Color? backgroundColor,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    String? semanticLabel,
    EdgeInsets? insetPadding,
    Clip clipBehavior = Clip.none,
    ShapeBorder? shape,
    AlignmentGeometry? alignment,
    BoxConstraints? constraints,
    bool scrollable = false,
  }) : super(
          icon: icon,
          iconPadding: iconPadding,
          iconColor: iconColor,
          title: title == null
              ? null
              : _RobinDialogHeader(
                  padding:
                      titlePadding ?? const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: title,
                ),
          titlePadding: EdgeInsets.zero,
          titleTextStyle: titleTextStyle,
          content: content,
          contentPadding:
              contentPadding ?? const EdgeInsets.fromLTRB(20, 16, 20, 14),
          contentTextStyle: contentTextStyle,
          actions: actions == null
              ? null
              : <Widget>[
                  _RobinDialogFooter(
                    padding: actionsPadding ??
                        const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    children: actions,
                  ),
                ],
          actionsPadding: EdgeInsets.zero,
          actionsAlignment: actionsAlignment,
          actionsOverflowAlignment: actionsOverflowAlignment,
          actionsOverflowDirection: actionsOverflowDirection,
          actionsOverflowButtonSpacing: actionsOverflowButtonSpacing,
          buttonPadding: buttonPadding ?? EdgeInsets.zero,
          backgroundColor: backgroundColor,
          elevation: elevation,
          shadowColor: shadowColor,
          surfaceTintColor: surfaceTintColor,
          semanticLabel: semanticLabel,
          insetPadding: insetPadding,
          clipBehavior: clipBehavior,
          shape: shape,
          alignment: alignment,
          constraints: constraints,
          scrollable: scrollable,
        );
}

/// 선택 목록형 팝업에도 동일한 제목 구분선을 적용한다.
class RobinSimpleDialog extends SimpleDialog {
  RobinSimpleDialog({
    super.key,
    Widget? title,
    EdgeInsetsGeometry? titlePadding,
    TextStyle? titleTextStyle,
    List<Widget>? children,
    EdgeInsetsGeometry? contentPadding,
    Color? backgroundColor,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    String? semanticLabel,
    EdgeInsets? insetPadding,
    Clip clipBehavior = Clip.none,
    ShapeBorder? shape,
    AlignmentGeometry? alignment,
    BoxConstraints? constraints,
  }) : super(
          title: title == null
              ? null
              : _RobinDialogHeader(
                  padding:
                      titlePadding ?? const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: title,
                ),
          titlePadding: EdgeInsets.zero,
          titleTextStyle: titleTextStyle,
          children: children,
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          backgroundColor: backgroundColor,
          elevation: elevation,
          shadowColor: shadowColor,
          surfaceTintColor: surfaceTintColor,
          semanticLabel: semanticLabel,
          insetPadding: insetPadding,
          clipBehavior: clipBehavior,
          shape: shape,
          alignment: alignment,
          constraints: constraints,
        );
}

class _RobinDialogHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _RobinDialogHeader({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: RobinTheme.border)),
        ),
        child: child,
      );
}

class _RobinDialogFooter extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const _RobinDialogFooter({required this.children, required this.padding});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: RobinTheme.border)),
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      );
}
