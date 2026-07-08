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
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/models/session.dart';
import 'package:wger/features/routines/providers/workout_logs_repository.dart';

import '../../../helpers/in_memory_drift.dart';

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

  Future<void> seedUnits() async {
    await db
        .into(db.routineRepetitionUnitTable)
        .insert(RoutineRepetitionUnitTableCompanion.insert(id: 1, name: 'Repetitions'));
    await db
        .into(db.routineWeightUnitTable)
        .insert(RoutineWeightUnitTableCompanion.insert(id: 1, name: 'kg'));
  }

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

  group('watchLogsByExerciseDrift', () {
    test('emits an empty list when nothing matches', () async {
      expect(await repo.watchLogsByExerciseDrift(routineId: 100, exerciseId: 1).first, isEmpty);
    });

    test('returns only logs for the given routine and exercise', () async {
      await seedUnits();
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(exerciseId: 1, routineId: 100).toCompanion());
      // Different exercise, same routine.
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(exerciseId: 2, routineId: 100).toCompanion());
      // Same exercise, different routine.
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(exerciseId: 1, routineId: 999).toCompanion());

      final logs = await repo.watchLogsByExerciseDrift(routineId: 100, exerciseId: 1).first;

      expect(logs, hasLength(1));
      expect(logs.single.exerciseId, 1);
      expect(logs.single.routineId, 100);
    });

    test('sorts by date descending', () async {
      await seedUnits();
      // Tag each row with a distinct weight so the order can be asserted without
      // depending on the timezone the date converter reads back in.
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(date: DateTime.utc(2026, 4, 14), weight: 14).toCompanion());
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(date: DateTime.utc(2026, 4, 16), weight: 16).toCompanion());
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(date: DateTime.utc(2026, 4, 15), weight: 15).toCompanion());

      final logs = await repo.watchLogsByExerciseDrift(routineId: 100, exerciseId: 1).first;

      expect(logs.map((l) => l.weight).toList(), [16, 15, 14]);
    });

    test('attaches the repetition and weight unit to each log', () async {
      await seedUnits();
      await db.into(db.workoutLogTable).insert(makeLog().toCompanion());

      final logs = await repo.watchLogsByExerciseDrift(routineId: 100, exerciseId: 1).first;

      expect(logs.single.repetitionsUnitObj?.name, 'Repetitions');
      expect(logs.single.weightUnitObj?.name, 'kg');
    });

    test('returns the logs of every routine when no routine is given', () async {
      await seedUnits();
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(exerciseId: 1, routineId: 100).toCompanion());
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(exerciseId: 1, routineId: 999).toCompanion());
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(exerciseId: 2, routineId: 100).toCompanion());

      final logs = await repo.watchLogsByExerciseDrift(exerciseId: 1).first;

      expect(logs.map((l) => l.routineId).toSet(), {100, 999});
    });

    test('only returns logs on or after the given date', () async {
      await seedUnits();
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(date: DateTime.utc(2026, 4, 14), weight: 14).toCompanion());
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(date: DateTime.utc(2026, 4, 16), weight: 16).toCompanion());

      final logs = await repo
          .watchLogsByExerciseDrift(
            routineId: 100,
            exerciseId: 1,
            since: DateTime.utc(2026, 4, 15),
          )
          .first;

      expect(logs.map((l) => l.weight).toList(), [16]);
    });

    test('compares a cutoff given in local time as an instant', () async {
      // Dates are stored as UTC text, a local cutoff is bound with its offset
      // appended. Both sides go through JULIANDAY, so the comparison happens on
      // the instant rather than on the raw string.
      await seedUnits();
      await db
          .into(db.workoutLogTable)
          .insert(makeLog(date: DateTime.utc(2026, 4, 15, 9)).toCompanion());

      final justBefore = await repo
          .watchLogsByExerciseDrift(
            routineId: 100,
            exerciseId: 1,
            since: DateTime.utc(2026, 4, 15, 8, 30).toLocal(),
          )
          .first;
      expect(justBefore, hasLength(1), reason: 'Cutoff half an hour before the log');

      final justAfter = await repo
          .watchLogsByExerciseDrift(
            routineId: 100,
            exerciseId: 1,
            since: DateTime.utc(2026, 4, 15, 9, 30).toLocal(),
          )
          .first;
      expect(justAfter, isEmpty, reason: 'Cutoff half an hour after the log');
    });

    test('re-emits when a matching log is added', () async {
      await seedUnits();
      final stream = repo.watchLogsByExerciseDrift(routineId: 100, exerciseId: 1);
      final emissions = <List<Log>>[];
      final sub = stream.listen(emissions.add);

      await db.into(db.workoutLogTable).insert(makeLog().toCompanion());
      await pumpEventQueue();

      expect(emissions.last, hasLength(1));
      await sub.cancel();
    });
  });
}
