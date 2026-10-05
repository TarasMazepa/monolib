# monolib_openrouter

A general-purpose Dart client for the OpenRouter API.

## Features

- Streaming API response support
- Native `http.Client` integration
- Configurable models and vendors

## Usage

```dart
import 'package:monolib_openrouter/monolib_openrouter.dart';

void main() async {
  final client = OpenRouterClient(apiKey: 'YOUR_API_KEY');
  
  final stream = client.ask(
    model: const AiModel('llama-3.1-405b-instruct', 'meta-llama'),
    systemPrompt: 'You are an AI.',
    userPrompt: 'Hello!',
    useCase: 'test',
  );
  
  await for (final chunk in stream) {
    print(chunk);
  }
}
```
