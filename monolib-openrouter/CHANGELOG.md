## 0.0.3

- Adds `OpenRouterClient` that streams the chat completions request and parses the response as it arrives, with optional request and response timeouts, cost reporting and stream wrappers.
- Raises the minimum Dart SDK to 3.4.0, as required by `http` 1.4.0.

## 0.0.2

- Adds `OnFuture` extension with `timeoutAsStream` to turn a future into a stream that closes without emitting on timeout.
- Adds `OnStream` extension with `timeoutAndClose` to close a stream on timeout instead of emitting a `TimeoutException`.

## 0.0.1

- Initial package setup.
- Adds `DropLeadingWhitespaceConverter` that strips leading ASCII whitespace bytes from a byte stream, with an optional `onError` callback.
- Adds `Utf8StreamStringSink`, a `StringSink` that UTF-8 encodes written values into an `EventSink<List<int>>`, with an optional `onError` callback.
- Adds `OnFluentJson` extension with `assertNoTopLevelError` to throw when json has a top level `error` element.
