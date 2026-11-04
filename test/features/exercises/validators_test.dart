/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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
import 'package:material_ui/material_ui.dart';
import 'package:wger/features/exercises/validators.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/l10n/localizations_delegates.dart';

const _fifteenWords =
    'Stand upright and hold the dumbbells at your sides, then curl both weights up slowly.';
const _longEnough =
    '$_fifteenWords Lower them again under control and keep your elbows close to your body.';

void main() {
  late BuildContext context;
  late AppLocalizations i18n;

  Future<void> pumpContext(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox();
          },
        ),
      ),
    );
    i18n = AppLocalizations.of(context);
  }

  group('validateExerciseDescription', () {
    testWidgets('accepts a description with enough characters and words', (tester) async {
      await pumpContext(tester);
      expect(validateExerciseDescription(_longEnough, context), isNull);
    });

    testWidgets('rejects a description under 120 characters', (tester) async {
      await pumpContext(tester);
      expect(_fifteenWords.length, lessThan(MIN_CHARS_DESCRIPTION));
      expect(
        validateExerciseDescription(_fifteenWords, context),
        i18n.enterMinCharacters(MIN_CHARS_DESCRIPTION),
      );
    });

    testWidgets('rejects a long description with too few words', (tester) async {
      await pumpContext(tester);
      final fewWords = 'Supercalifragilisticexpialidocious ' * 5;
      expect(
        validateExerciseDescription(fewWords, context),
        i18n.enterMinWords(MIN_WORDS_DESCRIPTION),
      );
    });

    testWidgets("markdown list markers don't count as words", (tester) async {
      await pumpContext(tester);
      final padded = '${'- 1. * - ' * 14}Hold the bar and pull yourself up.';
      expect(padded.length, greaterThanOrEqualTo(MIN_CHARS_DESCRIPTION));
      expect(
        validateExerciseDescription(padded, context),
        i18n.enterMinWords(MIN_WORDS_DESCRIPTION),
      );
    });
  });
}
