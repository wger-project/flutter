import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/categories.dart';
import 'package:wger/features/measurements/widgets/categories_card.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import '../../../../test_data/measurements.dart';
import '../providers/measurement_notifier_test.mocks.dart';

Widget _wrap(MockMeasurementRepository mockRepo) {
  return ProviderScope(
    overrides: [
      measurementRepositoryProvider.overrideWithValue(mockRepo),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: CategoriesList()),
    ),
  );
}

void main() {
  late MockMeasurementRepository mockRepo;

  setUp(() {
    mockRepo = MockMeasurementRepository();
  });

  group('CategoriesList', () {
    testWidgets('two top-level categories render two CategoriesCard widgets', (tester) async {
      when(mockRepo.watchAll()).thenAnswer((_) => Stream.value(getMeasurementCategories()));

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesCard), findsNWidgets(2));
    });

    testWidgets(' children of multi-value groups are not rendered as own list items', (
      tester,
    ) async {
      // Only 'bp' should produce a CategoriesCard; children stay inside it.
      when(mockRepo.watchAll()).thenAnswer((_) => Stream.value(getBloodPressureGroup()));

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesCard), findsOneWidget);
      expect(find.text('Systolic'), findsOneWidget);
      expect(find.text('Diastolic'), findsOneWidget);
    });

    testWidgets('empty list renders no CategoriesCard', (tester) async {
      when(mockRepo.watchAll()).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesCard), findsNothing);
    });
  });
}
