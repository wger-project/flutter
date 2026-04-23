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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show Response;
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/widgets/core/error.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

/// Convenience builder for an HTML-typed [WgerHttpException].
WgerHttpException _htmlException(String html) {
  return WgerHttpException(
    Response(html, 500, headers: const {'content-type': 'text/html; charset=utf-8'}),
  );
}

void main() {
  group('StreamErrorIndicator', () {
    testWidgets('renders the header and a plain string error', (tester) async {
      await tester.pumpWidget(
        _wrap(const StreamErrorIndicator('Backend exploded')),
      );
      await tester.pumpAndSettle();

      expect(find.text('An Error Occurred!'), findsOneWidget);
      expect(find.text('Backend exploded'), findsOneWidget);
      // Plain-text path → no Preview/Raw tabs.
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets('renders an arbitrary Exception via toString()', (tester) async {
      await tester.pumpWidget(
        _wrap(StreamErrorIndicator(Exception('boom'))),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('boom'), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets('shows the stacktrace below the error when one is provided', (tester) async {
      final stack = StackTrace.fromString(
        '#0  _MyClass.foo (package:wger/foo.dart:42)\n'
        '#1  main (file:///main.dart:10)',
      );

      await tester.pumpWidget(
        _wrap(StreamErrorIndicator('Backend exploded', stacktrace: stack)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Backend exploded'), findsOneWidget);
      expect(find.textContaining('_MyClass.foo'), findsOneWidget);
    });

    testWidgets('JSON-typed WgerHttpException falls into the plain-text path (no tabs)', (
      tester,
    ) async {
      final exception = WgerHttpException.fromMap({'detail': 'token expired'});

      await tester.pumpWidget(_wrap(StreamErrorIndicator(exception)));
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsNothing);
      expect(find.textContaining('token expired'), findsOneWidget);
    });

    testWidgets('HTML-typed WgerHttpException renders the Preview / Raw toggle', (tester) async {
      const html =
          '<html><body><h1>Server Error (500)</h1><p>Something went horribly wrong</p></body></html>';
      final exception = _htmlException(html);

      await tester.pumpWidget(_wrap(StreamErrorIndicator(exception)));
      await tester.pumpAndSettle();

      // Both tab labels are present.
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Raw'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('Raw tab exposes the HTML source verbatim', (tester) async {
      const html = '<html><body><h1>Server Error (500)</h1></body></html>';
      final exception = _htmlException(html);

      await tester.pumpWidget(_wrap(StreamErrorIndicator(exception)));
      await tester.pumpAndSettle();

      // Switch to the "Raw" tab and verify the source text appears.
      await tester.tap(find.text('Raw'));
      await tester.pumpAndSettle();

      expect(find.text(html), findsOneWidget);
    });

    testWidgets('content is height-limited so a giant error cannot blow out the layout', (
      tester,
    ) async {
      // A long error message that would otherwise grow well past 280px.
      final hugeError = List.generate(200, (i) => 'line $i of the failing operation').join('\n');

      await tester.pumpWidget(_wrap(StreamErrorIndicator(hugeError)));
      await tester.pumpAndSettle();

      // The body is wrapped in a ConstrainedBox(maxHeight: 280). Pull it out
      // of the tree and assert the cap is in place — this is what stops the
      // dashboard cards from growing unbounded.
      final constrained = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .firstWhere((c) => c.constraints.maxHeight == 280);
      expect(constrained.constraints.maxHeight, 280);
    });
  });
}
