import 'package:powersync/powersync.dart';

/* nutrition tables in postgres:
| public | nutrition_image                                    | table>
| public | nutrition_ingredient                               | table> * # millions of ingredients
| public | nutrition_ingredientcategory                       | table>
| public | nutrition_ingredientweightunit                     | table>
| public | nutrition_logitem                                  | table> * OK
| public | nutrition_meal                                     | table> * OK 
| public | nutrition_mealitem                                 | table> *
| public | nutrition_nutritionplan                            | table> * OK
| public | nutrition_weightunit                               | table> 

assumptions: nutrition_ingredientcategory, nutrition_weightunit, nutrition_ingredientweightunit globals?
*/

// User,NutritionPlan,Meal,LogItem,MealItem,Ingredient
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
      Column.integer('remote_id'),
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
      Column.integer('remote_id'),
      Column.integer('ingredient_id'),
      Column.text('plan_id'),
      Column.integer('weight_unit_id'),
      Column.text('meal_id'), // optional
    ],
    indexes: [
      // Index('plan', [IndexedColumn('plan_id')])
    ],
  ),
  Table(
    tableMeals,
    [
      Column.integer('order'),
      Column.integer('remote_id'),
      Column.text('time'),
      Column.text('plan_id'),
      Column.text('name'),
    ],
  ),
  Table(
    tableMealItems,
    [
      Column.integer('order'),
      Column.integer('amount'),
      Column.integer('ingredient_id'),
      Column.text('meal_id'),
      Column.integer('remote_id'),
      Column.integer('weight_unit_id'),
    ],
  ),
]);
