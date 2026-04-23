/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:wger/helpers/date.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/async_value_widget.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/core/error.dart';
import 'package:wger/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/widgets/routines/forms/routine.dart';

class DashboardRoutineWidget extends ConsumerStatefulWidget {
  const DashboardRoutineWidget();

  @override
  _DashboardRoutineWidgetState createState() => _DashboardRoutineWidgetState();
}

class _DashboardRoutineWidgetState extends ConsumerState<DashboardRoutineWidget> {
  var _showDetail = false;

  /// Routine ID we've already requested a full fetch for. The sparse list
  /// landing first only carries `name`/`start`/`end`; `dayData` (which
  /// the detail rendering below depends on) is only populated by
  /// [RoutinesRiverpod.fetchAndSetRoutineFull]. We track which routine we
  /// already triggered to avoid re-firing on every rebuild.
  int? _hydratedRoutineId;

  /// True while the auto-hydration call is in flight, so we can render a
  /// spinner instead of the (still-empty) detail block.
  bool _isHydrating = false;

  /// Renders the dashboard card shell so loading / error / empty / data
  /// states all share the same outline (icon + title) instead of the card
  /// hopping around. The trailing widget changes per state.
  Widget _shell(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget trailing,
    Widget? child,
  }) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
            subtitle: Text(subtitle),
            leading: Icon(
              Icons.fitness_center,
              color: Theme.of(context).textTheme.headlineSmall!.color,
            ),
            trailing: trailing,
          ),
          ?child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);
    final i18n = AppLocalizations.of(context);

    final asyncState = ref.watch(routinesRiverpodProvider);

    // Auto-hydrate the current routine once it appears in the sparse list
    final currentId = asyncState.value?.currentRoutine?.id;
    if (currentId != null && currentId != _hydratedRoutineId) {
      _hydratedRoutineId = currentId;
      Future.microtask(() async {
        if (!mounted) {
          return;
        }
        setState(() => _isHydrating = true);
        try {
          await ref.read(routinesRiverpodProvider.notifier).fetchAndSetRoutineFull(currentId);
        } finally {
          if (mounted) {
            setState(() => _isHydrating = false);
          }
        }
      });
    }

    return AsyncValueWidget<RoutinesState>(
      value: asyncState,
      loggerName: 'DashboardRoutineWidget',
      loading: _shell(
        context,
        title: i18n.labelWorkoutPlan,
        subtitle: '',
        trailing: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorBuilder: (e, st) => _shell(
        context,
        title: i18n.labelWorkoutPlan,
        subtitle: i18n.anErrorOccurred,
        trailing: const Icon(Icons.error_outline, color: Colors.red),
        child: StreamErrorIndicator(e, stacktrace: st),
      ),
      data: (state) {
        final routine = state.currentRoutine;
        if (routine == null) {
          return _shell(
            context,
            title: i18n.labelWorkoutPlan,
            subtitle: '',
            trailing: const SizedBox(),
            child: NothingFound(
              i18n.noRoutines,
              i18n.newRoutine,
              RoutineForm(Routine.empty()),
            ),
          );
        }

        return Card(
          child: Column(
            children: [
              ListTile(
                title: Text(routine.name, style: Theme.of(context).textTheme.headlineSmall),
                subtitle: Text(
                  '${dateFormat.format(routine.start)} - ${dateFormat.format(routine.end)}',
                ),
                leading: Icon(
                  Icons.fitness_center,
                  color: Theme.of(context).textTheme.headlineSmall!.color,
                ),
                trailing: _isHydrating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Tooltip(
                        message: i18n.toggleDetails,
                        child: _showDetail
                            ? const Icon(Icons.info)
                            : const Icon(Icons.info_outline),
                      ),
                // Toggle is meaningless while the day data is still
                // loading — disable the tap until hydration finishes.
                onTap: _isHydrating
                    ? null
                    : () {
                        setState(() {
                          _showDetail = !_showDetail;
                        });
                      },
              ),
              if (_isHydrating)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DetailContentWidget(
                    routine.dayDataCurrentIterationFiltered,
                    _showDetail,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    child: Text(i18n.goToDetailPage),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        RoutineScreen.routeName,
                        arguments: routine.id,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
                            : dayData.day!.nameWithType,
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
                                      Text(
                                        s.exercise
                                            .getTranslation(
                                              Localizations.localeOf(context).languageCode,
                                            )
                                            .name,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: MutedText(
                                          s.textRepr,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
