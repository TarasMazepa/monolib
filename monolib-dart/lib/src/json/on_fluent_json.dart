import 'package:monolib_dart/monolib_dart.dart';

extension OnFluentJson on FluentJson {
  DateTime get asDateTime => DateTime.parse(unbox<String>());
}
