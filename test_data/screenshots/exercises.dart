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

import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/exercises/models/muscle.dart';

import '../exercises.dart';
import '../screenshots_exercises.dart';

// Real muscles instead of the joke names of the unit-test fixtures; the gym
// mode summary prints them as 'name (nameEn)' in the muscle distribution.
const _chest = Muscle(id: 101, name: 'Pectoralis major', nameEn: 'Chest', isFront: true);
const _delts = Muscle(id: 102, name: 'Deltoideus', nameEn: 'Shoulders', isFront: true);
const _triceps = Muscle(id: 103, name: 'Triceps brachii', nameEn: 'Triceps', isFront: false);
const _biceps = Muscle(id: 104, name: 'Biceps brachii', nameEn: 'Biceps', isFront: true);
const _glutes = Muscle(id: 105, name: 'Gluteus maximus', nameEn: 'Glutes', isFront: false);
const _quads = Muscle(id: 106, name: 'Quadriceps femoris', nameEn: 'Quads', isFront: true);
const _hamstrings = Muscle(id: 107, name: 'Biceps femoris', nameEn: 'Hamstrings', isFront: false);
const _abs = Muscle(id: 108, name: 'Rectus abdominis', nameEn: 'Abs', isFront: true);
const _lowerBack = Muscle(id: 109, name: 'Erector spinae', nameEn: 'Lower back', isFront: false);

/// The test exercises with their full translation sets and realistic muscle
/// assignments attached, so the screenshots show localized exercise names and
/// a plausible muscle distribution.
List<Exercise> getScreenshotExercises() {
  return [
    testBenchPress.copyWith(
      translations: benchPressTranslations,
      muscles: const [_chest],
      musclesSecondary: const [_delts, _triceps],
    ),
    testCrunches.copyWith(
      translations: crunchesTranslations,
      muscles: const [_abs],
      musclesSecondary: const [],
    ),
    testDeadLift.copyWith(
      translations: deadLiftTranslations,
      muscles: const [_glutes, _lowerBack],
      musclesSecondary: const [_hamstrings],
    ),
    testCurls.copyWith(
      translations: curlsTranslations,
      muscles: const [_biceps],
      musclesSecondary: const [],
    ),
    testSquats.copyWith(
      translations: squatsTranslations,
      muscles: const [_quads],
      musclesSecondary: const [_glutes, _abs],
    ),
    testSideRaises.copyWith(
      translations: raisesTranslations,
      muscles: const [_delts],
      musclesSecondary: const [],
    ),
  ];
}
