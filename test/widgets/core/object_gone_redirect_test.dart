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
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/widgets/core/object_gone_redirect.dart';

void main() {
  /// Pushes a detail route whose body flips to [objectGoneRedirect] once [gone]
  /// is true. Returns the navigator key for pushing further routes.
  Future<GlobalKey<NavigatorState>> pumpDetail(
    WidgetTester tester,
    ValueNotifier<bool> gone,
  ) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        home: const Scaffold(body: Text('list')),
      ),
    );
    key.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => ValueListenableBuilder<bool>(
          valueListenable: gone,
          builder: (context, isGone, _) =>
              isGone ? objectGoneRedirect(context) : const Scaffold(body: Text('detail')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key;
  }

  testWidgets('pops the detail screen when it is the current route', (tester) async {
    final gone = ValueNotifier(false);
    addTearDown(gone.dispose);
    await pumpDetail(tester, gone);
    expect(find.text('detail'), findsOneWidget);

    gone.value = true;
    await tester.pumpAndSettle();

    expect(find.text('detail'), findsNothing);
    expect(find.text('list'), findsOneWidget);
  });

  testWidgets('does not tear down a child route opened on top of the detail screen', (
    tester,
  ) async {
    final gone = ValueNotifier(false);
    addTearDown(gone.dispose);
    final key = await pumpDetail(tester, gone);

    // Open a child route (edit form, dialog, …) on top of the detail screen.
    key.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('child'))),
    );
    await tester.pumpAndSettle();
    expect(find.text('child'), findsOneWidget);

    // The object is deleted while the child is open: the detail rebuilds
    // underneath. The child must stay, since the detail is not the current route.
    gone.value = true;
    await tester.pumpAndSettle();

    expect(find.text('child'), findsOneWidget);
  });

  testWidgets('pops the whole chain of screens about the same object', (tester) async {
    final gone = ValueNotifier(false);
    addTearDown(gone.dispose);
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        home: const Scaffold(body: Text('list')),
      ),
    );

    // Two screens about object id 5 (e.g. routine detail, then its logs view),
    // both pushed with the same id argument and both watching [gone].
    Widget goneOr(String label) => ValueListenableBuilder<bool>(
      valueListenable: gone,
      builder: (context, isGone, _) =>
          isGone ? objectGoneRedirect(context) : Scaffold(body: Text(label)),
    );
    key.currentState!.push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(arguments: 5),
        builder: (_) => goneOr('detail'),
      ),
    );
    await tester.pumpAndSettle();
    key.currentState!.push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(arguments: 5),
        builder: (_) => goneOr('logs'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('logs'), findsOneWidget);

    // Object deleted: both same-id screens drop, landing on the list, not on a
    // blank intermediate detail screen.
    gone.value = true;
    await tester.pumpAndSettle();

    expect(find.text('logs'), findsNothing);
    expect(find.text('detail'), findsNothing);
    expect(find.text('list'), findsOneWidget);
  });
}
