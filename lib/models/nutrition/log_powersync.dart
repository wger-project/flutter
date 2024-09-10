import 'package:powersync/sqlite3.dart' as sqlite;
import 'package:wger/models/schema.dart';

import '../../powersync.dart';

/// TodoItem represents a result row of a query on "todos".
///
/// This class is immutable - methods on this class do not modify the instance
/// directly. Instead, watch or re-query the data to get the updated item.
/// confirm how the watch works. this seems like a weird pattern
class TodoItem {
  final String id;
  final String description;
  final String? photoId;
  final bool completed;

  TodoItem(
      {required this.id,
      required this.description,
      required this.completed,
      required this.photoId});

  factory TodoItem.fromRow(sqlite.Row row) {
    return TodoItem(
        id: row['id'],
        description: row['description'],
        photoId: row['photo_id'],
        completed: row['completed'] == 1);
  }

  Future<void> toggle() async {
    if (completed) {
      await db.execute(
          'UPDATE $logItemsTable SET completed = FALSE, completed_by = NULL, completed_at = NULL WHERE id = ?',
          [id]);
    } else {
      await db.execute(
          'UPDATE $logItemsTable SET completed = TRUE, completed_by = ?, completed_at = datetime() WHERE id = ?',
          [await getUserId(), id]);
    }
  }

  Future<void> delete() async {
    await db.execute('DELETE FROM $logItemsTable WHERE id = ?', [id]);
  }

  static Future<void> addPhoto(String photoId, String id) async {
    await db.execute('UPDATE $logItemsTable SET photo_id = ? WHERE id = ?', [photoId, id]);
  }
}
/*
  static Stream<List<TodoList>> watchLists() {
    // This query is automatically re-run when data in "lists" or "todos" is modified.
    return db.watch('SELECT * FROM lists ORDER BY created_at, id').map((results) {
      return results.map(TodoList.fromRow).toList(growable: false);
    });
  }
  
 static Future<TodoList> create(String name) async {
    final results = await db.execute('''
      INSERT INTO
        lists(id, created_at, name, owner_id)
        VALUES(uuid(), datetime(), ?, ?)
      RETURNING *
      ''', [name, await getUserId()]);
    return TodoList.fromRow(results.first);
  }
  */