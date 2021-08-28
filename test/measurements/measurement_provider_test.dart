import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/measurement.dart';

import '../fixtures/fixture_reader.dart';
import 'measurement_provider_test.mocks.dart';

// class MockWgerBaseProvider extends Mock implements WgerBaseProvider {}

@GenerateMocks([WgerBaseProvider])
main() {
  late MeasurementProvider measurementProvider;
  late MockWgerBaseProvider mockWgerBaseProvider;

  String categoryUrl = 'measurement-category';
  String entryUrl = 'measurement';
  Uri tCategoryUri = Uri();
  Map<String, dynamic> tMeasurementCategoryMap =
      jsonDecode(fixture('measurement_category_entries.json'));
  Uri tCategoryEntriesUri = Uri(
      scheme: 'http',
      host: 'tedmosbyisajerk.com',
      path: 'api/v2/' + entryUrl + '/',
      query: 'category=1');

  int tCategoryId = 1;
  MeasurementCategory tMeasurementCategory =
      MeasurementCategory(id: 1, name: 'Strength', unit: 'kN');
  List<MeasurementCategory> tMeasurementCategories = [
    MeasurementCategory(id: 1, name: 'Strength', unit: 'kN'),
    MeasurementCategory(id: 2, name: 'Biceps', unit: 'cm')
  ];
  Map<String, dynamic> tMeasurementCategoriesMap =
      jsonDecode(fixture('measurement_categories.json'));

  setUp(() {
    mockWgerBaseProvider = MockWgerBaseProvider();
    measurementProvider = MeasurementProvider(mockWgerBaseProvider);

    when(mockWgerBaseProvider.makeUrl(any)).thenReturn(tCategoryUri);
    when(mockWgerBaseProvider.fetch(any))
        .thenAnswer((realInvocation) => Future.value(tMeasurementCategoriesMap));

    when(mockWgerBaseProvider.makeUrl(entryUrl, query: anyNamed('query')))
        .thenReturn(tCategoryEntriesUri);
    when(mockWgerBaseProvider.fetch(tCategoryEntriesUri))
        .thenAnswer((realInvocation) => Future.value(tMeasurementCategoryMap));
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

      await measurementProvider.fetchAndSetCategories();

      // act
      final result = measurementProvider.findCategoryById(1);

      // assert
      expect(result, tMeasurementCategory);
    });

    test('should throw a NoResultException if no category is found', () {
      // act & assert
      expect(() => measurementProvider.findCategoryById(3), throwsA(isA<NoSuchEntryException>()));
    });
  });

  group('fetchAndSetCategories()', () {
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
      verify(mockWgerBaseProvider.fetch(tCategoryUri));
    });

    test('should set categories', () async {
      // act
      await measurementProvider.fetchAndSetCategories();

      // assert
      expect(measurementProvider.categories, tMeasurementCategories);
    });
  });

  group('fetchAndSetCategoryEntries()', () {
    setUp(() async {
      await measurementProvider.fetchAndSetCategories();
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

  group('addCategory()', () {
    MeasurementCategory tMeasurementCategoryWithoutId =
        MeasurementCategory(id: null, name: 'Strength', unit: 'kN');
    Map<String, dynamic> tMeasurementCategoryMap = jsonDecode(fixture('measurement_category.json'));
    Map<String, dynamic> tMeasurementCategoryMapWithoutId =
        jsonDecode(fixture('measurement_category_without_id_to_json.json'));
    List<MeasurementCategory> tMeasurementCategoriesAdded = [
      MeasurementCategory(id: 2, name: 'Biceps', unit: 'cm'),
      MeasurementCategory(id: 1, name: 'Strength', unit: 'kN'),
      MeasurementCategory(id: 1, name: 'Strength', unit: 'kN'),
    ];
    setUp(() {
      when(mockWgerBaseProvider.post(any, any))
          .thenAnswer((realInvocation) => Future.value(tMeasurementCategoryMap));
    });

    test('should post the MeasurementCategorie\'s Map', () async {
      // act
      await measurementProvider.addCategory(tMeasurementCategoryWithoutId);

      // assert
      verify(mockWgerBaseProvider.post(tMeasurementCategoryMapWithoutId, tCategoryUri));
    });

    test(
        'should add the result from the post call to the categories List and sort the list by alphabetical order',
        () async {
      // arrange
      await measurementProvider.fetchAndSetCategories();

      // act
      await measurementProvider.addCategory(tMeasurementCategoryWithoutId);

      // assert
      expect(measurementProvider.categories, tMeasurementCategoriesAdded);
    });
  });

  group('deleteCategory()', () {
    setUp(() async {
      await measurementProvider.fetchAndSetCategories();
    });
    test(
        'should remove a MeasurementCategory from the categories list for an id and call the api to remove the MeasurementCategory',
        () async {
      // arrange
      when(mockWgerBaseProvider.deleteRequest(any, any))
          .thenAnswer((realInvocation) => Future.value(Response('', 200)));

      List<MeasurementCategory> tMeasurementCategoriesOneDeleted = [
        MeasurementCategory(id: 2, name: 'Biceps', unit: 'cm')
      ];

      // act
      await measurementProvider.deleteCategory(tCategoryId);

      // assert
      verify(mockWgerBaseProvider.deleteRequest('measurement-category', tCategoryId));
      expect(measurementProvider.categories, tMeasurementCategoriesOneDeleted);
    });

    test('should throw a NoSuchEntryException if no category is found', () {
      // act & assert
      expect(() async => await measurementProvider.deleteCategory(83),
          throwsA(isA<NoSuchEntryException>()));
    });

    test(
        'should re-add the "removed" MeasurementCategory and relay the exception on WgerHttpException',
        () async {
      // arrange
      when(mockWgerBaseProvider.deleteRequest(any, any)).thenThrow(WgerHttpException('{}'));

      // act & assert
      expect(() async => await measurementProvider.deleteCategory(tCategoryId),
          throwsA(isA<WgerHttpException>()));
      expect(measurementProvider.categories, tMeasurementCategories);
    });
  });

  group('editCategory()', () {
    String tCategoryEditedName = 'Triceps';
    String tCategoryEditedUnit = 'm';
    Map<String, dynamic> tCategoryMapEditedToJson =
        jsonDecode(fixture('measurement_category_edited_to_json.json'));
    Map<String, dynamic> tCategoryMapEdited =
        jsonDecode(fixture('measurement_category_edited.json'));
    setUp(() async {
      when(mockWgerBaseProvider.patch(any, any))
          .thenAnswer((realInvocation) => Future.value(tCategoryMapEdited));
      await measurementProvider.fetchAndSetCategories();
    });
    test('should add the new MeasurementCategory and remove the old one', () async {
      // arrange
      List<MeasurementCategory> tMeasurementCategoriesEdited = [
        MeasurementCategory(id: 1, name: 'Triceps', unit: 'm'),
        MeasurementCategory(id: 2, name: 'Biceps', unit: 'cm'),
      ];

      // act
      await measurementProvider.editCategory(tCategoryId, tCategoryEditedName, tCategoryEditedUnit);

      // assert
      expect(measurementProvider.categories, tMeasurementCategoriesEdited);
    });

    test('should throw a NoSuchEntryException if category doesn\'t exist', () {
      // act & assert
      expect(
          () async =>
              await measurementProvider.editCategory(83, tCategoryEditedName, tCategoryEditedUnit),
          throwsA(isA<NoSuchEntryException>()));
    });

    test('should call api to patch the category', () async {
      // act
      await measurementProvider.editCategory(tCategoryId, tCategoryEditedName, tCategoryEditedUnit);

      // assert
      verify(mockWgerBaseProvider.patch(tCategoryMapEditedToJson, tCategoryUri));
    });

    test('should keep categories list as is on WgerHttpException', () {
      // arrange
      when(mockWgerBaseProvider.patch(any, any)).thenThrow(WgerHttpException('{}'));

      // act & assert
      expect(
          () async => await measurementProvider.editCategory(
              tCategoryId, tCategoryEditedName, tCategoryEditedUnit),
          throwsA(isA<WgerHttpException>()));
      expect(measurementProvider.categories, tMeasurementCategories);
    });
  });

  group('addEntry()', () {
    MeasurementEntry tMeasurementEntry = MeasurementEntry(
      id: 3,
      category: 1,
      date: DateTime(2021, 7, 9),
      value: 15.00,
      notes: '',
    );

    MeasurementEntry tMeasurementEntryWithoutId = MeasurementEntry(
      id: null,
      category: 1,
      date: DateTime(2021, 7, 9),
      value: 15.0,
      notes: '',
    );

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
        ),
        tMeasurementEntry
      ]),
      MeasurementCategory(id: 2, name: 'Biceps', unit: 'cm')
    ];

    setUp(() async {
      await measurementProvider.fetchAndSetCategories();

      Map<String, dynamic> measurementEntryMap = jsonDecode(fixture('measurement_entry.json'));
      when(mockWgerBaseProvider.post(any, any))
          .thenAnswer((realInvocation) => Future.value(measurementEntryMap));
    });

    test('should make the post url', () async {
      // act
      await measurementProvider.addEntry(tMeasurementEntryWithoutId);

      // assert
      verify(mockWgerBaseProvider.makeUrl(entryUrl));
    });

    test('should post the MeasurementEntryMap', () async {
      // arrange
      Map<String, dynamic> measurementEntryMapWithoutId =
          jsonDecode(fixture('measurement_entry_without_id.json'));

      // act
      await measurementProvider.addEntry(tMeasurementEntryWithoutId);

      // assert
      verify(mockWgerBaseProvider.post(measurementEntryMapWithoutId, tCategoryEntriesUri));
    });

    test(
        'should add MeasurementEntry to its MeasurementCategory in the categories List and sort the category\'s list by date',
        () async {
      // arrange
      await measurementProvider.fetchAndSetCategoryEntries(tCategoryId);

      // act
      await measurementProvider.addEntry(tMeasurementEntryWithoutId);

      // assert
      expect(measurementProvider.categories, tMeasurementCategories);
    });

    test('should throw a NoSuchEntryException if no category is found', () {
      // arrange
      MeasurementEntry tMeasurementEntryWrongCategory = MeasurementEntry(
        id: 3,
        category: 83,
        date: DateTime(2021, 7, 9),
        value: 15.00,
        notes: '',
      );
      Map<String, dynamic> measurementEntryMapWrongCategory =
          jsonDecode(fixture('measurement_entry_wrong_category.json'));
      when(mockWgerBaseProvider.post(any, any))
          .thenAnswer((realInvocation) => Future.value(measurementEntryMapWrongCategory));

      // act & assert
      expect(() async => await measurementProvider.addEntry(tMeasurementEntryWrongCategory),
          throwsA(isA<NoSuchEntryException>()));
    });
  });

  group('deleteEntry()', () {
    int tEntryId = 2;
    List<MeasurementCategory> tMeasurementCategories = [
      MeasurementCategory(id: 1, name: 'Strength', unit: 'kN', entries: [
        MeasurementEntry(
          id: 1,
          category: 1,
          date: DateTime(2021, 7, 21),
          value: 10,
          notes: 'Some important notes',
        ),
      ]),
      MeasurementCategory(id: 2, name: 'Biceps', unit: 'cm')
    ];

    setUp(() async {
      await measurementProvider.fetchAndSetCategories();
      await measurementProvider.fetchAndSetCategoryEntries(tCategoryId);

      when(mockWgerBaseProvider.deleteRequest(any, any))
          .thenAnswer((realInvocation) => Future.value(Response('', 200)));
    });

    test('should remove a MeasurementEntry from the category\'s entries List for an id', () async {
      // act
      await measurementProvider.deleteEntry(tEntryId, tCategoryId);

      // assert
      expect(measurementProvider.categories, tMeasurementCategories);
    });

    test('should throw a NoSuchEntryException if the category isn\'t found', () {
      // act & assert
      expect(() async => await measurementProvider.deleteEntry(tEntryId, 83),
          throwsA(isA<NoSuchEntryException>()));
    });

    test(
        'should throw a NoSuchEntryException if the entry in the categories entries List isn\'t found',
        () {
      // act & assert
      expect(() async => await measurementProvider.deleteEntry(83, tCategoryId),
          throwsA(isA<NoSuchEntryException>()));
    });

    test('should call the api to remove the MeasurementEntry', () async {
      // act
      await measurementProvider.deleteEntry(tEntryId, tCategoryId);

      // assert
      verify(mockWgerBaseProvider.deleteRequest(entryUrl, tEntryId));
    });

    test(
        'should re-add the "removed" MeasurementEntry and throw a WgerHttpException if the api call fails',
        () async {
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
          ),
        ]),
        MeasurementCategory(id: 2, name: 'Biceps', unit: 'cm')
      ];
      when(mockWgerBaseProvider.deleteRequest(any, any)).thenThrow(WgerHttpException('{}'));

      // act & assert
      expect(() async => await measurementProvider.deleteEntry(tEntryId, tCategoryId),
          throwsA(isA<WgerHttpException>()));
      expect(measurementProvider.categories, tMeasurementCategories);
    });
  });

  group('editEntry()', () {
    // remove the old MeasurementCategory
    // should call api to patch the category
    // should add the new MeasurementCategory from the api call
    // notifyListeners()
    // should re-add the old MeasurementCategory and remove the new one if call to api fails
    // notifyListeners()
    int tEntryId = 1;
    num tEntryEditedValue = 23;
    DateTime tEntryEditedDate = DateTime(2021, 07, 21);
    String tEntryEditedNote = 'I just wanted to edit this to see what happens';
    Map<String, dynamic> tEntryMapEdited = jsonDecode(fixture('measurement_entry_edited.json'));
    setUp(() async {
      when(mockWgerBaseProvider.patch(any, any))
          .thenAnswer((realInvocation) => Future.value(tEntryMapEdited));
      await measurementProvider.fetchAndSetCategories();
      await measurementProvider.fetchAndSetCategoryEntries(1);
    });
    test('should add the new MeasurementCategory and remove the old one', () async {
      // arrange
      List<MeasurementCategory> tMeasurementCategoriesEdited = [
        MeasurementCategory(id: 1, name: 'Strength', unit: 'kN', entries: [
          MeasurementEntry(
            id: 1,
            category: 1,
            date: DateTime(2021, 7, 21),
            value: 23,
            notes: 'I just wanted to edit this to see what happens',
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
      await measurementProvider.editEntry(
        tEntryId,
        tCategoryId,
        tEntryEditedValue,
        tEntryEditedNote,
        tEntryEditedDate,
      );

      // assert
      expect(measurementProvider.categories, tMeasurementCategoriesEdited);
    });

    test('should throw a NoSuchEntryException if category doesn\'t exist', () {
      // act & assert
      expect(
          () async => await measurementProvider.editEntry(
                tEntryId,
                83,
                tEntryEditedValue,
                tEntryEditedNote,
                tEntryEditedDate,
              ),
          throwsA(isA<NoSuchEntryException>()));
    });

    test('should throw a NoSuchEntryException if entry doesn\'t exist', () {
      // act & assert
      expect(
          () async => await measurementProvider.editEntry(
                83,
                tCategoryId,
                tEntryEditedValue,
                tEntryEditedNote,
                tEntryEditedDate,
              ),
          throwsA(isA<NoSuchEntryException>()));
    });

    test('should call api to patch the category', () async {
      // act
      await measurementProvider.editEntry(
        tEntryId,
        tCategoryId,
        tEntryEditedValue,
        tEntryEditedNote,
        tEntryEditedDate,
      );

      // assert
      verify(mockWgerBaseProvider.patch(tEntryMapEdited, tCategoryEntriesUri));
    });
  });
}
