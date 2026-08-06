import 'package:flutter/services.dart';
import 'custom_rich_text_controller.dart';

class CustomTextInputClient implements TextInputClient {
  final CustomRichTextController controller;
  TextInputConnection? _connection;

  CustomTextInputClient({required this.controller});

  void attach() {
    _connection = TextInput.attach(this, const TextInputConfiguration());
    _connection?.show();
    _updateRemoteValue();
  }

  void detach() {
    _connection?.close();
    _connection = null;
  }

  void _updateRemoteValue() {
    _connection?.setEditingState(TextEditingValue(
      text: controller.dataString,
      selection: TextSelection.collapsed(offset: controller.cursorPosition),
    ));
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    controller.updateText(value.text);
    controller.setCursorPosition(value.selection.baseOffset);
  }

  @override
  void performAction(TextInputAction action) {
    // Handle specific actions if needed
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void connectionClosed() {}

  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  void insertTextPlaceholder(Size size) {}

  @override
  void removeTextPlaceholder() {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void showToolbar() {}

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void performSelector(String selectorName) {}

  @override
  TextEditingValue? get currentTextEditingValue => TextEditingValue(
        text: controller.dataString,
        selection: TextSelection.collapsed(offset: controller.cursorPosition),
      );

  @override
  void insertContent(KeyboardInsertedContent content) {}

  @override
  void didChangeInputControl(
      TextInputControl? oldControl, TextInputControl? newControl) {}
}
