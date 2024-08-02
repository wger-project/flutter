import 'package:powersync/powersync.dart';

const todosTable = 'todos';

// these are the same ones as in postgres, except for 'id'
Schema schema = const Schema(([
  Table(todosTable, [
    Column.text('list_id'),
    Column.text('created_at'),
    Column.text('completed_at'),
    Column.text('description'),
    Column.integer('completed'),
    Column.text('created_by'),
    Column.text('completed_by'),
  ], indexes: [
    // Index to allow efficient lookup within a list
    Index('list', [IndexedColumn('list_id')])
  ]),
  Table('lists',
      [Column.text('created_at'), Column.text('name'), Column.text('owner_id')])
]));

// post gres columns:
// todos:
// id                                   | created_at                    | completed_at | description       | completed | created_by | completed_by | list_id
// lists:
// id                                   | created_at                    | name        | owner_id

// diagnostics app:
/*
new Schema([
  new Table({
    name: 'lists', // same as flutter
    columns: [
      new Column({ name: 'created_at', type: ColumnType.TEXT }),
      new Column({ name: 'name', type: ColumnType.TEXT }),
      new Column({ name: 'owner_id', type: ColumnType.TEXT })
    ]
  }),
  new Table({
    name: 'todos', // misses completed_at and completed_by, until these actually get populated with something
    columns: [
      new Column({ name: 'created_at', type: ColumnType.TEXT }),
      new Column({ name: 'description', type: ColumnType.TEXT }),
      new Column({ name: 'completed', type: ColumnType.INTEGER }),
      new Column({ name: 'created_by', type: ColumnType.TEXT }),
      new Column({ name: 'list_id', type: ColumnType.TEXT })
    ]
  })
])

    Column.text('completed_at'),
    Column.text('completed_by'),
*/
