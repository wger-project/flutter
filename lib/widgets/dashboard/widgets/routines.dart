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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/widgets/routines/forms/routine.dart';

class DashboardRoutineWidget extends StatefulWidget {
  const DashboardRoutineWidget();

  @override
  _DashboardRoutineWidgetState createState() => _DashboardRoutineWidgetState();
}

class _DashboardRoutineWidgetState extends State<DashboardRoutineWidget> {
  var _showDetail = false;
  bool _hasContent = false;

  @override
  Widget build(BuildContext context) {
    final routine = context.watch<RoutinesProvider>().activeRoutine;
    _hasContent = routine != null;
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              _hasContent ? routine!.name : AppLocalizations.of(context).labelWorkoutPlan,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Text(
              _hasContent
                  ? '${dateFormat.format(routine!.start)} - ${dateFormat.format(routine!.end)}'
                  : '',
            ),
            leading: Icon(
              Icons.fitness_center,
              color: Theme.of(context).textTheme.headlineSmall!.color,
            ),
            trailing: _hasContent
                ? Tooltip(
                    message: AppLocalizations.of(context).toggleDetails,
                    child: _showDetail ? const Icon(Icons.info) : const Icon(Icons.info_outline),
                  )
                : const SizedBox(),
            onTap: () {
              setState(() {
                _showDetail = !_showDetail;
              });
            },
          ),
          if (_hasContent) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DetailContentWidget(routine!.dayDataCurrentIteration, _showDetail),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  child: Text(AppLocalizations.of(context).goToDetailPage),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      RoutineScreen.routeName,
                      arguments: routine.id,
                    );
                  },
                ),
              ],
            ),
          ] else
            NothingFound(
              AppLocalizations.of(context).noRoutines,
              AppLocalizations.of(context).newRoutine,
              RoutineForm(Routine.empty()),
            ),
        ],
      ),
    );
  }
}

class DetailContentWidget extends StatelessWidget {
  final List<DayData> dayDataList;
  final bool showDetail;

  const DetailContentWidget(this.dayDataList, this.showDetail, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...dayDataList.where((dayData) => dayData.day != null).map((dayData) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    if (dayData.date.isSameDayAs(DateTime.now())) const Icon(Icons.today),
                    Expanded(
                      child: Text(
                        dayData.day == null || dayData.day!.isRest
                            ? AppLocalizations.of(context).restDay
                            : dayData.day!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: MutedText(
                        dayData.day != null ? dayData.day!.description : '',
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (dayData.day == null || dayData.day!.isRest)
                      const Icon(Icons.hotel)
                    else
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        color: wgerPrimaryButtonColor,
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            GymModeScreen.routeName,
                            arguments: GymModeArguments(
                              dayData.day!.routineId,
                              dayData.day!.id!,
                              dayData.iteration,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              ...dayData.slots.map(
                (slotData) => SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...slotData.setConfigs.map(
                        (s) => showDetail
                            ? Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.exercise
                                          .getTranslation(
                                              Localizations.localeOf(context).languageCode)
                                          .name),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child:
                                            MutedText(s.textRepr, overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
            ],
          );
        }),
      ],
    );
  }
}
