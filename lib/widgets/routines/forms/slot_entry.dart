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
import 'package:intl/intl.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/widgets/core/decimal_input.dart';
import 'package:wger/widgets/core/form_submit_button.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/exercises/autocompleter.dart';
import 'package:wger/widgets/routines/forms/repetitions.dart';
import 'package:wger/widgets/routines/forms/rir.dart';
import 'package:wger/widgets/routines/forms/weight.dart';
import 'package:wger/widgets/routines/slot.dart';

class SlotEntryForm extends ConsumerStatefulWidget {
  final SlotEntry entry;
  final bool simpleMode;
  final int routineId;

  const SlotEntryForm(this.entry, this.routineId, {this.simpleMode = true, super.key});

  @override
  _SlotEntryFormState createState() => _SlotEntryFormState();
}

class _SlotEntryFormState extends ConsumerState<SlotEntryForm> {
  bool isDeleting = false;

  final iconSize = 18.0;

  double setsSliderValue = 1.0;

  num? _weight;
  num? _maxWeight;
  num? _reps;
  num? _maxReps;
  final restController = TextEditingController();
  final maxRestController = TextEditingController();
  final rirController = TextEditingController();

  Widget errorMessage = const SizedBox.shrink();

  final _form = GlobalKey<FormState>();

  var _edit = false;

  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry.nrOfSetsConfigs.isNotEmpty) {
      setsSliderValue = widget.entry.nrOfSetsConfigs.first.value.toDouble();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllersInitialized) {
      return;
    }
    _controllersInitialized = true;

    if (widget.entry.weightConfigs.isNotEmpty) {
      _weight = widget.entry.weightConfigs.first.value;
    }
    if (widget.entry.maxWeightConfigs.isNotEmpty) {
      _maxWeight = widget.entry.maxWeightConfigs.first.value;
    }
    if (widget.entry.repetitionsConfigs.isNotEmpty) {
      _reps = widget.entry.repetitionsConfigs.first.value;
    }
    if (widget.entry.maxRepetitionsConfigs.isNotEmpty) {
      _maxReps = widget.entry.maxRepetitionsConfigs.first.value;
    }

    if (widget.entry.restTimeConfigs.isNotEmpty) {
      restController.text = widget.entry.restTimeConfigs.first.value.round().toString();
    }
    if (widget.entry.maxRestTimeConfigs.isNotEmpty) {
      maxRestController.text = widget.entry.maxRestTimeConfigs.first.value.round().toString();
    }

    if (widget.entry.rirConfigs.isNotEmpty) {
      // RiR uses 0.5 steps, so the fractional part must be kept
      rirController.text = widget.entry.rirConfigs.first.value.toString();
    }
  }

  @override
  void dispose() {
    restController.dispose();
    maxRestController.dispose();

    rirController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

    final provider = ref.read(routinesRiverpodProvider.notifier);
    final isOnline = ref.watch(networkStatusProvider);

    return Form(
      key: _form,
      child: Column(
        children: [
          errorMessage,
          ListTile(
            title: Text(
              widget.entry.exerciseObj.getTranslation(languageCode).name,
              style: Theme.of(context).textTheme.titleMedium,
              // textAlign: TextAlign.center,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() => _edit = !_edit);
                  },
                  icon: _edit
                      ? Icon(Icons.edit_off, size: iconSize)
                      : Icon(Icons.edit, size: iconSize),
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: iconSize),
                  onPressed: isDeleting || !isOnline
                      ? null
                      : () async {
                          setState(() => isDeleting = true);
                          try {
                            await provider.deleteSlotEntry(widget.entry.id!, widget.routineId);
                          } on WgerHttpException catch (error) {
                            if (context.mounted) {
                              setState(() {
                                errorMessage = FormHttpErrorsWidget(error);
                              });
                            }
                          } finally {
                            if (mounted) {
                              setState(() => isDeleting = false);
                            }
                          }
                        },
                ),
              ],
            ),
          ),
          if (_edit)
            ExerciseAutocompleter(
              onExerciseSelected: (exercise) => setState(() {
                widget.entry.exercise = exercise;
                _edit = false;
              }),
            ),
          Row(
            children: [
              Text('${i18n.sets}: ${setsSliderValue.round()}'),
              Expanded(
                child: Slider(
                  value: setsSliderValue,
                  min: 1,
                  max: 20,
                  divisions: 20,
                  label: setsSliderValue.round().toString(),
                  onChanged: (double value) {
                    setState(() => setsSliderValue = value);
                  },
                ),
              ),
            ],
          ),
          if (!widget.simpleMode)
            DropdownButtonFormField<SlotEntryType>(
              key: const Key('field-slot-entry-type'),
              initialValue: widget.entry.type,
              decoration: const InputDecoration(labelText: 'Typ'),
              items: SlotEntryType.values.map((type) {
                return DropdownMenuItem(
                  key: Key('slot-entry-type-option-${type.name}'),
                  value: type,
                  child: Text('${type.name.toUpperCase()} - ${type.i18Label(i18n)}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  widget.entry.type = value!;
                });
              },
            ),
          if (!widget.simpleMode)
            WeightUnitInputWidget(
              widget.entry.weightUnitObj,
              onChanged: (value) {
                widget.entry.weightUnitObj = null;
                widget.entry.weightUnitId = null;
              },
            ),
          Row(
            spacing: 10,
            children: [
              Flexible(
                child: DecimalInputWidget(
                  key: const ValueKey('field-weight'),
                  value: _weight,
                  labelText: i18n.weight,
                  onChanged: (v) => _weight = v,
                ),
              ),
              if (!widget.simpleMode)
                Flexible(
                  child: DecimalInputWidget(
                    key: const ValueKey('field-max-weight'),
                    value: _maxWeight,
                    labelText: i18n.max,
                    onChanged: (v) => _maxWeight = v,
                  ),
                ),
            ],
          ),
          if (!widget.simpleMode)
            RepetitionUnitInputWidget(
              widget.entry.repetitionUnitObj,
              onChanged: (value) {
                widget.entry.repetitionUnitObj = null;
                widget.entry.repetitionUnitId = null;
              },
            ),
          Row(
            spacing: 10,
            children: [
              Flexible(
                child: DecimalInputWidget(
                  key: const ValueKey('field-repetitions'),
                  value: _reps,
                  labelText: i18n.repetitions,
                  onChanged: (v) => _reps = v,
                ),
              ),
              if (!widget.simpleMode)
                Flexible(
                  child: DecimalInputWidget(
                    key: const ValueKey('field-max-repetitions'),
                    value: _maxReps,
                    labelText: i18n.max,
                    onChanged: (v) => _maxReps = v,
                  ),
                ),
            ],
          ),
          if (!widget.simpleMode)
            Row(
              spacing: 10,
              children: [
                Flexible(
                  child: TextFormField(
                    key: const ValueKey('field-rest'),
                    controller: restController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: i18n.restTime),
                    validator: (value) {
                      if (value != null && value != '' && int.tryParse(value) == null) {
                        return i18n.enterValidNumber;
                      }
                      return null;
                    },
                  ),
                ),
                Flexible(
                  child: TextFormField(
                    key: const ValueKey('field-max-rest'),
                    controller: maxRestController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: i18n.max),
                    validator: (value) {
                      if (value != null && value != '' && int.tryParse(value) == null) {
                        return i18n.enterValidNumber;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          if (!widget.simpleMode)
            RiRInputWidget(
              rirController.text == '' ? null : num.parse(rirController.text),
              onChanged: (value) => rirController.text = value,
            ),
          const SizedBox(height: 5),
          FormSubmitButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            enabled: isOnline,
            label: AppLocalizations.of(context).save,
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }
              _form.currentState!.save();

              // Process new, edited or entries to be deleted
              await Future.wait([
                provider.handleConfig(
                  widget.entry,
                  setsSliderValue == 0 ? null : setsSliderValue.round(),
                  ConfigType.sets,
                ),
                provider.handleConfig(widget.entry, _weight, ConfigType.weight),
                provider.handleConfig(widget.entry, _maxWeight, ConfigType.maxWeight),
                provider.handleConfig(widget.entry, _reps, ConfigType.repetitions),
                provider.handleConfig(widget.entry, _maxReps, ConfigType.maxRepetitions),
                provider.handleConfig(
                  widget.entry,
                  numberFormat.tryParse(restController.text),
                  ConfigType.rest,
                ),
                provider.handleConfig(
                  widget.entry,
                  numberFormat.tryParse(maxRestController.text),
                  ConfigType.maxRest,
                ),
                provider.handleConfig(
                  widget.entry,
                  // RiR is slider-driven and held as an invariant string
                  num.tryParse(rirController.text),
                  ConfigType.rir,
                ),
              ]);
              await provider.editSlotEntry(widget.entry, widget.routineId);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
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

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final provider = ref.read(routinesRiverpodProvider.notifier);
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
              title: Text(i18n.addExercise, style: Theme.of(context).textTheme.titleMedium),
              onTap: isAddingSlot
                  ? null
                  : () async {
                      setState(() => isAddingSlot = true);

                      final newSlot = await provider.addSlot(
                        Slot.withData(day: widget.day.id, order: widget.slots.length + 1),
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
