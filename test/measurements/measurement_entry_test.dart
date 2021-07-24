import 'package:flutter_test/flutter_test.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

void main() {
  MeasurementEntry tMeasurementEntry = MeasurementEntry(
    id: 1234,
    category: 123,
    date: DateTime(2021, 7, 22),
    value: 83,
    notes: 'notes',
  );

  Map<String, dynamic> tMeasurementEntryMap = {
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
    expect(result.id, tMeasurementEntry.id);
    expect(result.category, tMeasurementEntry.category);
    expect(result.date, tMeasurementEntry.date);
    expect(result.value, tMeasurementEntry.value);
    expect(result.notes, tMeasurementEntry.notes);
  });

  test('should convert a MeasurementEntry object to a JSON map', () {
    // act
    final result = tMeasurementEntry.toJson();

    // assert
    expect(result, tMeasurementEntryMap);
  });
}
