import 'package:monolib_dart/fluent_json.dart';
import 'package:test/test.dart';

class _TestClass with ToJsonAsToString {
  final int id;
  final String name;

  _TestClass(this.id, this.name);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class _TestClassPrimitive with ToJsonAsToString {
  final String value;

  _TestClassPrimitive(this.value);

  @override
  String toJson() => value;
}

class _TestClassList with ToJsonAsToString {
  final List<int> values;

  _TestClassList(this.values);

  @override
  List<int> toJson() => values;
}

void main() {
  group('ToJsonAsToString', () {
    test('produces correct JSON string for map', () {
      final obj = _TestClass(1, 'test');
      expect(obj.toString(), '{"id":1,"name":"test"}');
    });

    test('produces correct JSON string for primitive', () {
      final obj = _TestClassPrimitive('hello');
      expect(obj.toString(), '"hello"');
    });

    test('produces correct JSON string for list', () {
      final obj = _TestClassList([1, 2, 3]);
      expect(obj.toString(), '[1,2,3]');
    });
  });
}
