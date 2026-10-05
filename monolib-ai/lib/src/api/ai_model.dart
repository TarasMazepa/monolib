import 'package:monolib_ai/src/api/ai_vendor.dart';
import 'package:monolib_ai/src/api/has_ai_model.dart';

class AiModel implements HasAiModel {
  final String name;
  final AiVendor vendor;

  const AiModel(this.name, this.vendor);

  @override
  AiModel get model => this;

  dynamic toJson() {
    return toString();
  }

  @override
  String toString() {
    return '${vendor.name}-$name';
  }
}
