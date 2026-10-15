/// Extension providing timezone-aware ISO 8601 formatting for [DateTime] objects.
extension Iso8601WithTimeZone on DateTime {
  /// Returns an ISO 8601 string representation of this [DateTime] that includes
  /// the local timezone offset (e.g., `+02:00` or `-05:00`) instead of just `Z` for UTC.
  ///
  /// This is particularly useful for serialization where preserving the original
  /// timezone offset is required. If the [DateTime] is in UTC, it formats the
  /// offset as `+00:00` instead of appending a `Z`.
  ///
  /// ```dart
  /// final dt = DateTime(2023, 1, 1, 12, 0, 0); // Assuming local time with +02:00 offset
  /// print(dt.toIso8601StringWithTz()); // Prints: 2023-01-01T12:00:00.000+02:00
  ///
  /// final utcDt = DateTime.utc(2023, 1, 1, 12, 0, 0);
  /// print(utcDt.toIso8601StringWithTz()); // Prints: 2023-01-01T12:00:00.000+00:00
  /// ```
  String toIso8601StringWithTz() {
    // Get the timezone offset
    final duration = timeZoneOffset;

    // Extract hours and minutes
    final hours = duration.inHours.abs().toString().padLeft(2, '0');
    final minutes =
        duration.inMinutes.remainder(60).abs().toString().padLeft(2, '0');

    // Determine the sign (+ or -)
    final sign = duration.isNegative ? '-' : '+';
    final formattedOffset = '$sign$hours:$minutes';

    // Get the standard ISO string
    // If the time is UTC, Dart appends a 'Z'. We remove it so we can append '+00:00' instead.
    final isoString = toIso8601String().replaceAll('Z', '');

    // Combine them
    return '$isoString$formattedOffset';
  }
}
