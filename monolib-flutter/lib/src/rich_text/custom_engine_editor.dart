import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'model/data_model.dart';


// --- UI WRAPPER ---
class CustomEngineEditor extends StatefulWidget {
  final String text;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final TapRegionCallback? onTapOutside;

  const CustomEngineEditor({
    required this.text,
    this.focusNode,
    this.padding,
    this.decoration,
    this.onTapOutside,
    super.key,
  });


  @override
  State<CustomEngineEditor> createState() => _CustomEngineEditorState();
}

class _CustomEngineEditorState extends State<CustomEngineEditor> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  List<RenderedWidgetBox> _widgetBoxes = [];

  final GlobalKey _engineKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }


  void _insertWidget(InlineWidgetData data) {
    final engine = _engineKey.currentContext?.findRenderObject() as RenderCustomEditor?;
    engine?.insertCustomWidget(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _insertWidget(
                ButtonInlineData(text: "Action Btn", snackbarText: "Stored Message Triggered!"),
              ),
              icon: const Icon(Icons.touch_app, size: 16),
              label: const Text("Add Button"),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _insertWidget(
                ImageInlineData(url: "https://picsum.photos/100"),
              ),
              icon: const Icon(Icons.image, size: 16),
              label: const Text("Add Image"),
            ),
          ],
        ),
        const SizedBox(height: 10),


        TapRegion(
          onTapOutside: (PointerDownEvent event) {
            if (widget.onTapOutside != null) {
              widget.onTapOutside!(event);
            } else {
              _focusNode.unfocus();
            }
          },
          child: Container(
            width: double.infinity,
            padding: widget.padding ?? const EdgeInsets.all(12),
            decoration: widget.decoration ?? BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // Layer 1: Core Engine
                Focus(
                  focusNode: _focusNode,
                  child: _CustomEngineRenderWidget(
                    key: _engineKey,
                    text: widget.text,
                    focusNode: _focusNode,
                    onLayoutComputed: (boxes) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _widgetBoxes != boxes) {
                          setState(() => _widgetBoxes = boxes);
                        }
                      });
                    },
                  ),
                ),

                // Layer 2: Dynamic Live Widgets based on Data Type
                ..._widgetBoxes.map((renderBox) {
                  final box = renderBox.box;
                  final data = renderBox.data;

                  Widget childWidget;


                  if (data is ButtonInlineData) {
                    childWidget = ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        backgroundColor: Colors.orangeAccent,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(data.snackbarText)),
                        );
                      },
                      child: Text(data.text, style: const TextStyle(fontSize: 12, color: Colors.white)),
                    );
                  }

                  else if (data is ImageInlineData) {
                    childWidget = Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
                      child: Image.network(data.url, fit: BoxFit.cover),
                    );
                  }
                  else {
                    childWidget = const SizedBox();
                  }

                  return Positioned(
                    left: box.left,
                    top: box.top,
                    width: box.right - box.left,
                    height: box.bottom - box.top,
                    child: childWidget,
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// A leaf widget that wraps the custom render engine.
class _CustomEngineRenderWidget extends LeafRenderObjectWidget {
  final String text;
  final FocusNode focusNode;
  final Function(List<RenderedWidgetBox>) onLayoutComputed;

  const _CustomEngineRenderWidget({
    super.key,
    required this.text,
    required this.focusNode,
    required this.onLayoutComputed,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomEditor(text: text, focusNode: focusNode, onLayoutComputed: onLayoutComputed);
  }

  @override
  void updateRenderObject(BuildContext context, RenderCustomEditor renderObject) {
    renderObject.focusNode = focusNode;
  }
}



class RenderCustomEditor extends RenderBox implements TextInputClient {
  String _text;
  final TextPainter _textPainter;
  TextInputConnection? _textInputConnection;

  TextSelection _selection = const TextSelection.collapsed(offset: 0);
  FocusNode _focusNode;
  bool _isFocusFromTap = false;

  Function(List<RenderedWidgetBox>) onLayoutComputed;

  List<InlineWidgetData> _metadataRegistry = [];

  RenderCustomEditor({
    required String text,
    required FocusNode focusNode,
    required this.onLayoutComputed,
  })  : _text = text,
        _focusNode = focusNode,
        _textPainter = TextPainter(textDirection: TextDirection.ltr) {
    _updateTextPainter();
    _focusNode.addListener(_handleFocusChange);
  }

  // --- API to Insert Widget from UI ---
  void insertCustomWidget(InlineWidgetData data) {
    final int cursorIndex = _selection.isValid ? _selection.baseOffset : _text.length;

    // Calculate registry index
    int registryIndex = 0;
    for (int i = 0; i < cursorIndex; i++) {
      if (_text[i] == '\uFFFC') registryIndex++;
    }

    _metadataRegistry.insert(registryIndex, data);
    _text = '${_text.substring(0, cursorIndex)}\uFFFC${_text.substring(cursorIndex)}';

    _selection = TextSelection.collapsed(offset: cursorIndex + 1);
    _textInputConnection?.setEditingState(currentTextEditingValue);

    _updateTextPainter();
    markNeedsLayout();
    markNeedsPaint();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      if (!_isFocusFromTap) _selection = TextSelection.collapsed(offset: _text.length);
      _requestKeyboard();
      _isFocusFromTap = false;
    } else {
      _textInputConnection?.close();
      _textInputConnection = null;
    }
    markNeedsPaint();
  }

  set focusNode(FocusNode value) {
    if (_focusNode == value) return;
    _focusNode.removeListener(_handleFocusChange);
    _focusNode = value;
    _focusNode.addListener(_handleFocusChange);
  }

  void _updateTextPainter() {
    final List<InlineSpan> spans = [];
    final parts = _text.split('\uFFFC');

    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i], style: const TextStyle(fontSize: 15, color: Colors.black, height: 1)));

      if (i < parts.length - 1 && i < _metadataRegistry.length) {
        final data = _metadataRegistry[i];
        // Dynamic Dimension allocation based on data type
        Size widgetSize = data is ButtonInlineData ? const Size(100, 30) : const Size(80, 80);

        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SizedBox(width: widgetSize.width, height: widgetSize.height),
        ));
      }
    }
    _textPainter.text = TextSpan(children: spans);
  }

  @override
  void performLayout() {
    // Dynamic Layout sizing mapping
    List<PlaceholderDimensions> dimensions = _metadataRegistry.map((data) {
      Size size = data is ButtonInlineData ? const Size(100, 30) : const Size(80, 80);
      return PlaceholderDimensions(size: size, alignment: PlaceholderAlignment.middle);
    }).toList();

    _textPainter.setPlaceholderDimensions(dimensions);
    _textPainter.layout(minWidth: 0, maxWidth: constraints.maxWidth);
    size = constraints.constrain(Size(_textPainter.width, _textPainter.height));

    final boxes = _textPainter.inlinePlaceholderBoxes;
    if (boxes != null) {
      List<RenderedWidgetBox> uiBoxes = [];
      for (int i = 0; i < boxes.length; i++) {
        if (i < _metadataRegistry.length) {
          uiBoxes.add(RenderedWidgetBox(box: boxes[i], data: _metadataRegistry[i]));
        }
      }
      onLayoutComputed(uiBoxes);
    }
  }


  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint bgPaint = Paint()..color = Colors.grey.shade200;
    context.canvas.drawRect(rect, bgPaint);
    _textPainter.paint(context.canvas, offset);


    if (_focusNode.hasFocus) {
      final Offset caretOffset = _textPainter.getOffsetForCaret(_selection.base, Rect.zero);
      final Offset finalCaretPosition = offset + caretOffset;
      context.canvas.drawLine(
        finalCaretPosition,
        finalCaretPosition + Offset(0, _textPainter.preferredLineHeight),
        Paint()..color = Colors.blue..strokeWidth = 2.0,
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

      if (!_focusNode.hasFocus) {
        _isFocusFromTap = true;
        _focusNode.requestFocus();
      } else {
        _requestKeyboard();
        markNeedsPaint();
      }
    }
  }

  void _requestKeyboard() {
    if (_textInputConnection == null || !_textInputConnection!.attached) {
      _textInputConnection = TextInput.attach(
        this,
        const TextInputConfiguration(inputType: TextInputType.multiline, inputAction: TextInputAction.newline),
      );
    }
    _textInputConnection!.setEditingState(currentTextEditingValue);
    _textInputConnection!.show();
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    if (_text == value.text && _selection == value.selection) return;

    int oldUfffcCount = _text.split('\uFFFC').length - 1;
    int newUfffcCount = value.text.split('\uFFFC').length - 1;
    int difference = oldUfffcCount - newUfffcCount;

    if (difference > 0) {
      int ufffcCountBeforeMismatch = 0;
      for (int i = 0; i < _text.length; i++) {
        if (i >= value.text.length || _text[i] != value.text[i]) break;
        if (_text[i] == '\uFFFC') ufffcCountBeforeMismatch++;
      }
      _metadataRegistry.removeRange(ufffcCountBeforeMismatch, ufffcCountBeforeMismatch + difference);
    }

    _text = value.text;
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
  void connectionClosed() => _focusNode.unfocus();
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
  TextEditingValue get currentTextEditingValue => TextEditingValue(text: _text, selection: _selection);
  @override
  void insertContent(KeyboardInsertedContent content) {}
  @override
  void performSelector(String selectorName) {}
  @override
  bool onFocusReceived() => true;
}