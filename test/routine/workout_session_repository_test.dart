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
import 'package:wger/providers/workout_session_repository.dart';

import '../helpers/in_memory_drift.dart';

void main() {
  late DriftPowersyncDatabase db;
  late WorkoutSessionRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    repo = WorkoutSessionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedUnits() async {
    await db
        .into(db.routineRepetitionUnitTable)
        .insert(RoutineRepetitionUnitTableCompanion.insert(id: 1, name: 'Repetitions'));
    await db
        .into(db.routineWeightUnitTable)
        .insert(RoutineWeightUnitTableCompanion.insert(id: 1, name: 'kg'));
  }

  WorkoutSession makeSession({
    String? id,
    int routineId = 100,
    DateTime? date,
  }) {
    return WorkoutSession(
      id: id,
      routineId: routineId,
      date: date ?? DateTime.utc(2026, 4, 15),
    );
  }

  Log makeLog({
    String? id,
    required String sessionId,
    int exerciseId = 1,
    int routineId = 100,
    DateTime? date,
    num weight = 50,
  }) {
    return Log(
      id: id,
      exerciseId: exerciseId,
      routineId: routineId,
      sessionId: sessionId,
      weight: weight,
      repetitions: 10,
      date: date ?? DateTime.utc(2026, 4, 15, 10, 30),
    );
  }

  group('CRUD', () {
    test('addLocalDrift inserts a row', () async {
      final session = makeSession();

      await repo.addLocalDrift(session);

      final rows = await db.select(db.workoutSessionTable).get();
      expect(rows, hasLength(1));
      expect(rows.first.id, session.id);
    });

    test('editLocalDrift overwrites the row with matching id', () async {
      final session = makeSession();
      await repo.addLocalDrift(session);

      session.notes = 'updated';
      await repo.editLocalDrift(session);

      final rows = await db.select(db.workoutSessionTable).get();
      expect(rows.single.notes, 'updated');
    });

    test('deleteLocalDrift removes the row with matching id', () async {
      final session = makeSession();
      await repo.addLocalDrift(session);

      await repo.deleteLocalDrift(session.id);

      expect(await db.select(db.workoutSessionTable).get(), isEmpty);
    });

    test('deleteLocalDrift on a non-existent id is a no-op', () async {
      await repo.addLocalDrift(makeSession());

      await repo.deleteLocalDrift('does-not-exist');

      expect(await db.select(db.workoutSessionTable).get(), hasLength(1));
    });
  });

  group('watchAllDrift', () {
    test('emits an empty list when no sessions exist', () async {
      expect(await repo.watchAllDrift().first, isEmpty);
    });

    test('emits sessions sorted by date desc', () async {
      await repo.addLocalDrift(makeSession(routineId: 1, date: DateTime.utc(2026, 4, 14)));
      await repo.addLocalDrift(makeSession(routineId: 2, date: DateTime.utc(2026, 4, 16)));
      await repo.addLocalDrift(makeSession(routineId: 3, date: DateTime.utc(2026, 4, 15)));

      final sessions = await repo.watchAllDrift().first;

      expect(sessions.map((s) => s.routineId).toList(), [2, 3, 1]);
    });

    test('attaches logs to their parent session', () async {
      await seedUnits();
      final session = makeSession();
      await repo.addLocalDrift(session);
      final log1 = makeLog(sessionId: session.id, exerciseId: 1);
      final log2 = makeLog(sessionId: session.id, exerciseId: 2);
      await db.into(db.workoutLogTable).insert(log1.toCompanion());
      await db.into(db.workoutLogTable).insert(log2.toCompanion());

      final sessions = await repo.watchAllDrift().first;

      expect(sessions.single.logs.map((l) => l.exerciseId).toSet(), {1, 2});
    });

    test('hydrates each log with its repetition and weight unit', () async {
      await seedUnits();
      final session = makeSession();
      await repo.addLocalDrift(session);
      await db.into(db.workoutLogTable).insert(makeLog(sessionId: session.id).toCompanion());

      final emitted = await repo.watchAllDrift().first;

      final log = emitted.single.logs.single;
      expect(log.repetitionsUnitObj?.name, 'Repetitions');
      expect(log.weightUnitObj?.name, 'kg');
    });

    test('returns a session without logs when nothing references it', () async {
      await repo.addLocalDrift(makeSession());

      final emitted = await repo.watchAllDrift().first;

      expect(emitted.single.logs, isEmpty);
    });

    test('does not duplicate logs across sessions', () async {
      await seedUnits();
      final s1 = makeSession(routineId: 1);
      final s2 = makeSession(routineId: 2);
      await repo.addLocalDrift(s1);
      await repo.addLocalDrift(s2);
      await db.into(db.workoutLogTable).insert(makeLog(sessionId: s1.id).toCompanion());
      await db.into(db.workoutLogTable).insert(makeLog(sessionId: s2.id).toCompanion());

      final emitted = await repo.watchAllDrift().first;

      expect(emitted, hasLength(2));
      expect(emitted.firstWhere((s) => s.id == s1.id).logs, hasLength(1));
      expect(emitted.firstWhere((s) => s.id == s2.id).logs, hasLength(1));
    });
  });
}
