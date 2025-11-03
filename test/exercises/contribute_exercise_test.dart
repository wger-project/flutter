/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/core_data.dart';
import 'package:wger/providers/exercise_data.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/add_exercise_screen.dart';

import '../../test_data/profile.dart';
import 'contribute_exercise_test.mocks.dart';

@GenerateMocks([AddExerciseProvider, UserProvider])
void main() {
  final mockAddExerciseProvider = MockAddExerciseProvider();
  final mockUserProvider = MockUserProvider();

  setUp(() {
    when(mockAddExerciseProvider.equipment).thenReturn([]);
    when(mockAddExerciseProvider.primaryMuscles).thenReturn([]);
    when(mockAddExerciseProvider.secondaryMuscles).thenReturn([]);
    when(mockAddExerciseProvider.variationConnectToExercise).thenReturn(null);
  });

  Widget createExerciseScreen({locale = 'en'}) {
    return riverpod.ProviderScope(
      overrides: [
        languagesProvider.overrideWith((ref) => Stream<List<Language>>.value(<Language>[])),
        exercisesProvider.overrideWith((ref) => Stream<List<Exercise>>.value(<Exercise>[])),
        exerciseMusclesProvider.overrideWith((ref) => Stream<List<Muscle>>.value(<Muscle>[])),
        exerciseCategoriesProvider.overrideWith(
          (ref) => Stream<List<ExerciseCategory>>.value(<ExerciseCategory>[]),
        ),
        exerciseEquipmentProvider.overrideWith(
          (ref) => Stream<List<Equipment>>.value(<Equipment>[]),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<AddExerciseProvider>(create: (context) => mockAddExerciseProvider),
          ChangeNotifierProvider<UserProvider>(create: (context) => mockUserProvider),
        ],
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AddExerciseScreen(),
        ),
      ),
    );
  }

  testWidgets('Unverified users see an info widget', (WidgetTester tester) async {
    // Arrange
    tProfile1.isTrustworthy = false;
    when(mockUserProvider.profile).thenReturn(tProfile1);

    // Act
    await tester.pumpWidget(createExerciseScreen());

    // Assert
    expect(find.byType(EmailNotVerified), findsOneWidget);
    expect(find.byType(AddExerciseStepper), findsNothing);
  });

  testWidgets('Verified users see the stepper to add exercises', (WidgetTester tester) async {
    // Arrange
    tProfile1.isTrustworthy = true;
    when(mockUserProvider.profile).thenReturn(tProfile1);

    // Act
    await tester.pumpWidget(createExerciseScreen());

    // Assert
    expect(find.byType(EmailNotVerified), findsNothing);
    expect(find.byType(AddExerciseStepper), findsOneWidget);
  });
}
