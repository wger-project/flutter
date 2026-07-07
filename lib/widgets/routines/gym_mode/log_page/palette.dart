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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/theme/theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SlotEntryType resolveType(SlotPageEntry sp, Map<String, SlotEntryType> overrides) {
  return overrides[sp.uuid] ?? sp.setConfigData?.type ?? SlotEntryType.normal;
}

String typeBadgeChar(SlotEntryType type, AppLocalizations i18n) {
  return switch (type) {
    SlotEntryType.warmup => i18n.gymModeSetTypeBadgeWarmup,
    SlotEntryType.dropset => i18n.gymModeSetTypeBadgeDropset,
    SlotEntryType.myo => i18n.gymModeSetTypeBadgeMyo,
    SlotEntryType.partial => i18n.gymModeSetTypeBadgePartial,
    SlotEntryType.forced => i18n.gymModeSetTypeBadgeForced,
    SlotEntryType.tut => i18n.gymModeSetTypeBadgeTut,
    SlotEntryType.iso => i18n.gymModeSetTypeBadgeIso,
    SlotEntryType.jump => i18n.gymModeSetTypeBadgeJump,
    _ => i18n.gymModeSetTypeBadgeNormal,
  };
}

/// Scroll behaviour that also allows dragging with a mouse / trackpad, so the
/// horizontal exercise-queue strip can be scrolled on desktop and web (where
/// there is no touch drag and a vertical wheel does not scroll it).
class DragScrollBehavior extends MaterialScrollBehavior {
  const DragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

// ---------------------------------------------------------------------------
// Gym mode palette — derived entirely from the app's Material 3 color scheme so
// gym mode blends with the rest of the app and adapts to light/dark/high-
// contrast themes.
//
// Roles:
//   panel*    large neutral elevated surfaces (header, bottom input panel)
//   accent*   the navy primary accent (Log button, active chip, NOW highlight)
//   accentTint primary-tinted surfaces (target chip, comment, pending row)
//   success*  the "logged / done" affirmative colour (button, progress, rows)
//   neutralTint inactive surfaces (NEXT row, inactive chip)
// ---------------------------------------------------------------------------

class GymPalette {
  final ColorScheme c;
  final WgerColors s;

  const GymPalette(this.c, this.s);

  factory GymPalette.of(BuildContext context) {
    final theme = Theme.of(context);
    return GymPalette(theme.colorScheme, theme.extension<WgerColors>()!);
  }

  // Large surfaces — header & bottom input panel (neutral, slightly elevated).
  Color get panel => c.surfaceContainerHigh;
  Color get onPanel => c.onSurface;
  Color get onPanelMuted => c.onSurfaceVariant;

  // Navy / primary accent.
  Color get accent => c.primary;
  Color get onAccent => c.onPrimary;
  Color get accentTint => c.primaryContainer;
  Color get onAccentTint => c.onPrimaryContainer;

  // Success / done.
  Color get success => s.success;
  Color get onSuccess => s.onSuccess;
  Color get successContainer => s.successContainer;
  Color get onSuccessContainer => s.onSuccessContainer;

  // Neutral inactive surfaces.
  Color get neutralTint => c.surfaceContainerHighest;

  // Content text on the page surface.
  Color get textPrimary => c.onSurface;
  Color get textSecondary => c.onSurfaceVariant;

  Color get divider => c.outlineVariant;
  Color get surface => c.surface;
}
