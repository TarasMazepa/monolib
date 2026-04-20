import 'package:flutter/foundation.dart';

class CustomRichTextController extends ChangeNotifier {
  String _dataString = '';
  int _cursorPosition = 0;

  String get dataString => _dataString;
  int get cursorPosition => _cursorPosition;

  void insertText(String text) {
    _dataString = _dataString.substring(0, _cursorPosition) +
        text +
        _dataString.substring(_cursorPosition);
    _cursorPosition += text.length;
    notifyListeners();
  }

  void deleteText(int count) {
    if (_cursorPosition - count >= 0) {
      _dataString = _dataString.substring(0, _cursorPosition - count) +
          _dataString.substring(_cursorPosition);
      _cursorPosition -= count;
      notifyListeners();
    }
  }

  void setCursorPosition(int position) {
    if (position >= 0 && position <= _dataString.length) {
      _cursorPosition = position;
      notifyListeners();
    }
  }

  void updateText(String newText) {
    _dataString = newText;
    _cursorPosition = newText.length;
    notifyListeners();
  }
}
