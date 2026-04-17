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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/exercises/autocompleter.dart';
import 'package:wger/widgets/routines/forms/slot_entry.dart';
import 'package:wger/widgets/routines/slot.dart';

typedef SlotGroupInfo = ({int groupSize, int indexInGroup, String? exerciseName});

/// Groups consecutive single-entry slots with the same exerciseId.
/// Returns a map from slot index to group metadata.
Map<int, SlotGroupInfo> computeSlotGroups(List<Slot> slots, String languageCode) {
  final result = <int, SlotGroupInfo>{};
  int i = 0;
  while (i < slots.length) {
    final slot = slots[i];
    if (slot.entries.length != 1) {
      result[i] = (groupSize: 1, indexInGroup: 0, exerciseName: null);
      i++;
      continue;
    }
    final exerciseId = slot.entries[0].exerciseId;
    int j = i + 1;
    while (j < slots.length &&
        slots[j].entries.length == 1 &&
        slots[j].entries[0].exerciseId == exerciseId) {
      j++;
    }
    final groupSize = j - i;
    final exerciseName = groupSize > 1
        ? slot.entries[0].exerciseObj.getTranslation(languageCode).name
        : null;
    for (int k = i; k < j; k++) {
      result[k] = (groupSize: groupSize, indexInGroup: k - i, exerciseName: exerciseName);
    }
    i = j;
  }
  return result;
}

class SlotDetailWidget extends ConsumerStatefulWidget {
  final Slot slot;
  final bool simpleMode;
  final int routineId;

  const SlotDetailWidget(this.slot, this.routineId, {this.simpleMode = true, super.key});

  @override
  _SlotDetailWidgetState createState() => _SlotDetailWidgetState();
}

class _SlotDetailWidgetState extends ConsumerState<SlotDetailWidget> {
  bool _showExerciseSearchBox = false;
  Widget errorMessage = const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final provider = ref.read(routinesRiverpodProvider.notifier);

    return Column(
      children: [
        errorMessage,
        ...widget.slot.entries.map(
          (entry) => entry.hasProgressionRules
              ? ProgressionRulesInfoBox(entry.exerciseObj)
              : SlotEntryForm(entry, widget.routineId, simpleMode: widget.simpleMode),
        ),
        const SizedBox(height: 10),
        if (_showExerciseSearchBox || widget.slot.entries.isEmpty)
          ExerciseAutocompleter(
            onExerciseSelected: (exercise) async {
              setState(() => _showExerciseSearchBox = false);

              final SlotEntry entry = SlotEntry.withData(
                slotId: widget.slot.id!,
                order: widget.slot.entries.length + 1,
                exercise: exercise,
              );

              try {
                await provider.addSlotEntry(entry, widget.routineId);
                if (context.mounted) {
                  setState(() => errorMessage = const SizedBox.shrink());
                }
              } on WgerHttpException catch (error) {
                if (context.mounted) {
                  setState(() {
                    errorMessage = FormHttpErrorsWidget(error);
                  });
                }
              }
            },
          ),
        if (widget.slot.entries.isNotEmpty)
          FilledButton(
            onPressed: () {
              setState(() => _showExerciseSearchBox = !_showExerciseSearchBox);
            },
            child: Text(i18n.addSuperset),
          ),
        const SizedBox(height: 5),
      ],
    );
  }
}

class ReorderableSlotList extends ConsumerStatefulWidget {
  final List<Slot> slots;
  final Day day;

  const ReorderableSlotList(this.slots, this.day);

  @override
  _SlotFormWidgetStateNg createState() => _SlotFormWidgetStateNg();
}

class _SlotFormWidgetStateNg extends ConsumerState<ReorderableSlotList> {
  int? selectedSlotId;
  bool simpleMode = true;
  bool isAddingSlot = false;
  int? isDeletingSlot;
  Widget errorMessage = const SizedBox.shrink();

