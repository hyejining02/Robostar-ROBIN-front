import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 데스크톱 브라우저처럼 Ctrl + 마우스 휠로 앱 전체 배율을 조절합니다.
class AppZoom extends StatefulWidget {
  const AppZoom({
    required this.child,
    this.minimumScale = 0.8,
    this.maximumScale = 1.5,
    this.scaleStep = 0.1,
    super.key,
  });

  final Widget child;
  final double minimumScale;
  final double maximumScale;
  final double scaleStep;

  @override
  State<AppZoom> createState() => _AppZoomState();
}

class _AppZoomState extends State<AppZoom> {
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter
        .removeGlobalRoute(_handlePointerEvent);
    super.dispose();
  }

  void _handlePointerEvent(PointerEvent event) {
    if (event is! PointerScrollEvent ||
        !HardwareKeyboard.instance.isControlPressed) {
      return;
    }

    // Scrollable보다 먼저 신호를 등록해 확대 중에는 화면이 함께 스크롤되지
    // 않도록 합니다. 일반 휠 입력은 등록하지 않아 기존 스크롤을 유지합니다.
    GestureBinding.instance.pointerSignalResolver.register(event, (signal) {
      final scrollEvent = signal as PointerScrollEvent;
      if (scrollEvent.scrollDelta.dy == 0) return;
      _changeScale(scrollEvent.scrollDelta.dy < 0 ? 1 : -1);
    });
  }

  void _changeScale(int direction) {
    final nextScale = (_scale + widget.scaleStep * direction)
        .clamp(widget.minimumScale, widget.maximumScale)
        .toDouble();
    final roundedScale = (nextScale * 10).round() / 10;
    if (roundedScale == _scale || !mounted) return;
    setState(() => _scale = roundedScale);
  }

  void _resetScale() {
    if (_scale == 1) return;
    setState(() => _scale = 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final viewportSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final logicalSize = Size(
          viewportSize.width / _scale,
          viewportSize.height / _scale,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: logicalSize.width,
                  maxWidth: logicalSize.width,
                  minHeight: logicalSize.height,
                  maxHeight: logicalSize.height,
                  child: Transform.scale(
                    alignment: Alignment.topLeft,
                    scale: _scale,
                    child: MediaQuery(
                      data: mediaQuery.copyWith(size: logicalSize),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
            if (_scale != 1)
              Positioned(
                right: 16,
                bottom: 16,
                child: Material(
                  color: const Color(0xEEFFFFFF),
                  elevation: 6,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    key: const Key('app-zoom-reset'),
                    onTap: _resetScale,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.zoom_in_map_outlined, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${(_scale * 100).round()}%',
                            key: const Key('app-zoom-value'),
                          ),
                          const SizedBox(width: 8),
                          const Text('초기화'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
