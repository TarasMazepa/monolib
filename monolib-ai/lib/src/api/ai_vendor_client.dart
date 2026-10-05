import 'package:monolib_ai/src/api/ai_model.dart';
import 'package:monolib_ai/src/api/ai_vendor.dart';

abstract class AiVendorClient {
  Set<AiVendor> get vendorsBlocklist;

  Stream<String> ask({
    required Object userPrompt,
    required Object? systemPrompt,
    required AiModel model,
    required String useCase,
  });
}
