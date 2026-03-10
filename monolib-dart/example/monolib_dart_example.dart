import 'package:monolib_dart/monolib_dart.dart';

void main() {
  var fluentJson = FluentJson.decode('{"name": "test"}');
  print('awesome: ${fluentJson["name"].unbox<String>()}');
}
