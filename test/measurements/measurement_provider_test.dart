import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/exceptions/no_result_exception.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/helpers.dart';
import 'package:wger/providers/measurement.dart';

import '../fixtures/fixture_reader.dart';
import 'measurement_provider_test.mocks.dart';

// class MockWgerBaseProvider extends Mock implements WgerBaseProvider {}

@GenerateMocks([WgerBaseProvider])
main() {
  late MeasurementProvider measurementProvider;
  late MockWgerBaseProvider mockWgerBaseProvider;

  Uri tCategoriesUri = Uri();
  int tCategoryId = 1;
  Map<String, dynamic> tMeasurementCategoriesMap =
      jsonDecode(fixture('measurement_categories.json'));

  setUp(() {
    mockWgerBaseProvider = MockWgerBaseProvider();
    measurementProvider = MeasurementProvider(mockWgerBaseProvider);

    when(mockWgerBaseProvider.makeUrl(any)).thenReturn(tCategoriesUri);
    when(mockWgerBaseProvider.fetch(any))
        .thenAnswer((realInvocation) => Future.value(tMeasurementCategoriesMap));
  });

  group('clear()', () {
    test('should clear the categories list', () async {
      // arrange
      await measurementProvider.fetchAndSetCategories();

      // assert
      expect(measurementProvider.categories.isEmpty, false);

      // act
      measurementProvider.clear();

      // assert
      expect(measurementProvider.categories.isEmpty, true);
    });
  });

  group('findCategoryById()', () {
    test('should return a category for an id', () async {
      // arrange
      MeasurementCategory tMeasurementCategory =
          MeasurementCategory(id: 1, name: 'Strength', unit: 'kN');
      await measurementProvider.fetchAndSetCategories();

      // act
      final result = measurementProvider.findCategoryById(1);

      // assert
      expect(result, tMeasurementCategory);
    });

    test('should throw a NoResultException if no category is found', () {
      // act & assert
      expect(() => measurementProvider.findCategoryById(3), throwsA(isA<NoResultException>()));
    });
  });

  group('fetchAndSetCategories()', () {
    String categoryUrl = 'measurement-category';

    List<MeasurementCategory> tMeasurementCategories = [
      MeasurementCategory(id: 1, name: 'Strength', unit: 'kN'),
      MeasurementCategory(id: 2, name: 'Biceps', unit: 'cm')
    ];

    test('should make a request url', () async {
      // act
      await measurementProvider.fetchAndSetCategories();

      // assert
      verify(mockWgerBaseProvider.makeUrl(categoryUrl));
    });

    test('should fetch data from api', () async {
      // act
      await measurementProvider.fetchAndSetCategories();

      // assert
      verify(mockWgerBaseProvider.fetch(tCategoriesUri));
    });

    test('should set categories', () async {
      // act
      await measurementProvider.fetchAndSetCategories();

      // assert
      expect(measurementProvider.categories, tMeasurementCategories);
    });
  });

  group('fetchAndSetCategoryEntries()', () {
    String entryUrl = 'measurement';
    Uri tCategoryEntriesUri = Uri(
        scheme: 'http',
        host: 'tedmosbyisajerk.com',
        path: 'api/v2/' + entryUrl + '/',
        query: 'category=1');
    Map<String, dynamic> tMeasurementCategoryMap = jsonDecode(fixture('measurement_category.json'));

    setUp(() async {
      await measurementProvider.fetchAndSetCategories();

      when(mockWgerBaseProvider.makeUrl(any, query: anyNamed('query')))
          .thenReturn(tCategoryEntriesUri);
      when(mockWgerBaseProvider.fetch(any))
          .thenAnswer((realInvocation) => Future.value(tMeasurementCategoryMap));
    });

    test('should make a uri from a category id', () async {
      // act
      await measurementProvider.fetchAndSetCategoryEntries(tCategoryId);

      // assert
      verify(mockWgerBaseProvider.makeUrl(entryUrl, query: {'category': tCategoryId.toString()}));
    });

    test('should fetch categories entries for id', () async {
      // act
      await measurementProvider.fetchAndSetCategoryEntries(tCategoryId);

      // assert
      verify(mockWgerBaseProvider.fetch(tCategoryEntriesUri));
    });

    test('should add entries to category in list', () async {
      // arrange
      List<MeasurementCategory> tMeasurementCategories = [
        MeasurementCategory(id: 1, name: 'Strength', unit: 'kN', entries: [
          MeasurementEntry(
            id: 1,
            category: 1,
            date: DateTime(2021, 7, 21),
            value: 10,
            notes: 'Some important notes',
          ),
          MeasurementEntry(
            id: 2,
            category: 1,
            date: DateTime(2021, 7, 10),
            value: 15.00,
            notes: '',
          )
        ]),
        MeasurementCategory(id: 2, name: 'Biceps', unit: 'cm')
      ];

      // act
      await measurementProvider.fetchAndSetCategoryEntries(tCategoryId);

      // assert
      expect(measurementProvider.categories, tMeasurementCategories);
    });
  });
}
