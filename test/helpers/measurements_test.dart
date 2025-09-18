import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/measurements.dart';
import 'package:wger/widgets/measurements/charts.dart';

void main() {
  group('whereDateWithInterpolation', () {
    // Helper to create entries
    MeasurementChartEntry entry(num value, DateTime date) => MeasurementChartEntry(value, date);

    // Test: No interpolation needed, exact start and end dates exist
    test('returns entries within range when start and end exist', () {
      final entries = [
        entry(10, DateTime(2023, 1, 1)),
        entry(20, DateTime(2023, 1, 2)),
        entry(30, DateTime(2023, 1, 3)),
      ];
      final result = entries.whereDateWithInterpolation(DateTime(2023, 1, 1), DateTime(2023, 1, 3));

      // Entries on start and end date should be included if they exist
      expect(result.first.value, 10);
      expect(result.last.value, 20);
    });

    // Test: Interpolates start if missing
    test('interpolates start if missing', () {
      final entries = [
        entry(10, DateTime(2023, 1, 1)),
        entry(30, DateTime(2023, 1, 3)),
      ];
      final result = entries.whereDateWithInterpolation(DateTime(2023, 1, 2), DateTime(2023, 1, 3));

      // Only the interpolated value for 2nd Jan is included
      expect(result.length, 1);
      expect(result.first.value, closeTo(20, 0.0001));
      expect(result.first.date.millisecond, INTERPOLATION_MARKER);
      expect(result.first.date.day, 2);
    });

    // Test: Interpolates end if missing
    test('interpolates end if missing', () {
      final entries = [
        entry(10, DateTime(2023, 1, 1)),
        entry(30, DateTime(2023, 1, 3)),
      ];
      final result = entries.whereDateWithInterpolation(DateTime(2023, 1, 1), DateTime(2023, 1, 2));
      // Should include the entry for 1st Jan and an interpolated value for 2nd Jan
      expect(result.length, 2);
      expect(result.first.value, 10);
      expect(result.first.date.day, 1);
      expect(result.last.value, closeTo(20, 0.0001));
      expect(result.last.date.day, 2);
    });

    // Test: No interpolation if out of bounds
    test('returns empty if no data in range', () {
      final entries = [
        entry(10, DateTime(2023, 1, 1)),
        entry(20, DateTime(2023, 1, 2)),
      ];
      final result = entries.whereDateWithInterpolation(DateTime(2023, 2, 1), DateTime(2023, 2, 2));
      expect(result, isEmpty);
    });

    // Test: Only start interpolation if data exists before and after
    test('does not interpolate if no data before start', () {
      final entries = [
        entry(10, DateTime(2023, 1, 2)),
        entry(20, DateTime(2023, 1, 3)),
      ];
      final result = entries.whereDateWithInterpolation(DateTime(2023, 1, 1), DateTime(2023, 1, 3));
      // No interpolation possible for Jan 1, only entry for Jan 2 is included
      expect(result.length, 1);
      expect(result.first.date.day, 2);
    });

    // Test: Only end interpolation if data exists before and after
    test('does not interpolate if no data after end', () {
      final entries = [
        entry(10, DateTime(2023, 1, 1)),
        entry(20, DateTime(2023, 1, 2)),
      ];
      final result = entries.whereDateWithInterpolation(DateTime(2023, 1, 1), DateTime(2023, 1, 3));
      // No interpolation possible for Jan 3, only entries for Jan 1 and Jan 2 are included
      expect(result.length, 2);
      expect(result.first.date.day, 1);
      expect(result.last.date.day, 2);
    });
  });
}
