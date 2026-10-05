import 'package:monolib_ai/src/api/has_ai_model.dart';

class AiModel implements HasAiModel {
  final String name;
  final String vendor;

  const AiModel(this.name, this.vendor);

  @override
  AiModel get model => this;

  dynamic toJson() {
    return toString();
  }

  @override
  String toString() {
    return '$vendor-$name';
  }
}
