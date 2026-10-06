## 0.0.1

- Initial package setup.
- Adds `DropLeadingWhitespaceConverter` that strips leading ASCII whitespace bytes from a byte stream, with an optional `onError` callback.
- Adds `Utf8StreamStringSink`, a `StringSink` that UTF-8 encodes written values into an `EventSink<List<int>>`, with an optional `onError` callback.
- Adds `OnFluentJson` extension with `assertNoTopLevelError` to throw when json has a top level `error` element.
