import 'package:monolib_dart/fluent_json.dart';

void main() {
  final FluentJson fluentJson = FluentJson.decode('{"name": "test"}');
  print('awesome: ${fluentJson["name"].unbox<String>()}');
}
