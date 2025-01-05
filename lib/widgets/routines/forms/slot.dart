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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/exercises/autocompleter.dart';

class ProgressionRulesInfoBox extends StatelessWidget {
  final Exercise exercise;

  const ProgressionRulesInfoBox(this.exercise, {super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final i18n = AppLocalizations.of(context);

    return Column(
      children: [
        ListTile(
          title: Text(
            exercise.getExercise(languageCode).name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          tileColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text(
            i18n.progressionRules,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class SlotEntryForm extends StatefulWidget {
  final SlotEntry entry;

  const SlotEntryForm(this.entry, {super.key});

  @override
  State<SlotEntryForm> createState() => _SlotEntryFormState();
}

class _SlotEntryFormState extends State<SlotEntryForm> {
  final iconSize = 18.0;

  double setsSliderValue = 1.0;

  final weightController = TextEditingController();
  final repsController = TextEditingController();

  final _form = GlobalKey<FormState>();

  var _edit = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry.nrOfSetsConfigs.isNotEmpty) {
      setsSliderValue = widget.entry.nrOfSetsConfigs.first.value.toDouble();
    }
    if (widget.entry.weightConfigs.isNotEmpty) {
      weightController.text = widget.entry.weightConfigs.first.value.toString();
    }
    if (widget.entry.repsConfigs.isNotEmpty) {
      repsController.text = widget.entry.repsConfigs.first.value.round().toString();
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Form(
      key: _form,
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.entry.exerciseObj.getExercise(languageCode).name,
              style: Theme.of(context).textTheme.titleMedium,
              // textAlign: TextAlign.center,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _edit = !_edit;
                    });
                  },
                  icon: _edit
                      ? Icon(Icons.edit_off, size: iconSize)
                      : Icon(Icons.edit, size: iconSize),
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: iconSize),
                  onPressed: () {
                    context.read<RoutinesProvider>().deleteSlotEntry(widget.entry.id!);
                  },
                ),
              ],
            ),
          ),
          if (_edit)
            ExerciseAutocompleter(
              onExerciseSelected: (exercise) => {
                setState(() {
                  widget.entry.exercise = exercise;
                })
              },
            ),
          Text('${i18n.sets} — ${setsSliderValue.round()}'),
          Slider.adaptive(
            value: setsSliderValue,
            min: 0,
            max: 20,
            divisions: 20,
            label: setsSliderValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                setsSliderValue = value;
              });
            },
          ),
          TextFormField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: i18n.weight),
            validator: (value) {
              if (value != null && double.tryParse(value) == null) {
                return i18n.enterValidNumber;
              }
              return null;
            },
          ),
          TextFormField(
            controller: repsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: i18n.repetitions),
            validator: (value) {
              if (value != null && int.tryParse(value) == null) {
                return i18n.enterValidNumber;
              }
              return null;
            },
          ),
          const SizedBox(height: 5),
          OutlinedButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            child: Text(i18n.save),
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }
              _form.currentState!.save();

              final provider = Provider.of<RoutinesProvider>(context, listen: false);

              // Process new, edited or entries to be deleted
              provider.handleConfig(
                widget.entry,
                weightController.text,
                ConfigType.weight,
              );
              provider.handleConfig(
                widget.entry,
                setsSliderValue == 0 ? '' : setsSliderValue.toString(),
                ConfigType.sets,
              );
              provider.handleConfig(
                widget.entry,
                repsController.text,
                ConfigType.reps,
              );
              provider.editSlotEntry(widget.entry);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class SlotDetailWidget extends StatefulWidget {
  final Slot slot;

  const SlotDetailWidget(this.slot, {super.key});

  @override
  State<SlotDetailWidget> createState() => _SlotDetailWidgetState();
}

class _SlotDetailWidgetState extends State<SlotDetailWidget> {
  bool _addSuperset = false;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final provider = context.read<RoutinesProvider>();

    return Column(
      children: [
        ...widget.slot.entries.map((entry) => entry.hasProgressionRules
            ? ProgressionRulesInfoBox(entry.exerciseObj)
            : SlotEntryForm(entry)),
        const SizedBox(height: 10),
        if (_addSuperset || widget.slot.entries.isEmpty)
          ExerciseAutocompleter(
            onExerciseSelected: (exercise) async {
              final SlotEntry entry = SlotEntry.withData(
                slotId: widget.slot.id!,
                order: widget.slot.entries.length + 1,
                exercise: exercise,
              );

              _addSuperset = false;
              await provider.addSlotEntry(entry);
            },
          ),
        if (widget.slot.entries.isNotEmpty)
          FilledButton(
            onPressed: () {
              setState(() {
                _addSuperset = !_addSuperset;
              });
            },
            child: Text(i18n.addSuperset),
          ),
        const SizedBox(height: 5),
      ],
    );
  }
}

class ReorderableSlotList extends StatefulWidget {
  final List<Slot> slots;
  final Day day;

  const ReorderableSlotList(this.slots, this.day);

  @override
  _SlotFormWidgetStateNg createState() => _SlotFormWidgetStateNg();
}

class _SlotFormWidgetStateNg extends State<ReorderableSlotList> {
  int? selectedSlotId;
  bool simpleMode = true;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    final provider = context.read<RoutinesProvider>();

    final languageCode = Localizations.localeOf(context).languageCode;

    return Column(
      children: [
        if (!widget.day.isRest)
          SwitchListTile(
            value: simpleMode,
            title: const Text('Simple edit mode'),
            subtitle: const Text('Hides some more advanced fields when editing'),
            contentPadding: const EdgeInsets.all(4),
            onChanged: (value) {
              setState(() {
                simpleMode = value;
              });
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
                    title: Text(i18n.exerciseNr(index + 1)),
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
                              ...slot.entries
                                  .map((e) => Text(e.exerciseObj.getExercise(languageCode).name)),
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
                            onPressed: () async {
                              selectedSlotId = null;
                              await provider.deleteSlot(slot.id!);
                            }),
                      ],
                    ),
                  ),
                  if (isCurrentSlotSelected) SlotDetailWidget(slot),
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

              provider.editSlots(widget.slots);
            });
          },
        ),
        if (!widget.day.isRest)
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(
              i18n.addExercise,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () async {
              final newSlot = await provider.addSlot(Slot.withData(
                day: widget.day.id,
                order: widget.slots.length + 1,
              ));
              setState(() {
                selectedSlotId = newSlot.id;
              });
            },
          ),
      ],
    );
  }
}
