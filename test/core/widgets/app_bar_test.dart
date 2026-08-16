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
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/core/network/wger_base.dart';
import 'package:wger/core/widgets/app_bar.dart';
import 'package:wger/core/widgets/sync_status_dialog.dart';
import 'package:wger/database/powersync/powersync.dart' show pendingUploadCountProvider, syncStatus;
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../helpers/sync_status.dart';

void main() {
  testWidgets('sync icon snapshots its providers at tap time and opens the dialog', (tester) async {
    // Companion to a production crash: reading a dirty provider from the
    // route builder forced a mid-build refresh. The exact race needs a
    // dependency flip in the same frame and is not deterministically
    // reproducible here; this pins the tap-time wiring of the fixed path.
    final container = ProviderContainer.test(
      overrides: [
        networkStatusProvider.overrideWithValue(true),
        pendingUploadCountProvider.overrideWith((ref) => Stream.value(0)),
        syncStatus.overrideWithValue(buildSyncStatus(connected: true)),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(appBar: MainAppBar('title')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Dirty the provider the dialog reads, without pumping a frame, so the
    // flush happens on the tap itself.
    container.invalidate(wgerBaseProvider);

    final syncIcon = find.descendant(
      of: find.byType(MainAppBar),
      matching: find.byType(IconButton),
    );
    await tester.tap(syncIcon.at(1));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SyncStatusDialog), findsOneWidget);
  });
}
