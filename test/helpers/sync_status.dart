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

import 'package:powersync/powersync.dart' show SyncStatus;

/// Builds a [SyncStatus] for tests. Since powersync 2.3.2 the constructor is
/// @internal and requires every parameter, so fabricate statuses through this
/// helper instead.
SyncStatus buildSyncStatus({
  bool connected = false,
  bool connecting = false,
  bool downloading = false,
  bool uploading = false,
  DateTime? lastSyncedAt,
  Object? downloadError,
  Object? uploadError,
}) {
  // ignore: invalid_use_of_internal_member
  return SyncStatus(
    connected: connected,
    connecting: connecting,
    downloading: downloading,
    uploading: uploading,
    lastSyncedAt: lastSyncedAt,
    downloadProgress: null,
    downloadError: downloadError,
    uploadError: uploadError,
    priorityStatusEntries: const [],
    streamSubscriptions: null,
  );
}
