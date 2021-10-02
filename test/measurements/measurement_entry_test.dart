import 'package:flutter_test/flutter_test.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

void main() {
  final MeasurementEntry tMeasurementEntry = MeasurementEntry(
    id: 1234,
    category: 123,
    date: DateTime(2021, 7, 22),
    value: 83,
    notes: 'notes',
  );

  final Map<String, dynamic> tMeasurementEntryMap = {
    'id': 1234,
    'category': 123,
    'date': '2021-07-22',
    'value': 83,
    'notes': 'notes',
  };

  test('should convert a JSON map to a MeasurementEntry object', () {
    // act
    final result = MeasurementEntry.fromJson(tMeasurementEntryMap);

    // assert
    expect(result, tMeasurementEntry);
  });

  test('should convert a MeasurementEntry object to a JSON map', () {
    // act
    final result = tMeasurementEntry.toJson();

    // assert
    expect(result, tMeasurementEntryMap);
  });

  test('should copyWith objects of this class', () {
    // arrange

    final MeasurementEntry tMeasurementEntryCopied = MeasurementEntry(
      id: 83,
      category: 17,
      date: DateTime(1960),
      value: 93,
      notes: 'Interesting',
    );

    // act
    final result = tMeasurementEntry.copyWith(
        id: 83, category: 17, date: DateTime(1960), value: 93, notes: 'Interesting');

    // assert
    expect(result, tMeasurementEntryCopied);
  });
}
