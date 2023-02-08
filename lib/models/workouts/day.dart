/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/workouts/set.dart';

part 'day.g.dart';

@JsonSerializable()
class Day {
  static const Map<int, String> weekdays = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true, name: 'training')
  late int workoutId;

  @JsonKey(required: true)
  late String description;

  @JsonKey(required: true, name: 'day')
  List<int> daysOfWeek = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Set> sets = [];

  //@JsonKey(includeFromJson: false, includeToJson: false)
  //late WorkoutPlan workout;

  Day() {
    daysOfWeek = [];
    sets = [];
  }

  String getDayName(int weekDay) {
    return weekdays[weekDay]!;
  }

  String get getDaysText {
    return daysOfWeek.map((e) => getDayName(e)).join(', ');
  }

  String getDaysTextTranslated(locale) {
    return daysOfWeek.map((e) => getDayTranslated(e, locale)).join(', ');
  }

  /// Returns the translated name of the given day
  String getDayTranslated(int day, locale) {
    // Isn't there another way?... 🙄
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday));

    return DateFormat(DateFormat.WEEKDAY, locale).format(firstDayOfWeek.add(Duration(days: day)));
  }

  // Boilerplate
  factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);

  Map<String, dynamic> toJson() => _$DayToJson(this);
}
