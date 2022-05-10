import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/other/base_provider_test.mocks.dart';
import '../test/utils.dart';
import '../test/workout/gym_mode_screen_test.mocks.dart';
import '../test_data/exercises.dart';
import '../test_data/workouts.dart';

Widget createGymModeScreen({locale = 'en'}) {
  final key = GlobalKey<NavigatorState>();
  final client = MockClient();
  final bases = getTestExerciseBases();

  final squats = bases[0];
  final squatsEn = Exercise(
    id: 1,
    uuid: 'uuid',
    creationDate: DateTime(2021, 1, 15),
    name: 'Squats',
    description: 'add clever text',
    baseId: tBase1.id,
    language: tLanguage1,
  );
  squats.exercises = [squatsEn];

  final benchPress = bases[1];
  final benchPressEn = Exercise(
    id: 1,
    uuid: 'uuid',
    creationDate: DateTime(2021, 1, 15),
    name: 'Bench press',
    description: 'add clever text',
    baseId: tBase1.id,
    language: tLanguage1,
  );
  benchPress.exercises = [benchPressEn];

  final deadLift = bases[2];
  final deadLiftEn = Exercise(
    id: 1,
    uuid: 'uuid',
    creationDate: DateTime(2021, 1, 15),
    name: 'Dead Lift',
    description: 'add clever text',
    baseId: tBase1.id,
    language: tLanguage1,
  );
  deadLift.exercises = [deadLiftEn];

  final crunches = bases[3];
  final crunchesEn = Exercise(
    id: 1,
    uuid: 'uuid',
    creationDate: DateTime(2021, 1, 15),
    name: 'Crunches',
    description: 'add clever text',
    baseId: tBase1.id,
    language: tLanguage1,
  );
  crunches.exercises = [crunchesEn];

  final mockExerciseProvider = MockExercisesProvider();
  when(mockExerciseProvider.findExerciseBaseById(1)).thenReturn(squats);
  when(mockExerciseProvider.findExerciseBaseById(2)).thenReturn(benchPress);
  when(mockExerciseProvider.findExerciseBaseById(3)).thenReturn(crunches);

  final setting1 = Setting(
    setId: 1,
    order: 1,
    exerciseBaseId: 1,
    repetitionUnitId: 1,
    reps: 5,
    weightUnitId: 1,
    comment: 'ddd',
    rir: '2',
  );
  setting1.repetitionUnit = repetitionUnit1;
  setting1.weightUnit = weightUnit1;
  setting1.exerciseBase = squats;
  setting1.weight = 100;

  final setting2 = Setting(
    setId: 1,
    order: 1,
    exerciseBaseId: 2,
    repetitionUnitId: 1,
    reps: 6,
    weightUnitId: 1,
    comment: 'ddd',
    rir: '1.5',
  );
  setting2.repetitionUnit = repetitionUnit1;
  setting2.weightUnit = weightUnit1;
  setting2.exerciseBase = benchPress;
  setting2.weight = 80;

  final setting2b = Setting(
    setId: 1,
    order: 1,
    exerciseBaseId: 2,
    repetitionUnitId: 1,
    reps: 8,
    weightUnitId: 1,
    comment: 'ddd',
    rir: '2',
  );
  setting2b.repetitionUnit = repetitionUnit1;
  setting2b.weightUnit = weightUnit1;
  setting2b.exerciseBase = benchPress;
  setting2b.weight = 60;

  final setting3 = Setting(
    setId: 1,
    order: 1,
    exerciseBaseId: 2,
    repetitionUnitId: 1,
    reps: 20,
    weightUnitId: 1,
    comment: '',
    rir: null,
  );
  setting3.repetitionUnit = repetitionUnit1;
  setting3.weightUnit = weightUnit1;
  setting3.exerciseBase = crunches;

  final setting4 = Setting(
    setId: 1,
    order: 1,
    exerciseBaseId: 2,
    repetitionUnitId: 1,
    reps: 8,
    weightUnitId: 1,
    comment: '',
    rir: null,
  );
  setting4.repetitionUnit = repetitionUnit1;
  setting4.weightUnit = weightUnit1;
  setting4.exerciseBase = deadLift;
  setting4.weight = 120;

  final set1 = Set.withData(
    id: 1,
    day: 1,
    sets: 3,
    order: 1,
  );
  set1.addExerciseBase(squats);
  set1.settings.add(setting1);
  set1.settings.add(setting1);
  set1.settings.add(setting1);
  set1.settings.add(setting1);

  final set2 = Set.withData(
    id: 2,
    day: 1,
    sets: 3,
    order: 1,
  );
  set2.addExerciseBase(benchPress);
  set2.settings.add(setting2);
  set2.settings.add(setting2);
  set2.settings.add(setting2b);
  set2.settings.add(setting2b);

  final set3 = Set.withData(
    id: 3,
    day: 1,
    sets: 3,
    order: 1,
  );
  set3.addExerciseBase(crunches);
  set3.settings.add(setting3);

  final set4 = Set.withData(
    id: 4,
    day: 1,
    sets: 3,
    order: 1,
  );
  set4.addExerciseBase(deadLift);
  set4.settings.add(setting4);
  set4.settings.add(setting4);
  set4.settings.add(setting4);
  set4.settings.add(setting4);

  final day1 = Day()
    ..id = 1
    ..workoutId = 1
    ..description = 'test day 1'
    ..daysOfWeek = [1, 2];
  day1.sets.add(set1);
  day1.sets.add(set2);
  day1.sets.add(set4);
  day1.sets.add(set3);

  final workout = WorkoutPlan(
    id: 1,
    creationDate: DateTime(2021, 01, 01),
    name: 'test workout 1',
    days: [day1],
  );

  return ChangeNotifierProvider<WorkoutPlansProvider>(
    create: (context) => WorkoutPlansProvider(
      testAuthProvider,
      mockExerciseProvider,
      [workout],
      client,
    ),
    child: ChangeNotifierProvider<ExercisesProvider>(
      create: (context) => mockExerciseProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        theme: wgerTheme,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: RouteSettings(arguments: workout.days.first),
              builder: (_) => GymModeScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
        routes: {
          WorkoutPlanScreen.routeName: (ctx) => WorkoutPlanScreen(),
        },
      ),
    ),
  );
}
