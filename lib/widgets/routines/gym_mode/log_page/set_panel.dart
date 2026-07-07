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
// Pending / bottom panel
// ---------------------------------------------------------------------------

class _PendingSetPanel extends StatelessWidget {
  final SlotPageEntry? activeSlot;
  final int activeIdx;
  final bool isEditing;
  final SlotPageEntry? pendingSlot;
  final TextEditingController? weightController;
  final TextEditingController? repsController;
  final TextEditingController? rirController;
  final int weightUnitId;
  final Map<String, SlotEntryType> setTypeOverrides;
  final Map<String, int> workingCounts;
  final VoidCallback onLogSet;
  final VoidCallback onCancelEdit;
  final VoidCallback onAddSet;
  final VoidCallback onUnitToggle;
  final VoidCallback? onTypeTap;

  const _PendingSetPanel({
    required this.activeSlot,
    required this.activeIdx,
    required this.isEditing,
    required this.pendingSlot,
    required this.weightController,
    required this.repsController,
    required this.rirController,
    required this.weightUnitId,
    required this.setTypeOverrides,
    required this.workingCounts,
    required this.onLogSet,
    required this.onCancelEdit,
    required this.onAddSet,
    required this.onUnitToggle,
    required this.onTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    final allLogged = pendingSlot == null && !isEditing;
    final showPanel = activeSlot != null || allLogged;
    if (!showPanel) {
      return const SizedBox.shrink();
    }

    final unit = weightUnitId == WEIGHT_UNIT_KG ? 'kg' : 'lbs';

    return Material(
      color: GymPalette.of(context).panel,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
          child: allLogged
              ? _AllLoggedView(onAddSet: onAddSet)
              : _ActiveSetView(
                  activeSlot: activeSlot!,
                  activeIdx: activeIdx,
                  isEditing: isEditing,
                  weightController: weightController!,
                  repsController: repsController!,
                  rirController: rirController,
                  unit: unit,
                  weightUnitId: weightUnitId,
                  setTypeOverrides: setTypeOverrides,
                  workingCounts: workingCounts,
                  onLogSet: onLogSet,
                  onCancelEdit: onCancelEdit,
                  onUnitToggle: onUnitToggle,
                  onTypeTap: onTypeTap,
                ),
        ),
      ),
    );
  }
}

class _AllLoggedView extends StatelessWidget {
  final VoidCallback onAddSet;

  const _AllLoggedView({required this.onAddSet});

  @override
  Widget build(BuildContext context) {
    final p = GymPalette.of(context);
    return OutlinedButton.icon(
      key: const ValueKey('gym-add-set-button'),
      onPressed: onAddSet,
      style: OutlinedButton.styleFrom(
        foregroundColor: p.onPanel,
        side: BorderSide(color: p.divider),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.add, size: 20),
      label: Text(
        AppLocalizations.of(context).gymModeAddAnotherSet,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    );
  }
}

class _ActiveSetView extends StatelessWidget {
  final SlotPageEntry activeSlot;
  final int activeIdx;
  final bool isEditing;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final TextEditingController? rirController;
  final String unit;
  final int weightUnitId;
  final Map<String, SlotEntryType> setTypeOverrides;
  final Map<String, int> workingCounts;
  final VoidCallback onLogSet;
  final VoidCallback onCancelEdit;
  final VoidCallback onUnitToggle;
  final VoidCallback? onTypeTap;

  const _ActiveSetView({
    required this.activeSlot,
    required this.activeIdx,
    required this.isEditing,
    required this.weightController,
    required this.repsController,
    required this.rirController,
    required this.unit,
    required this.weightUnitId,
    required this.setTypeOverrides,
    required this.workingCounts,
    required this.onLogSet,
    required this.onCancelEdit,
    required this.onUnitToggle,
    required this.onTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final p = GymPalette.of(context);
    final type = resolveType(activeSlot, setTypeOverrides);
    final badgeLabel = type == SlotEntryType.normal
        ? '${workingCounts[activeSlot.uuid] ?? activeIdx + 1}'
        : typeBadgeChar(type, i18n);
    final panelLabel = isEditing ? i18n.gymModeEditingSet(activeIdx + 1) : '';
    final logLabel = isEditing ? i18n.gymModeSaveChanges : i18n.gymModeLogSet(activeIdx + 1);

    // The repetitions input is labelled with the set's actual repetition unit
    // (e.g. "Until failure", "Seconds") rather than a hardcoded "REPS". The
    // default repetitions unit keeps the shorter localized "reps" label.
    final repUnit = activeSlot.setConfigData?.repetitionsUnit;
    final repsLabel = (repUnit == null || repUnit.id == REP_UNIT_REPETITIONS_ID)
        ? i18n.reps
        : getServerStringTranslation(repUnit.name, context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top row
        Row(
          children: [
            Semantics(
              button: true,
              label: i18n.gymModeSetType,
              child: GestureDetector(
                onTap: onTypeTap,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: p.accentTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      color: p.onAccentTint,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (panelLabel.isNotEmpty)
              Text(
                panelLabel,
                style: TextStyle(
                  color: p.onPanelMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const Spacer(),
            if (isEditing) ...[
              TextButton(
                onPressed: onCancelEdit,
                style: TextButton.styleFrom(
                  foregroundColor: p.onPanelMuted,
                  backgroundColor: p.onPanel.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                ),
                child: Text(
                  i18n.cancel,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 6),
            ],
            _UnitToggle(
              weightUnitId: weightUnitId,
              onToggle: onUnitToggle,
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Inputs
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _PanelInput(
                fieldKey: const ValueKey('gym-input-weight'),
                label: i18n.gymModeWeightUnit(unit),
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PanelInput(
                fieldKey: const ValueKey('gym-input-reps'),
                label: repsLabel,
                controller: repsController,
                keyboardType: TextInputType.number,
              ),
            ),
            if (rirController != null) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 66,
                child: _PanelInput(
                  fieldKey: const ValueKey('gym-input-rir'),
                  label: i18n.rir,
                  controller: rirController!,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // Log button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const ValueKey('gym-log-set-button'),
            onPressed: onLogSet,
            style: FilledButton.styleFrom(
              backgroundColor: p.accent,
              foregroundColor: p.onAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.check, size: 22),
            label: Text(
              logLabel,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _PanelInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Key? fieldKey;

  const _PanelInput({
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    final p = GymPalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: p.onPanelMuted,
            letterSpacing: 0.05,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.onPanel,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
            filled: true,
            fillColor: p.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: p.divider, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: p.divider, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: p.accent, width: 2),
            ),
            hintText: '—',
            hintStyle: TextStyle(
              color: p.onPanelMuted,
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final int weightUnitId;
  final VoidCallback onToggle;

  const _UnitToggle({required this.weightUnitId, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final onPanel = GymPalette.of(context).onPanel;
    final currentUnit = weightUnitId == WEIGHT_UNIT_KG ? 'kg' : 'lb';
    return Semantics(
      button: true,
      label: i18n.weightUnit,
      value: currentUnit,
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          decoration: BoxDecoration(
            color: onPanel.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _UnitChip(label: 'kg', isActive: weightUnitId == WEIGHT_UNIT_KG),
              _UnitChip(label: 'lb', isActive: weightUnitId == WEIGHT_UNIT_LB),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _UnitChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final p = GymPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? p.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? p.onAccent : p.onPanelMuted,
        ),
      ),
    );
  }
}
