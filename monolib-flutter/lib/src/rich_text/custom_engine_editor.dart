import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// A leaf widget that wraps the custom render engine.
class CustomEngineEditor extends LeafRenderObjectWidget {
  final String text;

  const CustomEngineEditor({required this.text, super.key});

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
class RenderCustomEditor extends RenderBox implements TextInputClient {
  String _text;
  final TextPainter _textPainter;
  TextInputConnection? _textInputConnection; // Connection to the OS keyboard

  // State variable to track exactly where the cursor is.
  TextSelection _selection = const TextSelection.collapsed(offset: 0);

  bool _hasFocus = false;

  RenderCustomEditor({required String text})
      : _text = text, _textPainter = TextPainter(textDirection: TextDirection.ltr) {
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
        fontSize: 15,
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

    // Only draw the cursor if the editor is focused ()
    if (_hasFocus) {
      final Offset caretOffset = _textPainter.getOffsetForCaret(_selection.base, Rect.zero);

      final Offset finalCaretPosition = offset + caretOffset;
      final Paint caretPaint = Paint()..color = Colors.blue..strokeWidth = 2.0;

      final double cursorHeight = _textPainter.preferredLineHeight;

      context.canvas.drawLine(
        finalCaretPosition,
        finalCaretPosition + Offset(0, cursorHeight),
        caretPaint,
      );
    }
  }



  @override
  bool hitTestSelf(Offset position) => true;


  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerDownEvent) {
      final TextPosition position = _textPainter.getPositionForOffset(event.localPosition);
      _selection = TextSelection.collapsed(offset: position.offset);

      //We gained focus because the user tapped on the editor
      _hasFocus = true;

      markNeedsPaint();
      _requestKeyboard();
    }
  }



  void _requestKeyboard() {
    if (_textInputConnection == null || !_textInputConnection!.attached) {
      _textInputConnection = TextInput.attach(
        this,
        const TextInputConfiguration(
          inputType: TextInputType.multiline,
          inputAction: TextInputAction.newline,
        ),
      );
    }

    // Always tell the OS exactly where the cursor is when tapped.
    _textInputConnection!.setEditingState(currentTextEditingValue);
    _textInputConnection!.show();
  }


  @override
  void updateEditingValue(TextEditingValue value) {
    // Check if BOTH text and cursor position are unchanged
    if (_text == value.text && _selection == value.selection) return;

    _text = value.text;
    // Update our cursor position based on what the OS keyboard sends back
    _selection = value.selection;

    _updateTextPainter();
    markNeedsLayout();
    markNeedsPaint();
  }


  @override
  void performAction(TextInputAction action) {}

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void connectionClosed() {
    _textInputConnection = null;

    // We lost focus because the keyboard closed
    _hasFocus = false;

    // Force redraw so the cursor disappears immediately
    markNeedsPaint();
  }

  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  void insertTextPlaceholder(Size size) {}

  @override
  void removeTextPlaceholder() {}

  @override
  void showToolbar() {}

  @override
  void didChangeInputControl(TextInputControl? oldControl, TextInputControl? newControl) {}

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}


  @override
  TextEditingValue get currentTextEditingValue => TextEditingValue(
    text: _text,
    // Send the dynamic calculated selection to OS
    selection: _selection,
  );


  @override
  void insertContent(KeyboardInsertedContent content) {}

  @override
  void performSelector(String selectorName) {}

  @override
  bool onFocusReceived() {
    // Return true to notify the platform that this input successfully acquired focus
    return true;
  }

}





