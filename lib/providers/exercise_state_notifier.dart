import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercise_data.dart';
import 'package:wger/providers/exercise_state.dart';
import 'package:wger/providers/exercises.dart';

part 'exercise_state_notifier.g.dart';

@riverpod
final class ExerciseStateNotifier extends _$ExerciseStateNotifier {
  final _logger = Logger('ExerciseStateNotifier');

  @override
  ExerciseState build() {
    state = ExerciseState(isLoading: true);

    // Load exercises
    ref.listen<AsyncValue<List<Exercise>>>(
      exerciseProvider,
      (previous, next) {
        if (next.isLoading) {
          state = state.copyWith(isLoading: true);
          return;
        }

        if (next.hasError) {
          _logger.warning('Error in exercise stream: ${next.error}');
          state = state.copyWith(isLoading: false);
          return;
        }

        final fresh = next.asData!.value;
        final filtered = _applyFilters(fresh, state.filters);
        state = state.copyWith(exercises: fresh, filteredExercises: filtered, isLoading: false);
      },
      fireImmediately: true,
    );

    // Load equipment
    ref.listen<AsyncValue<List<Equipment>>>(
      exerciseEquipmentProvider,
      (previous, next) {
        if (next.hasValue) {
          state = state.copyWith(equipment: next.asData!.value);
          _ensureFiltersInitialized();
        }
      },
      fireImmediately: true,
    );

    // Load categories
    ref.listen<AsyncValue<List<ExerciseCategory>>>(
      exerciseCategoryProvider,
      (previous, next) {
        if (next.hasValue) {
          state = state.copyWith(categories: next.asData!.value);
          _ensureFiltersInitialized();
        }
      },
      fireImmediately: true,
    );

    return state;
  }

  void _ensureFiltersInitialized() {
    var filters = state.filters;
    var updated = false;

    if (filters.equipment.items.isEmpty && state.equipment.isNotEmpty) {
      final equipmentMap = {for (final e in state.equipment) e: false};
      filters = filters.copyWith(
        equipment: FilterCategory<Equipment>(title: 'Equipment', items: equipmentMap),
      );
      updated = true;
    }

    if (filters.exerciseCategories.items.isEmpty && state.categories.isNotEmpty) {
      final categoryMap = {for (final c in state.categories) c: false};
      filters = filters.copyWith(
        exerciseCategories: FilterCategory<ExerciseCategory>(title: 'Category', items: categoryMap),
      );
      updated = true;
    }

    if (updated) {
      setFilters(filters);
    }
  }

  void setFilters(Filters filters) {
    final filtered = _applyFilters(state.exercises, filters);
    state = state.copyWith(filters: filters, filteredExercises: filtered);
  }

  List<Exercise> _applyFilters(List<Exercise> all, Filters filters) {
    if (filters.isNothingMarked && (filters.searchTerm.length <= 1)) {
      return all;
    }

    var items = all;
    if (filters.searchTerm.length > 1) {
      final term = filters.searchTerm.toLowerCase();
      items = items.where((e) {
        // TODO: FullTextSearch?
        // TODO!!!! translations
        final title = (e.getTranslation('en').name ?? '').toLowerCase();
        return title.contains(term);
      }).toList();
    }

    final selectedCats = filters.exerciseCategories.selected;
    final selectedEquip = filters.equipment.selected;

    return items.where((exercise) {
      final inCategory = selectedCats.isEmpty || selectedCats.contains(exercise.category);
      final hasEquipment =
          selectedEquip.isEmpty || selectedEquip.any((eq) => exercise.equipment.contains(eq));
      return inCategory && hasEquipment;
    }).toList();
  }

  Exercise? getById(int id) {
    try {
      return state.exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
