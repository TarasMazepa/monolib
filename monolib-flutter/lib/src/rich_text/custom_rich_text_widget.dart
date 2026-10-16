import 'package:flutter/material.dart';
import 'custom_rich_text_controller.dart';
import 'data_parser.dart';
import 'index_offset_mapping.dart';

class CustomRichTextWidget extends LeafRenderObjectWidget {
  final CustomRichTextController controller;

  const CustomRichTextWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CustomRichTextRenderBox(controller: controller);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant CustomRichTextRenderBox renderObject) {
    renderObject.controller = controller;
  }
}

class CustomRichTextRenderBox extends RenderBox {
  CustomRichTextController _controller;
  late TextPainter _textPainter;

  CustomRichTextRenderBox({
    required CustomRichTextController controller,
  }) : _controller = controller {
    _textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    _controller.addListener(_markNeedsPaint);
  }

  CustomRichTextController get controller => _controller;

  set controller(CustomRichTextController value) {
    if (_controller == value) return;
    _controller.removeListener(_markNeedsPaint);
    _controller = value;
    _controller.addListener(_markNeedsPaint);
    markNeedsLayout();
  }

  void _markNeedsPaint() {
    markNeedsLayout();
  }

  @override
  void dispose() {
    _controller.removeListener(_markNeedsPaint);
    _textPainter.dispose();
    super.dispose();
  }

  @override
  void performLayout() {
    final renderString = DataParser.parseToRenderString(_controller.dataString);
    _textPainter.text = TextSpan(
      text: renderString,
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );
    _textPainter.layout(maxWidth: constraints.maxWidth);
    size = _textPainter.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _textPainter.paint(context.canvas, offset);

    // Draw a basic cursor
    final renderString = DataParser.parseToRenderString(_controller.dataString);
    final renderCursorOffset = IndexOffsetMapping.dataToRenderOffset(
        _controller.dataString, renderString, _controller.cursorPosition);

    final cursorOffset = _textPainter.getOffsetForCaret(
        TextPosition(offset: renderCursorOffset), Rect.zero);

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0;

    context.canvas.drawLine(
      offset + cursorOffset,
      offset +
          cursorOffset +
          const Offset(0, 20), // Assumes line height of 20 for prototype
      paint,
    );
  }
}
