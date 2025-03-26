/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/routine_logs_screen.dart';
import 'package:wger/screens/routine_screen.dart';

import '../../test_data/routines.dart';
import '../utils.dart';
import 'routine_logs_screen_test.mocks.dart';

@GenerateMocks([RoutinesProvider])
void main() {
  late Routine routine;
  final mockRoutinesProvider = MockRoutinesProvider();

  setUp(() {
    routine = getTestRoutine();
    routine.logs[0].date = DateTime.now();
  });

  Widget renderWidget({locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ChangeNotifierProvider<RoutinesProvider>(
      create: (context) => mockRoutinesProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: RouteSettings(arguments: routine),
              builder: (_) => const WorkoutLogsScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
        routes: {
          RoutineScreen.routeName: (ctx) => const WorkoutLogsScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the routine logs screen',
      (WidgetTester tester) async {
    await loadAppFonts();
    await tester.pumpWidget(renderWidget());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    await expectLater(find.byType(WorkoutLogsScreen),
        matchesGoldenFile('goldens/routine_logs_screen_detail.png'));

    // expect(find.text('3 day workout'), findsOneWidget);

    // expect(find.text('first day'), findsOneWidget);
    // expect(find.text('chest, shoulders'), findsOneWidget);

    // The second day is repeated
    // expect(find.text('second day'), findsNWidgets(2));
    // expect(find.text('legs'), findsNWidgets(2));

    // expect(find.byType(Card), findsNWidgets(3));
  });
}
