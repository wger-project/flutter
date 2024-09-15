import 'package:powersync/powersync.dart';

const tableMuscles = 'exercises_muscle';
const tableLogItems = 'nutrition_logitem';
const tableNutritionPlans = 'nutrition_nutritionplan';
const tableMeals = 'nutrition_meal';
const tableMealItems = 'nutrition_mealitem';

Schema schema = const Schema([
  Table(
    tableMuscles,
    [Column.text('name'), Column.text('name_en'), Column.text('is_front')],
  ),
  Table(
    tableNutritionPlans,
    [
      Column.text('creation_date'),
      Column.text('description'),
      Column.integer('has_goal_calories'),
      Column.integer('user_id'),
      Column.integer('only_logging'),
      Column.integer('goal_carbohydrates'),
      Column.integer('goal_energy'),
      Column.integer('goal_fat'),
      Column.integer('goal_protein'),
      Column.integer('goal_fiber'),
    ],
  ),
  Table(
    tableLogItems,
    [
      Column.text('datetime'),
      Column.text('comment'),
      Column.integer('amount'),
      Column.integer('ingredient_id'),
      Column.integer('plan_id'),
      Column.integer('weight_unit_id'),
      Column.integer('meal_id'), // optional
    ],
    indexes: [
      // Index('plan', [IndexedColumn('plan_id')])
    ],
  ),
  Table(
    tableMeals,
    [
      Column.integer('order'),
      Column.text('time'),
      Column.integer('plan_id'),
      Column.text('name'),
    ],
  ),
  Table(
    tableMealItems,
    [
      Column.integer('order'),
      Column.integer('amount'),
      Column.integer('ingredient_id'),
      Column.integer('meal_id'),
      Column.integer('weight_unit_id'),
    ],
  ),
]);
