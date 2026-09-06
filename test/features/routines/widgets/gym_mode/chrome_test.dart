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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/widgets/gym_mode/log_page.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/theme/theme.dart';

import '../../../../../test_data/routines.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GymModeChrome exercise queue', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      container = ProviderContainer.test();
      final notifier = container.read(gymStateProvider.notifier);
      notifier.state = notifier.state.copyWith(
        dayId: 1,
        iteration: 1,
        routine: getTestRoutine(),
      );
      notifier.calculatePages();
    });

    Future<void> pumpChrome(WidgetTester tester, String currentPageUUID) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('en'),
            theme: wgerLightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: GymModeChrome(
                controller: PageController(),
                currentPageUUID: currentPageUUID,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a single-exercise page is labelled with its exercise', (tester) async {
      final page = container
          .read(gymStateProvider)
          .pages
          .firstWhere(
            (p) => p.type == PageType.set,
          );
      await pumpChrome(tester, page.uuid);

      expect(find.text(page.exercises.single.getTranslation('en').name), findsOneWidget);
    });

    testWidgets('a superset page names every exercise it holds', (tester) async {
      // Fold the second exercise's sets into the first page so it becomes a
      // superset — the test routine ships none.
      final state = container.read(gymStateProvider);
      final setPages = state.pages.where((p) => p.type == PageType.set).toList();
      final merged = setPages.first.copyWith(
        slotPages: [...setPages.first.slotPages, ...setPages[1].slotPages],
      );
      final notifier = container.read(gymStateProvider.notifier);
      notifier.state = state.copyWith(
        pages: [
          state.pages.first,
          merged,
          ...state.pages.where((p) => p.type != PageType.set && p != state.pages.first),
        ],
      );

      expect(merged.isSuperset, isTrue);
      final names = merged.exercises.map((e) => e.getTranslation('en').name).toList();
      expect(names, hasLength(2));

      await pumpChrome(tester, merged.uuid);

      // Both names appear, joined — not just the first one as before.
      expect(find.text('${names[0]} + ${names[1]}'), findsOneWidget);
      expect(find.text(names[0]), findsNothing);
    });
  });
}
