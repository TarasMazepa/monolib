import 'dart:convert';

import 'package:monolib_dart/fluent_json.dart';

extension OnFluentJson on FluentJson {
  DateTime get asDateTime => DateTime.parse(unbox<String>());

  /// Throws an [Exception] when the json has a top level `error` element.
  FluentJson assertNoTopLevelError() {
    if (elementAt('error') case final error?) {
      throw Exception('''Top level error

${jsonEncode(error.json)}''');
    }
    return this;
  }
}
