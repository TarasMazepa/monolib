import 'package:monolib_dart/fluent_json.dart';

void main() {
  var fluentJson = FluentJson.decode('{"name": "test"}');
  print('awesome: ${fluentJson["name"].unbox<String>()}');
}
