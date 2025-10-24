import 'package:powersync/powersync.dart';

Schema schema = const Schema([
  //
  // Core
  //
  Table(
    'core_language',
    [
      Column.text('short_name'),
      Column.text('full_name'),
    ],
  ),

  //
  // Exercises
  //
  Table(
    'exercises_exercise',
    [
      Column.text('uuid'),
      Column.integer('category_id'),
      Column.integer('variation_id'),
      Column.text('created'),
      Column.text('last_update'),
    ],
    indexes: [
      Index('category', [IndexedColumn('category_id')]),
      Index('variation', [IndexedColumn('variation_id')]),
    ],
  ),
  Table(
    'exercises_translation',
    [
      Column.text('uuid'),
      Column.integer('language_id'),
      Column.integer('exercise_id'),
      Column.text('description'),
      Column.text('name'),
      Column.text('created'),
      Column.text('last_update'),
    ],
    indexes: [
      Index('language', [IndexedColumn('language_id')]),
      Index('exercise', [IndexedColumn('exercise_id')]),
    ],
  ),
  Table(
    'exercises_muscle',
    [
      Column.text('name'),
      Column.text('name_en'),
      Column.text('is_front'),
    ],
  ),
  Table(
    'exercises_exercise_muscles',
    [
      Column.integer('exercise_id'),
      Column.integer('muscle_id'),
    ],
    indexes: [
      Index('muscle', [IndexedColumn('muscle_id')]),
      Index('exercise', [IndexedColumn('exercise_id')]),
    ],
  ),
  Table(
    'exercises_exercise_muscles_secondary',
    [
      Column.integer('exercise_id'),
      Column.integer('muscle_id'),
    ],
    indexes: [
      Index('muscle', [IndexedColumn('muscle_id')]),
      Index('exercise', [IndexedColumn('exercise_id')]),
    ],
  ),
  Table(
    'exercises_equipment',
    [
      Column.text('name'),
    ],
  ),
  Table(
    'exercises_exercise_equipment',
    [
      Column.text('exercise_id'),
      Column.text('equipment_id'),
    ],
    indexes: [
      Index('equipment', [IndexedColumn('equipment_id')]),
      Index('exercise', [IndexedColumn('exercise_id')]),
    ],
  ),
  Table(
    'exercises_exercisecategory',
    [
      Column.text('name'),
    ],
  ),
  Table(
    'exercises_exerciseimage',
    [
      Column.text('uuid'),
      Column.integer('exercise_id'),
      Column.text('url'),
      Column.integer('is_main'),
    ],
    indexes: [
      Index('exercise', [IndexedColumn('exercise_id')]),
    ],
  ),
  Table(
    'exercises_exercisevideo',
    [
      Column.text('uuid'),
      Column.integer('exercise_id'),
      Column.text('url'),
      Column.integer('size'),
      Column.integer('duration'),
      Column.integer('width'),
      Column.integer('height'),
      Column.text('codec'),
      Column.text('codec_long'),
      Column.integer('license_id'),
      Column.text('license_author'),
    ],
    indexes: [
      Index('exercise', [IndexedColumn('exercise_id')]),
    ],
  ),

  //
  // User data
  //
  Table(
    'weight_weightentry',
    [
      Column.text('uuid'),
      Column.real('weight'),
      Column.text('date'),
    ],
  ),
  Table(
    'measurements_category',
    [
      Column.text('name'),
      Column.real('unit'),
    ],
  ),
  Table(
    'manager_workoutlog',
    [
      Column.integer('exercise_id'),
      Column.integer('routine_id'),
      Column.integer('session_id'),
      Column.integer('iteration'),
      Column.integer('slot_entry_id'),
      Column.real('rir'),
      Column.real('rir_target'),
      Column.real('repetitions'),
      Column.real('repetitions_target'),
      Column.integer('repetitions_unit_id'),
      Column.real('weight'),
      Column.real('weight_target'),
      Column.integer('weight_unit_id'),
      Column.text('date'),
    ],
    indexes: [
      Index('exercise', [IndexedColumn('exercise_id')]),
      Index('slot_entry', [IndexedColumn('slot_entry_id')]),
      Index('routine', [IndexedColumn('routine_id')]),
      Index('session', [IndexedColumn('session_id')]),
      Index('repetitions_unit', [IndexedColumn('repetitions_unit_id')]),
      Index('weight_unit', [IndexedColumn('weight_unit_id')]),
    ],
  ),
]);
