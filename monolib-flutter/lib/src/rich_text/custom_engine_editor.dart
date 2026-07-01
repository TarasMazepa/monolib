import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// A leaf widget that wraps the custom render engine.
class CustomEngineEditor extends LeafRenderObjectWidget {
  final String text;

  const CustomEngineEditor({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomEditor(text: text);
  }

  @override
  void updateRenderObject(BuildContext context, RenderCustomEditor renderObject) {
    renderObject.text = text;
  }
}

// Custom RenderBox that handles direct text painting on the canvas.
class RenderCustomEditor extends RenderBox {
  String _text;
  final TextPainter _textPainter;

  RenderCustomEditor({required String text})
      : _text = text,
        _textPainter = TextPainter(
          textDirection: TextDirection.ltr,
        ) {
    _updateTextPainter();
  }

  String get text => _text;

  // Updates the text and triggers a layout/paint phase if changed.
  set text(String value) {
    if (_text == value) return;
    _text = value;

    _updateTextPainter();
    markNeedsLayout();
    markNeedsPaint();
  }

  // Configures the text content and styling for the painter.
  void _updateTextPainter() {
    _textPainter.text = TextSpan(
      text: _text,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
        height: 1.5,
      ),
    );
  }

  // Calculates the layout size for the render box based on constraints.
  @override
  void performLayout() {
    _textPainter.layout(
      minWidth: 0,
      maxWidth: constraints.maxWidth,
    );

    size = constraints.constrain(
      Size(_textPainter.width, _textPainter.height),
    );
  }

  // Paints the background and the text onto the canvas.
  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint bgPaint = Paint()..color = Colors.grey.shade200;

    context.canvas.drawRect(rect, bgPaint);
    _textPainter.paint(context.canvas, offset);
  }
}