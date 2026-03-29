import 'package:monolib_dart/fluent_json.dart';

extension OnString on String {
  FluentJson parseAsFluentJson() => FluentJson.decode(this);
}
