import 'package:powersync/powersync.dart';

const tableMuscle = 'exercises_muscle';
const tableBodyWeight = 'weight_weightentry';

Schema schema = const Schema([
  Table(
    tableMuscle,
    [
      Column.text('name'),
      Column.text('name_en'),
      Column.text('is_front'),
    ],
  ),
  Table(
    tableBodyWeight,
    [
      Column.text('uuid'),
      Column.real('weight'),
      Column.text('date'),
    ],
  ),
]);
