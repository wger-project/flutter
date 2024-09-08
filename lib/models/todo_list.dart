import 'package:powersync/sqlite3.dart' as sqlite;
import 'package:wger/powersync.dart';

import 'todo_item.dart';

/// TodoList represents a result row of a query on "lists".
///
/// This class is immutable - methods on this class do not modify the instance
/// directly. Instead, watch or re-query the data to get the updated list.
class TodoList {
  /// List id (UUID).
  final String id;

  /// Descriptive name.
  final String name;

  /// Number of completed todos in this list.
  final int? completedCount;

  /// Number of pending todos in this list.
  final int? pendingCount;

  TodoList({required this.id, required this.name, this.completedCount, this.pendingCount});

  factory TodoList.fromRow(sqlite.Row row) {
    return TodoList(
      id: row['id'],
      name: row['name'],
      completedCount: row['completed_count'],
      pendingCount: row['pending_count'],
    );
  }

  /// Watch all lists.
  static Stream<List<TodoList>> watchLists() {
    // This query is automatically re-run when data in "lists" or "todos" is modified.
    return db.watch('SELECT * FROM lists ORDER BY created_at, id').map((results) {
      return results.map(TodoList.fromRow).toList(growable: false);
    });
  }

  /// Watch all lists, with [completedCount] and [pendingCount] populated.
  static Stream<List<TodoList>> watchListsWithStats() {
    // This query is automatically re-run when data in "lists" or "todos" is modified.
    return db.watch('''
      SELECT
        *,
        (SELECT count() FROM todos WHERE list_id = lists.id AND completed = TRUE) as completed_count,
        (SELECT count() FROM todos WHERE list_id = lists.id AND completed = FALSE) as pending_count
      FROM lists
      ORDER BY created_at
    ''').map((results) {
      return results.map(TodoList.fromRow).toList(growable: false);
    });
  }

  /// Create a new list
  static Future<TodoList> create(String name) async {
    final results = await db.execute(
      '''
      INSERT INTO
        lists(id, created_at, name, owner_id)
        VALUES(uuid(), datetime(), ?, ?)
      RETURNING *
      ''',
      [name, await getUserId()],
    );
    return TodoList.fromRow(results.first);
  }

  /// Watch items within this list.
  Stream<List<TodoItem>> watchItems() {
    return db.watch('SELECT * FROM todos WHERE list_id = ? ORDER BY created_at DESC, id',
        parameters: [id]).map((event) {
      return event.map(TodoItem.fromRow).toList(growable: false);
    });
  }

  /// Delete this list.
  Future<void> delete() async {
    await db.execute('DELETE FROM lists WHERE id = ?', [id]);
  }

  /// Find list item.
  static Future<TodoList> find(id) async {
    final results = await db.get('SELECT * FROM lists WHERE id = ?', [id]);
    return TodoList.fromRow(results);
  }

  /// Add a new todo item to this list.
  Future<TodoItem> add(String description) async {
    final results = await db.execute('''
      INSERT INTO
        todos(id, created_at, completed, list_id, description, created_by)
        VALUES(uuid(), datetime(), FALSE, ?, ?, ?)
      RETURNING *
    ''', [id, description, await getUserId()]);
    return TodoItem.fromRow(results.first);
  }
}
