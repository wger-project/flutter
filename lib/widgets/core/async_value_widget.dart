/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:logging/logging.dart';
import 'package:wger/widgets/core/error.dart';
import 'package:wger/widgets/core/progress_indicator.dart';

/// Renders an [AsyncValue] with sensible defaults for the loading and error
/// states.
///
/// Defaults:
///  * loading → [BoxedProgressIndicator]
///  * error   → [StreamErrorIndicator] (and the error is logged at warning level)
///
/// Override [loading] or [errorBuilder] when you need a more compact rendering
/// (e.g. inside a list tile or a small card).
///
/// Example:
/// ```dart
/// AsyncValueWidget<RoutinesState>(
///   value: ref.watch(routinesRiverpodProvider),
///   data: (state) => RoutineList(state.routines),
/// )
/// ```
class AsyncValueWidget<T> extends StatelessWidget {
  static final _logger = Logger('AsyncValueWidget');

  const AsyncValueWidget({
    required this.value,
    required this.data,
    this.loading,
    this.errorBuilder,
    this.loggerName,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  /// Custom widget for the loading state. Defaults to [BoxedProgressIndicator].
  final Widget? loading;

  /// Custom builder for the error state. Defaults to [StreamErrorIndicator].
  final Widget Function(Object error, StackTrace? stack)? errorBuilder;

  /// Optional context tag included in the warning log line. Helps when an
  /// app-wide grep on the logs needs to point back at the offending screen.
  final String? loggerName;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading ?? const BoxedProgressIndicator(),
      error: (e, st) {
        _logger.warning(loggerName == null ? 'Async error' : 'Async error in $loggerName', e, st);
        return errorBuilder?.call(e, st) ?? StreamErrorIndicator(e.toString(), stacktrace: st);
      },
    );
  }
}
