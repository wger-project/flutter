import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/other/base_provider_test.mocks.dart';
import '../test/utils.dart';
import '../test/workout/gym_mode_screen_test.mocks.dart';
import '../test_data/exercises.dart';
import '../test_data/workouts.dart';

Future<void> takeScreenshot(tester, binding, name) async {
  if (Platform.isAndroid) {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  }
  await binding.takeScreenshot(name);
}

// Languages for which the translations are almost complete in weblate
const languages = ['de', 'en', 'es', 'it', 'jp', 'ca', 'pt', 'ru', 'tr', 'zh', 'fr', 'he'];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget createNutritionalPlanScreen({locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();
    final client = MockClient();

    final muesli = Ingredient(
      id: 1,
      code: '123456787',
      name: 'Müsli',
      creationDate: DateTime(2021, 5, 1),
      energy: 500,
      carbohydrates: 10,
      carbohydratesSugar: 2,
      protein: 5,
      fat: 20,
      fatSaturated: 7,
      fibres: 12,
      sodium: 0.5,
    );
    final milk = Ingredient(
      id: 1,
      code: '123456787',
      name: 'Milk',
      creationDate: DateTime(2021, 5, 1),
      energy: 500,
      carbohydrates: 10,
      carbohydratesSugar: 2,
      protein: 5,
      fat: 20,
      fatSaturated: 7,
      fibres: 12,
      sodium: 0.5,
    );
    final apple = Ingredient(
      id: 1,
      code: '123456787',
      name: 'Apple',
      creationDate: DateTime(2021, 5, 1),
      energy: 500,
      carbohydrates: 10,
      carbohydratesSugar: 2,
      protein: 5,
      fat: 20,
      fatSaturated: 7,
      fibres: 12,
      sodium: 0.5,
    );

    final mealItem1 = MealItem(ingredientId: 1, amount: 100, ingredient: muesli);
    final mealItem2 = MealItem(ingredientId: 2, amount: 75, ingredient: milk);
    final mealItem3 = MealItem(ingredientId: 3, amount: 100, ingredient: apple);

    final meal1 = Meal(
      id: 1,
      plan: 1,
      time: const TimeOfDay(hour: 8, minute: 30),
      name: 'Breakfast',
      mealItems: [mealItem1, mealItem2],
    );

    final meal2 = Meal(
      id: 2,
      plan: 1,
      time: const TimeOfDay(hour: 11, minute: 0),
      name: 'Snack 1',
      mealItems: [mealItem3],
    );

    final NutritionalPlan plan = NutritionalPlan(
      id: 1,
      description: 'Mini diet',
      creationDate: DateTime(2021, 5, 23),
      meals: [meal1, meal2],
    );

    // Add logs
    plan.logs.add(Log.fromMealItem(mealItem1, 1, 1, DateTime(2021, 6, 1)));
    plan.logs.add(Log.fromMealItem(mealItem2, 1, 1, DateTime(2021, 6, 1)));
    plan.logs.add(Log.fromMealItem(mealItem3, 1, 1, DateTime(2021, 6, 10)));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NutritionPlansProvider>(
          create: (context) => NutritionPlansProvider(testAuthProvider, [], client),
        ),
        ChangeNotifierProvider<BodyWeightProvider>(
          create: (context) => BodyWeightProvider(testAuthProvider, [], client),
        ),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: wgerTheme,
        navigatorKey: key,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: RouteSettings(arguments: plan),
              builder: (_) => NutritionalPlanScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
      ),
    );
  }

  Widget createWeightScreen({locale = 'en'}) {
    return ChangeNotifierProvider<BodyWeightProvider>(
      create: (context) => BodyWeightProvider(
        testAuthProvider,
        [
          WeightEntry(id: 1, weight: 86, date: DateTime(2021, 01, 01)),
          WeightEntry(id: 2, weight: 81, date: DateTime(2021, 01, 10)),
          WeightEntry(id: 3, weight: 82, date: DateTime(2021, 01, 20)),
          WeightEntry(id: 4, weight: 83, date: DateTime(2021, 01, 30)),
          WeightEntry(id: 5, weight: 86, date: DateTime(2021, 02, 20)),
          WeightEntry(id: 6, weight: 90, date: DateTime(2021, 02, 28)),
          WeightEntry(id: 7, weight: 91, date: DateTime(2021, 03, 20)),
          WeightEntry(id: 8, weight: 91.1, date: DateTime(2021, 03, 30)),
          WeightEntry(id: 9, weight: 90, date: DateTime(2021, 05, 1)),
          WeightEntry(id: 10, weight: 91, date: DateTime(2021, 6, 5)),
          WeightEntry(id: 11, weight: 89, date: DateTime(2021, 6, 20)),
          WeightEntry(id: 12, weight: 88, date: DateTime(2021, 7, 15)),
          WeightEntry(id: 13, weight: 86, date: DateTime(2021, 7, 20)),
          WeightEntry(id: 14, weight: 83, date: DateTime(2021, 7, 30)),
          WeightEntry(id: 15, weight: 80, date: DateTime(2021, 8, 10))
        ],
        MockClient(),
      ),
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: wgerTheme,
        home: WeightScreen(),
        routes: {
          FormScreen.routeName: (ctx) => FormScreen(),
        },
      ),
    );
  }

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

  group('Generate screenshots', () {
    for (final language in languages) {
      testWidgets('nutritional plan detail - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createNutritionalPlanScreen(locale: language));
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, binding, '$language/03-nutritional-plan');
      });

      testWidgets('body weight screen - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createWeightScreen(locale: language));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, binding, '$language/05-weight');
      });

      testWidgets('gym mode screen - $language', (WidgetTester tester) async {
        await tester.pumpWidget(createGymModeScreen(locale: language));
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, binding, '$language/05-gym-mode');
      });
    }
  });
}
