import 'package:flutter/material.dart';
import 'custom_rich_text_controller.dart';
import 'custom_rich_text_widget.dart';
import 'custom_text_input_client.dart';

class CustomRichTextField extends StatefulWidget {
  final CustomRichTextController? controller;

  const CustomRichTextField({
    Key? key,
    this.controller,
  }) : super(key: key);

  @override
  State<CustomRichTextField> createState() => _CustomRichTextFieldState();
}

class _CustomRichTextFieldState extends State<CustomRichTextField> {
  late CustomRichTextController _controller;
  late CustomTextInputClient _textInputClient;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CustomRichTextController();
    _textInputClient = CustomTextInputClient(controller: _controller);
  }

  @override
  void didUpdateWidget(CustomRichTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? CustomRichTextController();
      _textInputClient = CustomTextInputClient(controller: _controller);
    }
  }

  @override
  void dispose() {
    _textInputClient.detach();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _textInputClient.attach();
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: CustomRichTextWidget(controller: _controller),
      ),
    );
  }
}
