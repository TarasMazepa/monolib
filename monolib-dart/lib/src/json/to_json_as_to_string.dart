import 'dart:convert';

/// A mixin that provides a `toString()` implementation using `jsonEncode`.
///
/// Classes mixing this in must implement `toJson()`.
mixin ToJsonAsToString {
  /// Converts the object to a representation that can be JSON encoded.
  dynamic toJson();

  @override
  String toString() => jsonEncode(toJson());
}