  Future<void> _handleAddSet(Slot slot, int slotIndex) async {
    final provider = Provider.of<RoutinesProvider>(context, listen: false);
    if (slot.entries.isEmpty) {
      return;
    }

    setState(() => isAddingSlot = true);
    try {
      final insertOrder = slotIndex + 2;

      // Shift orders of subsequent slots
      final slotsToUpdate = <Slot>[];
      for (int k = slotIndex + 1; k < widget.slots.length; k++) {
        widget.slots[k].order = insertOrder + (k - slotIndex);
        slotsToUpdate.add(widget.slots[k]);
      }
      if (slotsToUpdate.isNotEmpty) {
        await provider.editSlots(slotsToUpdate, widget.day.routineId);
      }

      // Create new slot after source
      final newSlot = await provider.addSlot(
        Slot.withData(day: widget.day.id, order: insertOrder),
        widget.day.routineId,
      );

      // Create entry with same exercise
      final sourceEntry = slot.entries[0];
      await provider.addSlotEntry(
        SlotEntry.withData(
          slotId: newSlot.id!,
          exercise: sourceEntry.exerciseObj,
          order: 1,
          weightUnitId: sourceEntry.weightUnitId,
        ),
        widget.day.routineId,
      );

      if (mounted) {
        setState(() {
          isAddingSlot = false;
          errorMessage = const SizedBox.shrink();
        });
      }
    } on WgerHttpException catch (error) {
      if (mounted) {
        setState(() {
          isAddingSlot = false;
          errorMessage = FormHttpErrorsWidget(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final provider = ref.read(routinesRiverpodProvider.notifier);
    final languageCode = Localizations.localeOf(context).languageCode;
    final groupInfo = computeSlotGroups(widget.slots, languageCode);

    return Column(
      children: [
        errorMessage,
        if (!widget.day.isRest)
          SwitchListTile(
            value: simpleMode,
            title: Text(i18n.simpleMode),
            subtitle: Text(i18n.simpleModeHelp),
            contentPadding: const EdgeInsets.all(4),
            onChanged: (value) {
              setState(() => simpleMode = value);
            },
          ),
        ReorderableListView.builder(
          buildDefaultDragHandles: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.slots.length,
          itemBuilder: (context, index) {
            final slot = widget.slots[index];
            final isCurrentSlotSelected = slot.id == selectedSlotId;
            final info = groupInfo[index]!;
            final isGrouped = info.groupSize > 1;

            // Title: "Set N" for grouped, "Superset N" or "Exercise N" otherwise
            final String titleText;
            if (isGrouped) {
              titleText = i18n.setNr((info.indexInGroup + 1).toString());
            } else if (slot.isSuperset) {
              titleText = i18n.supersetNr((index + 1).toString());
            } else {
              titleText = i18n.exerciseNr((index + 1).toString());
            }

            // Subtitle: exercise name(s), or group header for first in group
            Widget? subtitleWidget;
            if (slot.entries.isEmpty) {
              subtitleWidget = Text(i18n.setHasNoExercises);
            } else if (isGrouped && info.indexInGroup == 0 && info.exerciseName != null) {
              subtitleWidget = Text(info.exerciseName!);
            } else if (!isGrouped) {
              subtitleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: slot.entries
                    .map((e) => Text(e.exerciseObj.getTranslation(languageCode).name))
                    .toList(),
              );
            }

            // Group visual: flush cards with rounded outer corners only
            const double cardRadius = 12;
            final bool isFirst = info.indexInGroup == 0;
            final bool isLast = info.indexInGroup == info.groupSize - 1;
            final borderRadius = isGrouped
                ? BorderRadius.only(
                    topLeft: isFirst ? const Radius.circular(cardRadius) : Radius.zero,
                    topRight: isFirst ? const Radius.circular(cardRadius) : Radius.zero,
                    bottomLeft: isLast ? const Radius.circular(cardRadius) : Radius.zero,
                    bottomRight: isLast ? const Radius.circular(cardRadius) : Radius.zero,
                  )
                : BorderRadius.circular(cardRadius);

            // Remove vertical gap between consecutive grouped cards
            final cardMargin = isGrouped
                ? EdgeInsets.only(
                    left: 4,
                    right: 4,
                    top: isFirst ? 4 : 0,
                    bottom: isLast ? 4 : 0,
                  )
                : const EdgeInsets.all(4);

            final cardChild = Column(
              children: [
                ListTile(
                  title: Text(titleText),
                  tileColor: isCurrentSlotSelected ? Theme.of(context).highlightColor : null,
                  leading: selectedSlotId == null
                      ? ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        )
                      : const Icon(Icons.block),
                  subtitle: subtitleWidget,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (slot.entries.length == 1 && isLast)
                        IconButton(
                          tooltip: i18n.addSet,
                          icon: isAddingSlot
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.content_copy),
                          onPressed: isAddingSlot ? null : () => _handleAddSet(slot, index),
                        ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (selectedSlotId == slot.id) {
                              selectedSlotId = null;
                            } else {
                              selectedSlotId = slot.id;
                            }
                          });
                        },
                        icon: isCurrentSlotSelected
                            ? const Icon(Icons.edit_off)
                            : const Icon(Icons.edit),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: isDeletingSlot == index
                            ? null
                            : () async {
                                selectedSlotId = null;
                                setState(() => isDeletingSlot = index);
                                await provider.deleteSlot(slot.id!, widget.day.routineId);
                                if (mounted) {
                                  setState(() => isDeletingSlot = null);
                                }
                              },
                      ),
                    ],
                  ),
                ),
                if (isCurrentSlotSelected)
                  SlotDetailWidget(slot, widget.day.routineId, simpleMode: simpleMode),
              ],
            );

            return Card(
              key: ValueKey(slot.id),
              margin: cardMargin,
              color: slot.entries.isEmpty ? Theme.of(context).colorScheme.inversePrimary : null,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              clipBehavior: Clip.antiAlias,
              child: cardChild,
            );
          },
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              // Update the order of slots in your data source
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = widget.slots.removeAt(oldIndex);
              widget.slots.insert(newIndex, item);

              for (int i = 0; i < widget.slots.length; i++) {
                widget.slots[i].order = i + 1;
              }

              try {
                provider.editSlots(widget.slots, widget.day.routineId);
                setState(() {
                  errorMessage = const SizedBox.shrink();
                });
              } on WgerHttpException catch (error) {
                if (context.mounted) {
                  setState(() {
                    errorMessage = FormHttpErrorsWidget(error);
                  });
                }
              }
            });
          },
        ),
        if (!widget.day.isRest)
          Card(
            child: ListTile(
              leading: isAddingSlot ? const FormProgressIndicator() : const Icon(Icons.add),
              title: Text(
                i18n.addExercise,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: isAddingSlot
                  ? null
                  : () async {
                      setState(() => isAddingSlot = true);

                      final newSlot = await provider.addSlot(
                        Slot.withData(
                          day: widget.day.id,
                          order: widget.slots.length + 1,
                        ),
                        widget.day.routineId,
                      );
                      if (mounted) {
                        setState(() => isAddingSlot = false);
                        setState(() => selectedSlotId = newSlot.id);
                      }
                    },
            ),
          ),
      ],
    );
  }
}
