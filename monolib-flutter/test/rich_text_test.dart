import 'package:flutter_test/flutter_test.dart';
import 'package:monolib_flutter/rich_text.dart';

void main() {
  group('ZalgoModel Tests', () {
    test('encodeWidget and decodeWidget should work symmetrically', () {
      final widgetId = 5;
      final encoded = ZalgoModel.encodeWidget(widgetId);

      expect(ZalgoModel.isWidget(encoded), isTrue);
      expect(ZalgoModel.decodeWidget(encoded), equals(widgetId));
    });

    test('isWidget should return false for normal text', () {
      expect(ZalgoModel.isWidget('A'), isFalse);
      expect(ZalgoModel.isWidget('a'), isFalse); // Just base char
    });
  });

  group('CustomRichTextController Tests', () {
    test('insertText should update string and cursor', () {
      final controller = CustomRichTextController();
      expect(controller.dataString, equals(''));
      expect(controller.cursorPosition, equals(0));

      controller.insertText('Hello');
      expect(controller.dataString, equals('Hello'));
      expect(controller.cursorPosition, equals(5));

      controller.setCursorPosition(2);
      controller.insertText('xx');
      expect(controller.dataString, equals('Hexxllo'));
      expect(controller.cursorPosition, equals(4));
    });

    test('deleteText should update string and cursor', () {
      final controller = CustomRichTextController();
      controller.insertText('Hello World');

      controller.setCursorPosition(5);
      controller.deleteText(1);

      expect(controller.dataString, equals('Hell World'));
      expect(controller.cursorPosition, equals(4));
    });
  });

  group('DataParser Tests', () {
    test('parseToRenderString should replace widget markers with \uFFFC', () {
      final encodedWidget = ZalgoModel.encodeWidget(1);
      final rawDataString = 'Hello${encodedWidget}World';

      final renderString = DataParser.parseToRenderString(rawDataString);
      expect(renderString, equals('Hello\uFFFCWorld'));
    });
  });
}
