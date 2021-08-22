import 'package:flutter_test/flutter_test.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

void main() {
  List<MeasurementEntry> tMeasurementEntries = [
    MeasurementEntry(
      id: 1234,
      category: 123,
      date: DateTime(2021, 7, 22),
      value: 83,
      notes: 'notes',
    )
  ];

  MeasurementCategory tMeasurementCategory = MeasurementCategory(
    id: 123,
    name: 'Bizeps',
    unit: 'cm',
    entries: tMeasurementEntries,
  );

  Map<String, dynamic> tMeasurementEntryMap = {
    'id': 1234,
    'category': 123,
    'date': '2021-07-22',
    'value': 83,
    'notes': 'notes'
  };

  Map<String, dynamic> tMeasurementCategoryMap = {
    'id': 123,
    'name': 'Bizeps',
    'unit': 'cm',
    'entries': [tMeasurementEntryMap],
  };

  test('should convert a JSON map to a MeasurementCategory object', () {
    // act
    final result = MeasurementCategory.fromJson(tMeasurementCategoryMap);

    // assert
    expect(result, tMeasurementCategory);
  });

  test('should convert a MeasurementCategory object to a JSON map', () {
    // act
    final result = tMeasurementCategory.toJson();

    // assert
    expect(result, tMeasurementCategoryMap);
  });
}
