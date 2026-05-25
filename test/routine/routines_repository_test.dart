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
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/workouts/base_config.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/routines_repository.dart';

import '../helpers/in_memory_drift.dart';
import 'routines_repository_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late DriftPowersyncDatabase db;
  late MockWgerBaseProvider mockBase;
  late RoutinesRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    mockBase = MockWgerBaseProvider();
    repo = RoutinesRepository(mockBase, db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedRoutine({
    required int id,
    String name = 'Test',
    DateTime? start,
    DateTime? created,
  }) async {
    await db
        .into(db.routineTable)
        .insert(
          RoutineTableCompanion.insert(
            id: id,
            name: name,
            description: '',
            created: created ?? DateTime.utc(2024),
            start: start ?? DateTime.utc(2024, 1, 1),
            end: DateTime.utc(2025),
            isTemplate: false,
            isPublic: false,
            fitInWeek: false,
          ),
        );
  }

  // ---------------------------------------------------------------------------

  group('Routines, Drift', () {
    test('watchAllDrift emits an empty list when no routines exist', () async {
      expect(await repo.watchAllDrift().first, isEmpty);
    });

    test('watchAllDrift sorts by start desc, then created desc', () async {
      // Two routines share a start date; the newer `created` should win.
      await seedRoutine(
        id: 1,
        start: DateTime.utc(2024, 1, 1),
        created: DateTime.utc(2024, 1, 1),
      );
      await seedRoutine(
        id: 2,
        start: DateTime.utc(2024, 6, 1),
        created: DateTime.utc(2024, 1, 1),
      );
      await seedRoutine(
        id: 3,
        start: DateTime.utc(2024, 1, 1),
        created: DateTime.utc(2024, 6, 1),
      );

      final emitted = await repo.watchAllDrift().first;

      expect(emitted.map((r) => r.id).toList(), [2, 3, 1]);
    });

    test('editLocalDrift overwrites the routine with matching id', () async {
      await seedRoutine(id: 1, name: 'original');
      final routine = (await repo.watchAllDrift().first).single;
      routine.name = 'updated';

      await repo.editLocalDrift(routine);

      final emitted = await repo.watchAllDrift().first;
      expect(emitted.single.name, 'updated');
    });

    test('editLocalDrift throws StateError when id is null', () async {
      final routine = Routine(name: 'no id', description: '');

      expect(() => repo.editLocalDrift(routine), throwsStateError);
    });

    test('deleteLocalDrift removes the routine with matching id', () async {
      await seedRoutine(id: 1);
      await seedRoutine(id: 2);

      await repo.deleteLocalDrift(1);

      final emitted = await repo.watchAllDrift().first;
      expect(emitted.map((r) => r.id), [2]);
    });

    test('watchWeightUnitsDrift emits seeded units', () async {
      await db
          .into(db.routineWeightUnitTable)
          .insert(RoutineWeightUnitTableCompanion.insert(id: 1, name: 'kg'));

      final units = await repo.watchWeightUnitsDrift().first;

      expect(units.single.name, 'kg');
    });

    test('watchRepetitionUnitsDrift emits seeded units', () async {
      await db
          .into(db.routineRepetitionUnitTable)
          .insert(RoutineRepetitionUnitTableCompanion.insert(id: 1, name: 'Repetitions'));

      final units = await repo.watchRepetitionUnitsDrift().first;

      expect(units.single.name, 'Repetitions');
    });
  });

  // ---------------------------------------------------------------------------
  // The two REST methods below (addRoutineServer and fetchAndSetRoutineFullServer)
  // already have coverage in routines_provider_repository_test.dart. Everything
  // else lives here.
  // ---------------------------------------------------------------------------

  group('Days, REST', () {
    test('addDayServer POSTs to /day/ and returns the created Day', () async {
      final dayUri = Uri.https('localhost', 'api/v2/day/');
      when(mockBase.makeUrl('day')).thenReturn(dayUri);
      when(mockBase.post(any, dayUri)).thenAnswer(
        (_) async => <String, dynamic>{
          'id': 7,
          'routine': 100,
          'name': 'Day 1',
          'description': '',
          'is_rest': false,
          'need_logs_to_advance': false,
          'type': 'custom',
          'order': 1,
          'config': null,
        },
      );

      final created = await repo.addDayServer(
        Day(routineId: 100, name: 'Day 1'),
      );

      expect(created.id, 7);
      expect(created.routineId, 100);
    });

    test('editDayServer PATCHes /day/<id>/', () async {
      final uri = Uri.https('localhost', 'api/v2/day/5/');
      when(mockBase.makeUrl('day', id: 5)).thenReturn(uri);
      when(mockBase.patch(any, uri)).thenAnswer((_) async => {});

      await repo.editDayServer(Day(id: 5, routineId: 100, name: 'updated'));

      verify(mockBase.patch(any, uri)).called(1);
    });

    test('deleteDayServer sends DELETE for /day/<id>/', () async {
      when(mockBase.deleteRequest('day', 5)).thenAnswer((_) async => http.Response('', 204));

      await repo.deleteDayServer(5);

      verify(mockBase.deleteRequest('day', 5)).called(1);
    });
  });

  group('Slots, REST', () {
    test('addSlotServer POSTs to /slot/ and returns the created Slot', () async {
      final uri = Uri.https('localhost', 'api/v2/slot/');
      when(mockBase.makeUrl('slot')).thenReturn(uri);
      when(mockBase.post(any, uri)).thenAnswer(
        (_) async => {'id': 7, 'day': 1, 'order': 1, 'comment': '', 'config': null},
      );

      final created = await repo.addSlotServer(Slot.withData(day: 1, order: 1));

      expect(created.id, 7);
    });

    test('editSlotServer PATCHes /slot/<id>/', () async {
      final uri = Uri.https('localhost', 'api/v2/slot/5/');
      when(mockBase.makeUrl('slot', id: 5)).thenReturn(uri);
      when(mockBase.patch(any, uri)).thenAnswer((_) async => {});

      await repo.editSlotServer(Slot.withData(id: 5, day: 1, order: 1));

      verify(mockBase.patch(any, uri)).called(1);
    });

    test('deleteSlotServer sends DELETE for /slot/<id>/', () async {
      when(mockBase.deleteRequest('slot', 5)).thenAnswer((_) async => http.Response('', 204));

      await repo.deleteSlotServer(5);

      verify(mockBase.deleteRequest('slot', 5)).called(1);
    });
  });

  group('Slot entries, REST', () {
    SlotEntry makeEntry({int? id, int slotId = 1}) {
      // `config` is `late Object?` and required for toJson to work.
      return SlotEntry(
        id: id,
        slotId: slotId,
        type: SlotEntryType.normal,
        order: 1,
        exerciseId: 1,
        repetitionUnitId: 1,
        repetitionRounding: 1,
        weightUnitId: 1,
        weightRounding: 1.25,
        comment: '',
      )..config = null;
    }

    test('addSlotEntryServer POSTs to /slot-entry/ and returns the created entry', () async {
      final uri = Uri.https('localhost', 'api/v2/slot-entry/');
      when(mockBase.makeUrl('slot-entry')).thenReturn(uri);
      when(mockBase.post(any, uri)).thenAnswer(
        (_) async => <String, dynamic>{
          'id': 11,
          'slot': 1,
          'type': 'normal',
          'order': 1,
          'exercise': 1,
          'repetition_unit': 1,
          'repetition_rounding': '1',
          'weight_unit': 1,
          'weight_rounding': '1.25',
          'comment': '',
          'config': null,
        },
      );

      final created = await repo.addSlotEntryServer(makeEntry());

      expect(created.id, 11);
    });

    test('editSlotEntryServer PATCHes /slot-entry/<id>/', () async {
      final uri = Uri.https('localhost', 'api/v2/slot-entry/5/');
      when(mockBase.makeUrl('slot-entry', id: 5)).thenReturn(uri);
      when(mockBase.patch(any, uri)).thenAnswer((_) async => {});

      await repo.editSlotEntryServer(makeEntry(id: 5));

      verify(mockBase.patch(any, uri)).called(1);
    });

    test('deleteSlotEntryServer sends DELETE for /slot-entry/<id>/', () async {
      when(mockBase.deleteRequest('slot-entry', 5)).thenAnswer((_) async => http.Response('', 204));

      await repo.deleteSlotEntryServer(5);

      verify(mockBase.deleteRequest('slot-entry', 5)).called(1);
    });
  });

  group('Configs, REST', () {
    Map<String, dynamic> configResponse(int id, num value) => {
      'id': id,
      'iteration': 1,
      'slot_entry': 1,
      'value': value,
      'operation': 'r',
      'step': 'abs',
      'requirements': null,
      'repeat': false,
    };

    // Walks the full type → URL-segment table. Each ConfigType triggers a
    // different branch of the private _getConfigUrl, so addConfigServer
    // doubles as a coverage harness for that switch.
    const expectedPaths = <ConfigType, String>{
      ConfigType.sets: 'sets-config',
      ConfigType.maxSets: 'max-sets-config',
      ConfigType.weight: 'weight-config',
      ConfigType.maxWeight: 'max-weight-config',
      ConfigType.repetitions: 'repetitions-config',
      ConfigType.maxRepetitions: 'max-repetitions-config',
      ConfigType.rir: 'rir-config',
      ConfigType.maxRir: 'max-rir-config',
      ConfigType.rest: 'rest-config',
      ConfigType.maxRest: 'max-rest-config',
    };

    for (final entry in expectedPaths.entries) {
      test('addConfigServer routes ${entry.key} to /${entry.value}/', () async {
        final uri = Uri.https('localhost', 'api/v2/${entry.value}/');
        when(mockBase.makeUrl(entry.value)).thenReturn(uri);
        when(mockBase.post(any, uri)).thenAnswer((_) async => configResponse(1, 5));

        await repo.addConfigServer(BaseConfig.firstIteration(5, 1), entry.key);

        verify(mockBase.makeUrl(entry.value)).called(1);
      });
    }

    test('editConfigServer PATCHes /<config-path>/<id>/', () async {
      final uri = Uri.https('localhost', 'api/v2/sets-config/3/');
      when(mockBase.makeUrl('sets-config', id: 3)).thenReturn(uri);
      when(mockBase.patch(any, uri)).thenAnswer((_) async => configResponse(3, 4));

      final config = BaseConfig.firstIteration(4, 1);
      config.id = 3;
      final result = await repo.editConfigServer(config, ConfigType.sets);

      expect(result.id, 3);
      verify(mockBase.patch(any, uri)).called(1);
    });

    test('deleteConfigServer sends DELETE for /<config-path>/<id>/', () async {
      when(
        mockBase.deleteRequest('sets-config', 3),
      ).thenAnswer((_) async => http.Response('', 204));

      await repo.deleteConfigServer(3, ConfigType.sets);

      verify(mockBase.deleteRequest('sets-config', 3)).called(1);
    });

    group('handleConfigServer', () {
      SlotEntry entryWithSetsConfig(BaseConfig? existing) {
        return SlotEntry(
          id: 1,
          slotId: 1,
          type: SlotEntryType.normal,
          order: 1,
          exerciseId: 1,
          repetitionUnitId: 1,
          repetitionRounding: 1,
          weightUnitId: 1,
          weightRounding: 1.25,
          comment: '',
          nrOfSetsConfigs: existing == null ? [] : [existing],
        )..config = null;
      }

      test('value=null + existing config → DELETE', () async {
        final existing = BaseConfig.firstIteration(3, 1);
        existing.id = 9;
        final entry = entryWithSetsConfig(existing);
        when(
          mockBase.deleteRequest('sets-config', 9),
        ).thenAnswer((_) async => http.Response('', 204));

        await repo.handleConfigServer(entry, null, ConfigType.sets);

        verify(mockBase.deleteRequest('sets-config', 9)).called(1);
      });

      test('value + existing config → PATCH', () async {
        final existing = BaseConfig.firstIteration(3, 1);
        existing.id = 9;
        final entry = entryWithSetsConfig(existing);
        final uri = Uri.https('localhost', 'api/v2/sets-config/9/');
        when(mockBase.makeUrl('sets-config', id: 9)).thenReturn(uri);
        when(mockBase.patch(any, uri)).thenAnswer((_) async => configResponse(9, 5));

        await repo.handleConfigServer(entry, 5, ConfigType.sets);

        verify(mockBase.patch(any, uri)).called(1);
      });

      test('value + no existing config → POST (add new)', () async {
        final entry = entryWithSetsConfig(null);
        final uri = Uri.https('localhost', 'api/v2/sets-config/');
        when(mockBase.makeUrl('sets-config')).thenReturn(uri);
        when(mockBase.post(any, uri)).thenAnswer((_) async => configResponse(1, 5));

        await repo.handleConfigServer(entry, 5, ConfigType.sets);

        verify(mockBase.post(any, uri)).called(1);
      });

      test('value=null + no existing config → no-op', () async {
        final entry = entryWithSetsConfig(null);

        await repo.handleConfigServer(entry, null, ConfigType.sets);

        verifyZeroInteractions(mockBase);
      });
    });
  });
}
