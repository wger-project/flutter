import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/measurements.dart';

void main() {
  group('whereDate', () {
    MeasurementChartEntry entry(num value, DateTime date) => MeasurementChartEntry(value, date);

    test('keeps a point sitting exactly on the start bound', () {
      // Day buckets and the range cutoff both sit at midnight, so the oldest
      // day of a range lands exactly on the bound
      final entries = [
        entry(10, DateTime(2023, 1, 1)),
        entry(20, DateTime(2023, 1, 2, 14)),
      ];

      final result = entries.whereDate(DateTime(2023, 1, 1), null);

      expect(result.map((e) => e.value), [10, 20]);
    });

    test('the end stays exclusive', () {
      final entries = [
        entry(10, DateTime(2023, 1, 1)),
        entry(20, DateTime(2023, 1, 2)),
      ];

      final result = entries.whereDate(DateTime(2023, 1, 1), DateTime(2023, 1, 2));

      expect(result.map((e) => e.value), [10]);
    });
  });

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
      expect(result.map((e) => e.value), [10, 20, 30]);
    });

    test('includes an entry recorded during the end day', () {
      final entries = [
        entry(10, DateTime(2023, 1, 1)),
        entry(30, DateTime(2023, 1, 3, 14, 30)),
      ];
      // The plan ends on Jan 3rd, so a measurement taken that afternoon is
      // still inside the window and no end value has to be interpolated
      final result = entries.whereDateWithInterpolation(DateTime(2023, 1, 1), DateTime(2023, 1, 3));

      expect(result.map((e) => e.value), [10, 30]);
      expect(result.last.date.millisecond, isNot(INTERPOLATION_MARKER));
    });

    test('excludes an entry recorded the day after the end', () {
      final entries = [
        entry(10, DateTime(2023, 1, 1)),
        entry(30, DateTime(2023, 1, 4, 0, 1)),
      ];
      final result = entries.whereDateWithInterpolation(DateTime(2023, 1, 1), DateTime(2023, 1, 3));

      // Only the Jan 1st entry plus the value interpolated for the end date
      expect(result.length, 2);
      expect(result.first.value, 10);
      expect(result.last.date.day, 3);
      expect(result.last.date.millisecond, INTERPOLATION_MARKER);
    });

    test('includes an entry recorded during the start day', () {
      final entries = [
        entry(10, DateTime(2023, 1, 1, 8)),
        entry(20, DateTime(2023, 1, 2)),
      ];
      final result = entries.whereDateWithInterpolation(DateTime(2023, 1, 1), DateTime(2023, 1, 2));

      expect(result.map((e) => e.value), [10, 20]);
    });

    // Test: Interpolates start if missing
    test('interpolates start if missing', () {
      final entries = [
        entry(10, DateTime(2023, 1, 1)),
        entry(30, DateTime(2023, 1, 3)),
      ];
      final result = entries.whereDateWithInterpolation(DateTime(2023, 1, 2), DateTime(2023, 1, 3));

      // An interpolated value for 2nd Jan, followed by the real entry on the
      // end date
      expect(result.length, 2);
      expect(result.first.value, closeTo(20, 0.0001));
      expect(result.first.date.millisecond, INTERPOLATION_MARKER);
      expect(result.first.date.day, 2);
      expect(result.last.value, 30);
      expect(result.last.date.day, 3);
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
      // No interpolation possible for Jan 1, the window starts at the first
      // real entry
      expect(result.map((e) => e.date.day), [2, 3]);
      expect(result.first.date.millisecond, isNot(INTERPOLATION_MARKER));
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
