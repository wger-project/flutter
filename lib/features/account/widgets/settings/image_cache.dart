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

import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Settings tile that shows the on-disk image cache footprint and lets
/// the user clear it.
class SettingsImageCache extends StatefulWidget {
  const SettingsImageCache({super.key});

  @override
  State<SettingsImageCache> createState() => _SettingsImageCacheState();
}

class _SettingsImageCacheState extends State<SettingsImageCache> {
  _CacheStats? _stats;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final stats = await _readStats();
    if (!mounted) {
      return;
    }
    setState(() => _stats = stats);
  }

  Future<void> _clear() async {
    // Capture context-derived objects before the async gap.
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).settingsCacheDeletedSnackbar;

    await clearDiskCachedImages();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await _refresh();

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final stats = _stats;

    return ListTile(
      title: Text(i18n.settingsImageCacheDescription),
      subtitle: Text(
        stats == null || stats.count == 0 ? '-/-' : '${stats.count} · ${_formatBytes(stats.bytes)}',
      ),
      trailing: IconButton(
        key: const ValueKey('cacheIconImages'),
        icon: const Icon(Icons.delete),
        onPressed: stats == null ? null : _clear,
      ),
    );
  }
}

class _CacheStats {
  final int bytes;
  final int count;
  const _CacheStats({required this.bytes, required this.count});
}

/// Walks the `extended_image` disk cache directory once, summing bytes
/// and file count. Returns zeros when the directory doesn't exist yet
/// (i.e. no image has been loaded since install / cache clear).
Future<_CacheStats> _readStats() async {
  final dir = Directory(p.join((await getTemporaryDirectory()).path, cacheImageFolderName));
  if (!dir.existsSync()) {
    return const _CacheStats(bytes: 0, count: 0);
  }

  int bytes = 0;
  int count = 0;
  await for (final entity in dir.list()) {
    if (entity is File) {
      bytes += entity.statSync().size;
      count++;
    }
  }
  return _CacheStats(bytes: bytes, count: count);
}

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
}
