/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/exceptions/http_exception.dart';
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
    final provider = ref.read(routinesChangeProvider);

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

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final provider = ref.read(routinesChangeProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

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

            return Card(
              color: slot.entries.isEmpty ? Theme.of(context).colorScheme.inversePrimary : null,
              key: ValueKey(slot.id),
              child: Column(
                children: [
                  ListTile(
                    title: slot.isSuperset
                        ? Text(i18n.supersetNr((index + 1).toString()))
                        : Text(i18n.exerciseNr((index + 1).toString())),
                    tileColor: isCurrentSlotSelected ? Theme.of(context).highlightColor : null,
                    leading: selectedSlotId == null
                        ? ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle),
                          )
                        : const Icon(Icons.block),
                    subtitle: slot.entries.isEmpty
                        ? Text(i18n.setHasNoExercises)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...slot.entries.map(
                                (e) => Text(e.exerciseObj.getTranslation(languageCode).name),
                              ),
                            ],
                          ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
              ),
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
