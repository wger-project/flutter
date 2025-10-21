import 'package:powersync/powersync.dart';

const tableMuscles = 'exercises_muscle';
const tableBodyWeights = 'weight_weightentry';

Schema schema = const Schema([
  Table(
    tableMuscles,
    [
      Column.text('name'),
      Column.text('name_en'),
      Column.text('is_front'),
    ],
  ),
  Table(
    tableBodyWeights,
    [
      Column.real('weight'),
      Column.text('date'),
    ],
  ),
]);
