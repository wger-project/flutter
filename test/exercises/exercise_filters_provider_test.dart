import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/core/search_options.dart';
import 'package:wger/models/exercises/category.dart';
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

    expect(filters.searchLanguage, SearchLanguage.currentAndEnglish);
    expect(filters.searchMode, ExerciseSearchMode.fulltext);
    expect(filters.selectedCategories, isEmpty);
  });

  test('chooseLanguage updates provider and saves to SharedPreferences', () async {
    final container = ProviderContainer.test();
    await container.read(exerciseFiltersProvider.future);
    final notifier = container.read(exerciseFiltersProvider.notifier);

    await notifier.chooseLanguage(SearchLanguage.all);

    final filters = await container.read(exerciseFiltersProvider.future);
    expect(filters.searchLanguage, SearchLanguage.all);
    expect(
      await PreferenceHelper.instance.getExerciseSearchLanguage(),
      SearchLanguage.all,
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

  test('toggleCategory adds and removes categories without persisting them', () async {
    final container = ProviderContainer.test();
    await container.read(exerciseFiltersProvider.future);
    final notifier = container.read(exerciseFiltersProvider.notifier);

    const abs = ExerciseCategory(id: 1, name: 'Abs');
    const arms = ExerciseCategory(id: 2, name: 'Arms');

    // Add two categories
    notifier.toggleCategory(abs);
    notifier.toggleCategory(arms);

    var filters = await container.read(exerciseFiltersProvider.future);
    expect(filters.selectedCategories, {abs, arms});

    // Tapping an already-selected category removes it
    notifier.toggleCategory(abs);
    filters = await container.read(exerciseFiltersProvider.future);
    expect(filters.selectedCategories, {arms});

    // clearCategories empties the set
    notifier.clearCategories();
    filters = await container.read(exerciseFiltersProvider.future);
    expect(filters.selectedCategories, isEmpty);
  });

  test('resetAll clears the category selection', () async {
    final container = ProviderContainer.test();
    await container.read(exerciseFiltersProvider.future);
    final notifier = container.read(exerciseFiltersProvider.notifier);

    notifier.toggleCategory(const ExerciseCategory(id: 1, name: 'Abs'));
    await notifier.resetAll();

    final filters = await container.read(exerciseFiltersProvider.future);
    expect(filters.selectedCategories, isEmpty);
  });

  test('settings persist across provider container restart', () async {
    // create container, set values, destroy, create new container
    final container1 = ProviderContainer.test();
    await container1.read(exerciseFiltersProvider.future);
    await container1
        .read(exerciseFiltersProvider.notifier)
        .chooseLanguage(
          SearchLanguage.current,
        );
    await container1
        .read(exerciseFiltersProvider.notifier)
        .chooseSearchMode(
          ExerciseSearchMode.exact,
        );
    container1.dispose();

    // New container
    final container2 = ProviderContainer.test();
    final filters = await container2.read(exerciseFiltersProvider.future);
    expect(filters.searchLanguage, SearchLanguage.current);
    expect(filters.searchMode, ExerciseSearchMode.exact);
  });
}
