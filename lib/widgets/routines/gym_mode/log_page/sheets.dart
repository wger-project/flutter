/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

part of '../log_page.dart';

// ---------------------------------------------------------------------------
// History sheet
// ---------------------------------------------------------------------------

List<_HistorySession> _historySessionsFor(GymModeState gymState, int? exerciseId) {
  if (exerciseId == null) {
    return [];
  }
  final sessionStart = gymState.startedAt;
  final logs = gymState.routine
      .filterLogsByExercise(exerciseId)
      .where((l) => l.date.isBefore(sessionStart))
      .toList();
  final groups = <String, List<Log>>{};
  final order = <String>[];
  for (final log in logs) {
    final key = log.sessionId ?? 'day:${log.date.year}-${log.date.month}-${log.date.day}';
    if (groups[key] == null) {
      groups[key] = [log];
      order.add(key);
    } else {
      groups[key]!.add(log);
    }
  }
  return [
    for (final key in order) _HistorySession(date: groups[key]!.first.date, logs: groups[key]!),
  ];
}

/// One past session's worth of logged sets for a single exercise.
class _HistorySession {
  final DateTime date;
  final List<Log> logs;

  const _HistorySession({required this.date, required this.logs});
}

/// Scrollable, session-grouped history for the active exercise. The data is
/// already-synced local data; more sessions are revealed as the user scrolls
/// (client-side pagination — no network).
class _HistorySheet extends StatefulWidget {
  final Exercise? exercise;
  final List<_HistorySession> sessions;
  final String languageCode;

  const _HistorySheet({
    required this.exercise,
    required this.sessions,
    required this.languageCode,
  });

  @override
  State<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<_HistorySheet> {
  /// How many session groups to reveal per "page".
  static const _pageSize = 5;

  late int _visibleCount = _pageSize.clamp(0, widget.sessions.length);

  bool get _hasMore => _visibleCount < widget.sessions.length;

  void _revealMore() {
    if (!_hasMore) {
      return;
    }
    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, widget.sessions.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final exerciseName = widget.exercise?.getTranslation(widget.languageCode).name ?? '';

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scroll) {
        final i18n = AppLocalizations.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i18n.labelWorkoutLogs,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (exerciseName.isNotEmpty)
                    Text(
                      exerciseName,
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: widget.sessions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        i18n.gymModeNothingLoggedYet,
                        style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
                          _revealMore();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: scroll,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        itemCount: _visibleCount + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _visibleCount) {
                            // Trailing "load more" affordance (the list also
                            // auto-reveals as you scroll near the bottom).
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: IconButton(
                                  onPressed: _revealMore,
                                  icon: const Icon(Icons.expand_more),
                                  tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                                ),
                              ),
                            );
                          }
                          return _HistorySessionGroup(session: widget.sessions[index]);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// A single dated session block: a date header followed by its set rows.
class _HistorySessionGroup extends StatelessWidget {
  final _HistorySession session;

  const _HistorySessionGroup({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            DateFormat('EEE, MMM d').format(session.date),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.07,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        for (var i = 0; i < session.logs.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  session.logs[i].repTextNoNl(context),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Type picker sheet
// ---------------------------------------------------------------------------

class _TypePickerSheet extends StatelessWidget {
  final SlotEntryType currentType;
  final ValueChanged<SlotEntryType> onPick;
  final VoidCallback onRemove;

  const _TypePickerSheet({
    required this.currentType,
    required this.onPick,
    required this.onRemove,
  });

  static List<(SlotEntryType, String, String, String)> _typeOptions(AppLocalizations i18n) => [
    (
      SlotEntryType.normal,
      i18n.gymModeSetTypeBadgeNormal,
      i18n.gymModeSetTypeNormal,
      i18n.gymModeSetTypeNormalDesc,
    ),
    (
      SlotEntryType.warmup,
      i18n.gymModeSetTypeBadgeWarmup,
      i18n.slotEntryTypeWarmup,
      i18n.gymModeSetTypeWarmupDesc,
    ),
    (
      SlotEntryType.dropset,
      i18n.gymModeSetTypeBadgeDropset,
      i18n.slotEntryTypeDropset,
      i18n.gymModeSetTypeDropsetDesc,
    ),
    (
      SlotEntryType.myo,
      i18n.gymModeSetTypeBadgeMyo,
      i18n.gymModeSetTypeMyo,
      i18n.gymModeSetTypeMyo_desc,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final i18n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Text(
            i18n.gymModeSetType,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            i18n.gymModeSetTypeHelp,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          for (final (type, tag, name, desc) in _typeOptions(i18n)) ...[
            _TypeOption(
              tag: tag,
              name: name,
              desc: desc,
              type: type,
              isActive: type == currentType,
              onPick: () => onPick(type),
            ),
            const SizedBox(height: 8),
          ],
          Divider(height: 16, color: theme.dividerColor),
          Center(
            child: TextButton.icon(
              onPressed: onRemove,
              style: TextButton.styleFrom(foregroundColor: colors.error),
              icon: const Icon(Icons.delete_outline, size: 20),
              label: Text(
                i18n.gymModeRemoveSet,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String tag;
  final String name;
  final String desc;
  final SlotEntryType type;
  final bool isActive;
  final VoidCallback onPick;

  const _TypeOption({
    required this.tag,
    required this.name,
    required this.desc,
    required this.type,
    required this.isActive,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Color tagBg, tagFg;
    switch (type) {
      case SlotEntryType.warmup:
        tagBg = Colors.orange.withValues(alpha: 0.16);
        tagFg = Colors.orange.shade700;
      case SlotEntryType.dropset:
        tagBg = colors.errorContainer;
        tagFg = colors.onErrorContainer;
      case SlotEntryType.myo:
        tagBg = colors.tertiaryContainer;
        tagFg = colors.onTertiaryContainer;
      default:
        tagBg = colors.primaryContainer;
        tagFg = colors.primary;
    }

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? tagFg : colors.outline.withValues(alpha: 0.4),
            width: isActive ? 2 : 1.5,
          ),
          color: isActive ? tagBg.withValues(alpha: 0.5) : colors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(9)),
              alignment: Alignment.center,
              child: Text(
                tag,
                style: TextStyle(
                  color: tagFg,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
