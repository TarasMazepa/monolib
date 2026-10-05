import 'dart:convert';

import 'package:monolib_dart/fluent_json.dart';

extension OnFluentJson on FluentJson {
  FluentJson assertNoTopLevelError() {
    if (elementAt('error') case final error?) {
      throw Exception('''Top level error

${jsonEncode(error.json)}''');
    }
    return this;
  }
}
