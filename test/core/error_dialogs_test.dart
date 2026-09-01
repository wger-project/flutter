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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/core/errors.dart';
import 'package:wger/core/keys.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Requests an error dialog from *inside* its own build, the situation a
/// FlutterError.onError handler is in when a widget fails to build.
class _ErrorDuringBuild extends StatelessWidget {
  const _ErrorDuringBuild();

  @override
  Widget build(BuildContext context) {
    showGeneralErrorDialog('boom during build', StackTrace.current, context: context);
    return const SizedBox.shrink();
  }
}

/// Requests the transient-error snackbar from inside a build, where the
/// messenger's setState would otherwise assert.
class _SnackbarDuringBuild extends StatelessWidget {
  const _SnackbarDuringBuild();

  @override
  Widget build(BuildContext context) {
    showTransientErrorSnackbar();
    return const SizedBox.shrink();
  }
}

void main() {
  group('formatApiErrors', () {
    final errors = [
      ApiError(key: 'username', errorMessages: ['too short', 'already taken']),
    ];

    test('leaves the text color unset so it inherits the theme (dark-mode readable)', () {
      // Hardcoding a color (the old Colors.black default) made the API error
      // dialog unreadable on a dark background. A null color inherits instead.
      final texts = formatApiErrors(errors).whereType<Text>().toList();

      expect(texts, isNotEmpty);
      expect(texts.every((t) => t.style?.color == null), isTrue);
    });

    test('applies an explicit color when one is given', () {
      final texts = formatApiErrors(errors, color: Colors.red).whereType<Text>().toList();

      expect(texts, isNotEmpty);
      expect(texts.every((t) => t.style?.color == Colors.red), isTrue);
    });
  });

  group('htmlErrorTitle', () {
    test('extracts and unescapes the title of a bot-wall page', () {
      const html =
          '<!doctype html><html lang="en"><head>'
          '<title>Making sure you&#39;re not a bot!</title>'
          '</head><body></body></html>';

      expect(htmlErrorTitle(html), "Making sure you're not a bot!");
    });

    test('matches case-insensitively and ignores attributes on the title tag', () {
      expect(
        htmlErrorTitle('<HEAD><TITLE data-x="1">Just a moment...</TITLE></HEAD>'),
        'Just a moment...',
      );
    });

    test('returns null when there is no usable title', () {
      expect(htmlErrorTitle('<html><body>no title here</body></html>'), isNull);
      expect(htmlErrorTitle('<html><head><title>   </title></head></html>'), isNull);
      expect(htmlErrorTitle(''), isNull);
    });
  });

  group('showGeneralErrorDialog during build', () {
    Widget app(Widget home) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

    testWidgets('defers the dialog to the next frame instead of asserting', (tester) async {
      // Regression: a mid-build route push asserted, and the secondary
      // exception wedged the one-dialog guard shut until app restart.
      await tester.pumpWidget(app(const _ErrorDuringBuild()));

      // The build itself must not throw...
      expect(tester.takeException(), isNull);

      // ...and the dialog appears on the following frame.
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);

      // Dismissing releases the guard: a second dialog can be shown.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);

      final context = tester.element(find.byType(SizedBox));
      showGeneralErrorDialog('second error', StackTrace.current, context: context);
      // One frame runs the post-frame callback (pushing the route), the next
      // builds the dialog.
      await tester.pump();
      await tester.pump();
      expect(
        find.byType(AlertDialog),
        findsOneWidget,
        reason: 'the guard flag must not stay wedged after the first dialog',
      );
    });

    testWidgets('snackbar requested during build appears without asserting', (tester) async {
      // Same bug class as the dialogs: showSnackBar sets state on the
      // messenger, which asserts during build.
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: _SnackbarDuringBuild()),
        ),
      );

      expect(tester.takeException(), isNull);

      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
