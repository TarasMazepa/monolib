import 'dart:convert';

import 'package:monolib_openrouter/src/drop_leading_whitespace_converter.dart';

/// A [Converter] that strips leading whitespace from a byte stream, decodes
/// UTF-8 bytes to text, and parses the result into JSON.
///
/// Use this decoder with OpenRouter streamed response streams (such as chunked
/// byte streams returned from OpenRouter completions or chat APIs) to safely
/// parse JSON payloads. Streaming responses from OpenRouter may emit leading
/// keep-alive whitespace or newlines (e.g., `\r\n` or ` `) before the JSON body
/// begins, which standard JSON decoders reject with a syntax error.
///
/// This decoder fuses [DropLeadingWhitespaceConverter], [Utf8Codec.decoder]
/// (`utf8.decoder`), and [JsonCodec.decoder] (`json.decoder`):
/// ```dart
/// const DropLeadingWhitespaceConverter()
///     .fuse(utf8.decoder)
///     .fuse(json.decoder);
/// ```
///
/// Example:
/// ```dart
/// final jsonStream = responseStream.transform(openRouterJsonDecoder);
///
/// await for (final json in jsonStream) {
///   print(json);
/// }
/// ```
final openRouterJsonDecoder = const DropLeadingWhitespaceConverter()
    .fuse(utf8.decoder)
    .fuse(json.decoder);
