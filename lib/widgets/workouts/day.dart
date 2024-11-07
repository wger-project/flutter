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
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/slot_data.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/exercises/exercises.dart';
import 'package:wger/widgets/exercises/images.dart';
import 'package:wger/widgets/workouts/forms.dart';

class SettingWidget extends StatelessWidget {
  final SetConfigData setConfigData;
  final bool expanded;
  final Function toggle;

  const SettingWidget({
    required this.setConfigData,
    required this.expanded,
    required this.toggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: InkWell(
          child: SizedBox(
            width: 45,
            child: ExerciseImageWidget(image: setConfigData.exercise.getMainImage),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(setConfigData.exercise
                      .getExercise(Localizations.localeOf(context).languageCode)
                      .name),
                  content: ExerciseDetail(setConfigData.exercise),
                  actions: [
                    TextButton(
                      child: Text(
                        MaterialLocalizations.of(context).closeButtonLabel,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        title: Text(
          setConfigData.exercise.getExercise(Localizations.localeOf(context).languageCode).name,
        ),
        subtitle: Text(setConfigData.textRepr));
  }
}

class WorkoutDayWidget extends StatefulWidget {
  final DayData _dayData;

  const WorkoutDayWidget(this._dayData);

  @override
  _WorkoutDayWidgetState createState() => _WorkoutDayWidgetState();
}

class _WorkoutDayWidgetState extends State<WorkoutDayWidget> {
  bool _editing = false;
  late List<SlotData> _slots;

  @override
  void initState() {
    super.initState();
    _slots = widget._dayData.slots;
    //_slots.sort((a, b) => a.order.compareTo(b.order));
  }

  void _toggleExpanded() {
    setState(() {
      _editing = !_editing;
    });
  }

  Widget getSlotDataRow(SlotData slotData, int index) {
    return Row(
      key: ValueKey(index),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_editing)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.delete),
            iconSize: ICON_SIZE_SMALL,
            tooltip: AppLocalizations.of(context).delete,
            onPressed: () {
              // Provider.of<RoutinesProvider>(context, listen: false).deleteSet(set);
            },
          ),
        Expanded(
          child: Column(
            children: [
              if (slotData.comment != '') MutedText(slotData.comment),
              ...slotData.setConfigs.map(
                (setting) => SettingWidget(
                  setConfigData: setting,
                  expanded: _editing,
                  toggle: _toggleExpanded,
                ),
              ),
              const Divider(),
            ],
          ),
        ),
        if (_editing)
          ReorderableDragStartListener(
            index: index,
            child: const IconButton(
              icon: Icon(Icons.drag_handle),
              onPressed: null,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DayHeader(
              day: widget._dayData,
              expanded: _editing,
              toggle: _toggleExpanded,
            ),
            if (_editing)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      label: Text(AppLocalizations.of(context).addSet),
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          FormScreen.routeName,
                          arguments: FormScreenArguments(
                            AppLocalizations.of(context).newSet,
                            SetFormWidget(widget._dayData.day!),
                            hasListView: true,
                            padding: EdgeInsets.zero,
                          ),
                        );
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_month),
                      label: Text(AppLocalizations.of(context).edit),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          FormScreen.routeName,
                          arguments: FormScreenArguments(
                            AppLocalizations.of(context).edit,
                            DayFormWidget(
                              Provider.of<RoutinesProvider>(
                                context,
                                listen: false,
                              ).findById(widget._dayData.day!.routineId),
                              widget._dayData.day,
                            ),
                            hasListView: true,
                          ),
                        );
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete),
                      label: Text(AppLocalizations.of(context).delete),
                      onPressed: () {
                        Provider.of<RoutinesProvider>(
                          context,
                          listen: false,
                        ).deleteDay(widget._dayData.day!);
                      },
                    ),
                  ],
                ),
              ),
            const Divider(),
            ReorderableListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) async {
                int startIndex = 0;
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                  startIndex = oldIndex;
                } else {
                  startIndex = newIndex;
                }
                setState(() {
                  _slots.insert(newIndex, _slots.removeAt(oldIndex));
                });
                // _slots = await Provider.of<RoutinesProvider>(
                //   context,
                //   listen: false,
                // ).reorderSets(_slots, startIndex);
              },
              children: [
                for (var i = 0; i < widget._dayData.slots.length; i++)
                  getSlotDataRow(widget._dayData.slots[i], i),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DayHeader extends StatelessWidget {
  final DayData _dayData;
  final bool _editing;
  final Function _toggle;

  const DayHeader({
    required DayData day,
    required bool expanded,
    required Function toggle,
  })  : _dayData = day,
        _editing = expanded,
        _toggle = toggle;

  @override
  Widget build(BuildContext context) {
    return _dayData.day == null || _dayData.day!.isRest
        ? ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              'REST DAY',
              style: Theme.of(context).textTheme.headlineSmall,
              overflow: TextOverflow.ellipsis,
            ),
            leading: const Icon(Icons.hotel),
            minLeadingWidth: 8,
          )
        : ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              _dayData.day!.name,
              style: Theme.of(context).textTheme.headlineSmall,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(_dayData.day!.description),
            leading: const Icon(Icons.play_arrow),
            minLeadingWidth: 8,
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 40, width: 1, child: VerticalDivider()),
              const SizedBox(width: 10),
              IconButton(
                icon: _editing ? const Icon(Icons.done) : const Icon(Icons.edit),
                tooltip: _editing
                    ? AppLocalizations.of(context).done
                    : AppLocalizations.of(context).edit,
                onPressed: () {
                  _toggle();
                },
              ),
            ]),
            onTap: () {
              Navigator.of(context).pushNamed(
                GymModeScreen.routeName,
                arguments: _dayData,
              );
            },
          );
  }
}
