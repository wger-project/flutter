/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/workout_logs_repository.dart';

import '../helpers/in_memory_drift.dart';

void main() {
  late DriftPowersyncDatabase db;
  late WorkoutLogRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    repo = WorkoutLogRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Log makeLog({
    int exerciseId = 1,
    int routineId = 100,
    String? sessionId,
    DateTime? date,
    num weight = 50,
    num repetitions = 10,
  }) {
    return Log(
      exerciseId: exerciseId,
      routineId: routineId,
      sessionId: sessionId,
      weight: weight,
      repetitions: repetitions,
      date: date ?? DateTime.utc(2026, 4, 15, 10, 30),
    );
  }

  Future<List<dynamic>> readLogs() => db.select(db.workoutLogTable).get();
  Future<List<dynamic>> readSessions() => db.select(db.workoutSessionTable).get();

  group('addLocalDrift, log already has a sessionId', () {
    test('inserts the log without touching the session table', () async {
      final log = makeLog(sessionId: 'existing-session');

      await repo.addLocalDrift(log);

      final logs = await readLogs();
      expect(logs, hasLength(1));
      expect(logs.first.sessionId, 'existing-session');
      expect(await readSessions(), isEmpty);
    });
  });

  group('addLocalDrift, log without sessionId', () {
    test('reuses an existing session for the same routine and day', () async {
      final existingSession = WorkoutSession(
        id: 'existing-session-1',
        routineId: 100,
        date: DateTime.utc(2026, 4, 15),
      );
      await db.into(db.workoutSessionTable).insert(existingSession.toCompanion());

      final log = makeLog(date: DateTime.utc(2026, 4, 15, 18));
      await repo.addLocalDrift(log);

      expect(await readSessions(), hasLength(1));
      expect(log.sessionId, existingSession.id);
      final logs = await readLogs();
      expect(logs.single.sessionId, existingSession.id);
    });

    test('reuses a server-synced session whose date has no time component', () async {
      // After a round-trip the backend stores the date as a bare 'YYYY-MM-DD'
      // (Django DateField), not the local 'T00:00:00.000Z' format. The day
      // lookup must still match it, otherwise a duplicate session is created
      // and the server rejects it on the unique (date, routine, user)
      // constraint, taking every log on it down with it.
      await db.customStatement(
        "INSERT INTO manager_workoutsession (id, routine_id, date, impression) VALUES ('server-session', 100, '2026-04-15', '2')",
      );

      final log = makeLog(routineId: 100, date: DateTime.utc(2026, 4, 15, 18));
      await repo.addLocalDrift(log);

      expect(await readSessions(), hasLength(1));
      expect(log.sessionId, 'server-session');
      final logs = await readLogs();
      expect(logs.single.sessionId, 'server-session');
    });

    test('creates a new session at midnight UTC of the log date', () async {
      final log = makeLog(date: DateTime.utc(2026, 4, 15, 18, 30));

      await repo.addLocalDrift(log);

      final sessions = await readSessions();
      expect(sessions, hasLength(1));
      expect(sessions.single.date, DateTime.utc(2026, 4, 15));
      expect(log.sessionId, sessions.single.id);
    });

    test('does not reuse a session from a different day', () async {
      await db
          .into(db.workoutSessionTable)
          .insert(
            WorkoutSession(routineId: 100, date: DateTime.utc(2026, 4, 14)).toCompanion(),
          );

      await repo.addLocalDrift(makeLog(date: DateTime.utc(2026, 4, 15)));

      expect(await readSessions(), hasLength(2));
    });

    test('does not reuse a session from a different routine', () async {
      await db
          .into(db.workoutSessionTable)
          .insert(
            WorkoutSession(routineId: 999, date: DateTime.utc(2026, 4, 15)).toCompanion(),
          );

      await repo.addLocalDrift(makeLog(routineId: 100, date: DateTime.utc(2026, 4, 15)));

      expect(await readSessions(), hasLength(2));
    });
  });

  group('updateLocalDrift', () {
    test('overwrites the row with matching id', () async {
      final log = makeLog(sessionId: 'session-1', weight: 50);
      await repo.addLocalDrift(log);

      log.weight = 75;
      await repo.updateLocalDrift(log);

      final rows = await readLogs();
      expect(rows, hasLength(1));
      expect(rows.single.weight, 75);
    });
  });

  group('deleteLocalDrift', () {
    test('removes the row with matching id', () async {
      final log = makeLog(sessionId: 'session-1');
      await repo.addLocalDrift(log);

      await repo.deleteLocalDrift(log.id!);

      expect(await readLogs(), isEmpty);
    });

    test('on a non-existent id is a no-op', () async {
      final log = makeLog(sessionId: 'session-1');
      await repo.addLocalDrift(log);

      await repo.deleteLocalDrift('does-not-exist');

      expect(await readLogs(), hasLength(1));
    });
  });
}
