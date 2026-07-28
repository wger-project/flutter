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
// Sets section
// ---------------------------------------------------------------------------

class _SetsSection extends StatelessWidget {
  final List<SlotPageEntry> logSlotPages;

  /// UUID of the set currently being logged/edited (highlighted as active).
  final String? activeUUID;
  final Map<String, int> workingCounts;
  final Map<String, SlotEntryType> setTypeOverrides;
  final Map<String, TextEditingController> weightControllers;
  final Map<String, TextEditingController> repsControllers;
  final int weightUnitId;
  final bool isSuperset;
  final String languageCode;
  final ValueChanged<String> onSelectTap;
  final ValueChanged<SlotPageEntry> onTypeTap;

  const _SetsSection({
    required this.logSlotPages,
    required this.activeUUID,
    required this.workingCounts,
    required this.setTypeOverrides,
    required this.weightControllers,
    required this.repsControllers,
    required this.weightUnitId,
    required this.isSuperset,
    required this.languageCode,
    required this.onSelectTap,
    required this.onTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    final unitLabel = weightUnitId == WEIGHT_UNIT_KG ? 'kg' : 'lbs';
    final p = GymPalette.of(context);

    return ColoredBox(
      color: p.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).sets,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.06,
                  color: p.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              itemCount: logSlotPages.length,
              itemBuilder: (context, index) {
                final sp = logSlotPages[index];
                final isDone = sp.logDone;
                final isActive = sp.uuid == activeUUID;
                final type = resolveType(sp, setTypeOverrides);
                final badgeLabel = type == SlotEntryType.normal
                    ? '${workingCounts[sp.uuid] ?? index + 1}'
                    : typeBadgeChar(type, AppLocalizations.of(context));
                final weightText = weightControllers[sp.uuid]?.text.isNotEmpty == true
                    ? weightControllers[sp.uuid]!.text
                    : '—';
                final repsText = repsControllers[sp.uuid]?.text.isNotEmpty == true
                    ? repsControllers[sp.uuid]!.text
                    : '—';

                // In a superset, label the start of each exercise's sets.
                final prevExerciseId = index > 0
                    ? logSlotPages[index - 1].setConfigData?.exerciseId
                    : null;
                final showExerciseHeader =
                    isSuperset && sp.setConfigData?.exerciseId != prevExerciseId;

                final row = _DesignSetRow(
                  key: ValueKey('gym-set-row-${sp.uuid}'),
                  sp: sp,
                  isDone: isDone,
                  isActive: isActive,
                  type: type,
                  badgeLabel: badgeLabel,
                  weightText: weightText,
                  repsText: repsText,
                  unitLabel: unitLabel,
                  onSelectTap: () => onSelectTap(sp.uuid),
                  onTypeTap: () => onTypeTap(sp),
                );

                if (!showExerciseHeader) {
                  return row;
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 2 : 8, bottom: 4, left: 2),
                      child: Text(
                        sp.setConfigData?.exercise.getTranslation(languageCode).name ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.03,
                          color: p.textSecondary,
                        ),
                      ),
                    ),
                    row,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignSetRow extends StatelessWidget {
  final SlotPageEntry sp;
  final bool isDone;

  /// Whether this is the set currently being logged/edited.
  final bool isActive;
  final SlotEntryType type;
  final String badgeLabel;
  final String weightText;
  final String repsText;
  final String unitLabel;
  final VoidCallback onSelectTap;
  final VoidCallback onTypeTap;

  const _DesignSetRow({
    super.key,
    required this.sp,
    required this.isDone,
    required this.isActive,
    required this.type,
    required this.badgeLabel,
    required this.weightText,
    required this.repsText,
    required this.unitLabel,
    required this.onSelectTap,
    required this.onTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final p = GymPalette.of(context);
    final doneTint = p.successContainer.withValues(alpha: 0.4);

    // Selecting an already-logged set re-opens it for editing.
    final isEditing = isDone && isActive;

    Color rowBg;
    Color leftBorderColor;
    if (isDone) {
      rowBg = isEditing ? p.successContainer : doneTint;
      leftBorderColor = isEditing ? p.success : Colors.transparent;
    } else if (isActive) {
      rowBg = p.accentTint;
      leftBorderColor = p.accent;
    } else {
      rowBg = p.neutralTint;
      leftBorderColor = Colors.transparent;
    }

    Color badgeBg, badgeFg;
    switch (type) {
      case SlotEntryType.warmup:
        badgeBg = Colors.orange.withValues(alpha: 0.16);
        badgeFg = Colors.orange.shade700;
      case SlotEntryType.dropset:
        badgeBg = colors.errorContainer;
        badgeFg = colors.onErrorContainer;
      case SlotEntryType.myo:
        badgeBg = colors.tertiaryContainer;
        badgeFg = colors.onTertiaryContainer;
      default:
        badgeBg = p.accentTint;
        badgeFg = p.onAccentTint;
    }

    final i18n = AppLocalizations.of(context);
    String statusLabel = '';
    Color statusBg = Colors.transparent;
    Color statusFg = Colors.transparent;
    if (isDone) {
      statusLabel = isEditing ? i18n.edit.toUpperCase() : i18n.done.toUpperCase();
      statusBg = isEditing ? p.successContainer : doneTint;
      statusFg = p.onSuccessContainer;
    } else if (isActive) {
      statusLabel = i18n.gymModeStatusNow;
      statusBg = p.accentTint;
      statusFg = p.onAccentTint;
    }

    final textAlpha = isDone ? 0.5 : 1.0;

    return GestureDetector(
      onTap: onSelectTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.fromLTRB(8, 9, 10, 9),
        decoration: BoxDecoration(
          color: rowBg,
          borderRadius: BorderRadius.circular(11),
          border: Border(left: BorderSide(color: leftBorderColor, width: 3)),
        ),
        child: Row(
          children: [
            Semantics(
              button: true,
              label: i18n.gymModeSetType,
              child: GestureDetector(
                onTap: onTypeTap,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      color: badgeFg,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Text(
                    weightText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isDone ? FontWeight.w500 : FontWeight.w600,
                      color: p.textPrimary.withValues(alpha: textAlpha),
                    ),
                  ),
                  Text(
                    ' $unitLabel',
                    style: TextStyle(
                      fontSize: 10,
                      color: p.textSecondary.withValues(alpha: textAlpha),
                    ),
                  ),
                  Text(
                    ' × ',
                    style: TextStyle(
                      fontSize: 12,
                      color: p.textSecondary.withValues(alpha: textAlpha),
                    ),
                  ),
                  Text(
                    repsText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isDone ? FontWeight.w500 : FontWeight.w600,
                      color: p.textPrimary.withValues(alpha: textAlpha),
                    ),
                  ),
                ],
              ),
            ),
            if (statusLabel.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusFg,
                    letterSpacing: 0.06,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
