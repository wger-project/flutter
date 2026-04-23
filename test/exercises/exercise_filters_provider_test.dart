
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/exercises/exercise_filters.dart';
import 'package:wger/providers/exercise_filters_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  test('default values are correct on first load', () async {
    final container = ProviderContainer.test();
    final filters = await container.read(exerciseFiltersProvider.future);

    expect(filters.searchLanguage, ExerciseSearchLanguage.currentAndEnglish);
    expect(filters.searchMode, ExerciseSearchMode.fulltext);
    expect(filters.selectedCategory, isNull);
  });

  test('chooseLanguage updates provider and saves to SharedPreferences', () async {
    final container = ProviderContainer.test();
    await container.read(exerciseFiltersProvider.future);
    final notifier = container.read(exerciseFiltersProvider.notifier);

    await notifier.chooseLanguage(ExerciseSearchLanguage.all);

    final filters = await container.read(exerciseFiltersProvider.future);
    expect(filters.searchLanguage, ExerciseSearchLanguage.all);
    expect(
      await PreferenceHelper.instance.getExerciseSearchLanguage(),
      ExerciseSearchLanguage.all,
    );
  });

  test('chooseSearchMode updates provider and saves to SharedPreferences', () async {
    final container = ProviderContainer.test();
    await container.read(exerciseFiltersProvider.future);
    final notifier = container.read(exerciseFiltersProvider.notifier);

    await notifier.chooseSearchMode(ExerciseSearchMode.exact);

    final filters = await container.read(exerciseFiltersProvider.future);
    expect(filters.searchMode, ExerciseSearchMode.exact);
    expect(
      await PreferenceHelper.instance.getExerciseSearchMode(),
      ExerciseSearchMode.exact,
    );
  });

  test('selectCategory updates state but does NOT save to SharedPreferences', () async {
    final container = ProviderContainer.test();
    await container.read(exerciseFiltersProvider.future);
    final notifier = container.read(exerciseFiltersProvider.notifier);

    // selectCategory is synchronous — no await needed
    notifier.selectCategory(null);

    final filters = await container.read(exerciseFiltersProvider.future);
    expect(filters.selectedCategory, isNull);
  });

  test('settings persist across provider container restart', () async {
    // create container, set values, destroy, create new container
    final container1 = ProviderContainer.test();
    await container1.read(exerciseFiltersProvider.future);
    await container1.read(exerciseFiltersProvider.notifier).chooseLanguage(
      ExerciseSearchLanguage.current,
    );
    await container1.read(exerciseFiltersProvider.notifier).chooseSearchMode(
      ExerciseSearchMode.exact,
    );
    container1.dispose();

    // New container
    final container2 = ProviderContainer.test();
    final filters = await container2.read(exerciseFiltersProvider.future);
    expect(filters.searchLanguage, ExerciseSearchLanguage.current);
    expect(filters.searchMode, ExerciseSearchMode.exact);
  });
}