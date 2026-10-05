import 'package:monolib_ai/src/api/ai_model.dart';

abstract class AiVendorClient {
  Set<String> get vendorsBlocklist;

  Stream<String> ask({
    required Object userPrompt,
    required Object? systemPrompt,
    required AiModel model,
    required String useCase,
  });
}
