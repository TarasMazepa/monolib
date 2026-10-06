import 'package:monolib_dart/fluent_json.dart';
import 'package:monolib_openrouter/monolib_openrouter.dart';
import 'package:test/test.dart';

void main() {
  group('OnFluentJson', () {
    test('assertNoTopLevelError returns the same json without error', () {
      final json = FluentJson.root({
        'choices': [
          {
            'message': {'content': 'hi'},
          },
        ],
      });

      expect(json.assertNoTopLevelError(), same(json));
    });

    test('assertNoTopLevelError throws with error details', () {
      final json = FluentJson.root({
        'error': {'code': 429, 'message': 'Rate limited'},
      });

      expect(
        json.assertNoTopLevelError,
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('Top level error'), contains('Rate limited')),
          ),
        ),
      );
    });

    test('assertNoTopLevelError ignores nested errors', () {
      final json = FluentJson.root({
        'data': {'error': 'nested'},
      });

      expect(json.assertNoTopLevelError, returnsNormally);
    });
  });
}
