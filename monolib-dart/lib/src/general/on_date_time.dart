extension Iso8601WithTimeZone on DateTime {
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
