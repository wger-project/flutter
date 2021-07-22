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
    'measurementEntries': [
      {
        'id': 1234,
        'category': 123,
        'date': '2021-07-22',
        'value': 83,
        'notes': 'notes',
      }
    ]
  };

  test('should convert a JSON map to a MeasurementCategory object', () {
    // act
    final result = MeasurementCategory.fromJson(tMeasurementCategoryMap);

    // assert
    expect(result.id, tMeasurementCategory.id);
    expect(result.name, tMeasurementCategory.name);
    expect(result.unit, tMeasurementCategory.unit);
    expect(result.measurementEntries.length, tMeasurementCategory.measurementEntries.length);
    expect(result.measurementEntries[0].id, tMeasurementCategory.measurementEntries[0].id);
    expect(
        result.measurementEntries[0].category, tMeasurementCategory.measurementEntries[0].category);
    expect(result.measurementEntries[0].date, tMeasurementCategory.measurementEntries[0].date);
    expect(result.measurementEntries[0].value, tMeasurementCategory.measurementEntries[0].value);
    expect(result.measurementEntries[0].notes, tMeasurementCategory.measurementEntries[0].notes);
  });

  test('should convert a MeasurementCategory object to a JSON map', () {
    // act
    final result = tMeasurementCategory.toJson();

    // assert
    expect(result, tMeasurementCategoryMap);
  });
}
