import 'package:flutter_test/flutter_test.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

void main() {
  final List<MeasurementEntry> tMeasurementEntries = [
    MeasurementEntry(
      id: 1234,
      category: 123,
      date: DateTime(2021, 7, 22),
      value: 83,
      notes: 'notes',
    )
  ];

  final MeasurementEntry tMeasurementEntry = MeasurementEntry(
    id: 1234,
    category: 123,
    date: DateTime(2021, 7, 22),
    value: 83,
    notes: 'notes',
  );
  const int tMeasurementEntryId = 1234;

  final MeasurementCategory tMeasurementCategory = MeasurementCategory(
    id: 123,
    name: 'Bizeps',
    unit: 'cm',
    entries: tMeasurementEntries,
  );

  final Map<String, dynamic> tMeasurementEntryMap = {
    'id': 1234,
    'category': 123,
    'date': '2021-07-22',
    'value': 83,
    'notes': 'notes'
  };

  final Map<String, dynamic> tMeasurementCategoryMap = {
    'id': 123,
    'name': 'Bizeps',
    'unit': 'cm',
    'entries': [tMeasurementEntryMap],
  };

  final Map<String, dynamic> tMeasurementCategoryMaptoJson = {
    'id': 123,
    'name': 'Bizeps',
    'unit': 'cm',
    'entries': null,
  };

  group('fromJson()', () {
    test('should convert a JSON map to a MeasurementCategory object', () {
      // act
      final result = MeasurementCategory.fromJson(tMeasurementCategoryMap);

      // assert
      expect(result, tMeasurementCategory);
    });
  });

  group('toJson()', () {
    test('should convert a MeasurementCategory object to a JSON map', () {
      // act
      final result = tMeasurementCategory.toJson();

      // assert
      expect(result, tMeasurementCategoryMaptoJson);
    });
  });

  group('copyWith()', () {
    test('should copyWith objects of this class', () {
      // arrange

      final MeasurementCategory tMeasurementCategoryCopied = MeasurementCategory(
        id: 1234,
        name: 'Coolness',
        unit: 'lp',
        entries: tMeasurementEntries,
      );

      // act
      final result = tMeasurementCategory.copyWith(
        id: 1234,
        name: 'Coolness',
        unit: 'lp',
        entries: tMeasurementEntries,
      );

      // assert
      expect(result, tMeasurementCategoryCopied);
    });
  });

  group('findEntryById()', () {
    test('should find an entry in the entries list', () {
      // arrange

      // act
      final result = tMeasurementCategory.findEntryById(tMeasurementEntryId);

      // assert
      expect(result, tMeasurementEntry);
    });

    test('should throw a NoSuchEntryException if no MeasurementEntry was found', () {
      // act & assert
      expect(() => tMeasurementCategory.findEntryById(83), throwsA(isA<NoSuchEntryException>()));
    });
  });
}
