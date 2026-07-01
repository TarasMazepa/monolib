import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Iso8601WithTimeZone', () {
    test('toIso8601StringWithTz returns UTC time with +00:00 offset', () {
      final dateTime = DateTime.utc(2023, 1, 15, 12, 30, 45);
      expect(dateTime.isUtc, isTrue);

      final result = dateTime.toIso8601StringWithTz();
      expect(result, equals('2023-01-15T12:30:45.000+00:00'));
    });

    test('toIso8601StringWithTz works with local timezone offsets', () {
      // Create a specific DateTime
      final dateTimeLocal = DateTime(2023, 1, 15, 12, 30, 45);

      final result = dateTimeLocal.toIso8601StringWithTz();

      // Calculate the expected offset manually to compare
      final duration = dateTimeLocal.timeZoneOffset;
      final hours = duration.inHours.abs().toString().padLeft(2, '0');
      final minutes =
          duration.inMinutes.remainder(60).abs().toString().padLeft(2, '0');
      final sign = duration.isNegative ? '-' : '+';
      final formattedOffset = '$sign$hours:$minutes';

      // Expected string without 'Z' at the end + formatted offset
      final expected =
          dateTimeLocal.toIso8601String().replaceAll('Z', '') + formattedOffset;

      expect(result, equals(expected));
    });
  });
}
