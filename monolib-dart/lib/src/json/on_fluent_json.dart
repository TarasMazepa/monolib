import 'package:monolib_dart/fluent_json.dart';

extension OnFluentJson on FluentJson {
  DateTime get asDateTime => DateTime.parse(unbox<String>());
}
