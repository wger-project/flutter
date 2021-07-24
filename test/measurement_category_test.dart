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
    measurementEntries: tMeasurementEntries,
  );

  Map<String, dynamic> tMeasurementCategoryMap = {
    'id': 123,
    'name': 'Bizeps',
    'unit': 'cm',
  };

  Map<String, dynamic> tMeasurementEntryMap = {
    'id': 1234,
    'category': 123,
    'date': '2021-07-22',
    'value': 83,
    'notes': 'notes'
  };

  test('should convert a JSON map to a MeasurementCategory object', () {
    // act
    final category = MeasurementCategory.fromJson(tMeasurementCategoryMap);
    final entry = MeasurementEntry.fromJson(tMeasurementEntryMap);

    // assert
    expect(category.id, tMeasurementCategory.id);
    expect(category.name, tMeasurementCategory.name);
    expect(category.unit, tMeasurementCategory.unit);
    expect(entry.id, tMeasurementCategory.measurementEntries[0].id);
    expect(entry.category, tMeasurementCategory.measurementEntries[0].category);
    expect(entry.date, tMeasurementCategory.measurementEntries[0].date);
    expect(entry.value, tMeasurementCategory.measurementEntries[0].value);
    expect(entry.notes, tMeasurementCategory.measurementEntries[0].notes);
  });

  test('should convert a MeasurementCategory object to a JSON map', () {
    // act
    final result = tMeasurementCategory.toJson();

    // assert
    expect(result, tMeasurementCategoryMap);
  });
}
