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

import 'package:json_annotation/json_annotation.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/slot.dart';

part 'day.g.dart';

enum DayType { custom, enom, amrap, hiit, tabata, edt, rft, afap }

extension DayTypeExtension on DayType {
  String i18Label(AppLocalizations i18n) {
    switch (this) {
      case DayType.custom:
        return i18n.dayTypeCustom;
      case DayType.enom:
        return i18n.dayTypeEnom;
      case DayType.amrap:
        return i18n.dayTypeAmrap;
      case DayType.hiit:
        return i18n.dayTypeHiit;
      case DayType.tabata:
        return i18n.dayTypeTabata;
      case DayType.edt:
        return i18n.dayTypeEdt;
      case DayType.rft:
        return i18n.dayTypeRft;
      case DayType.afap:
        return i18n.dayTypeAfap;
    }
  }
}

@JsonSerializable()
class Day {
  static const MIN_LENGTH_NAME = 3;
  static const MAX_LENGTH_NAME = 20;
  static const MAX_LENGTH_DESCRIPTION = 1000;

  @JsonKey(required: true, includeToJson: false)
  int? id;

  @JsonKey(required: true, name: 'routine')
  late int routineId;

  @JsonKey(required: true)
  late String name;

  @JsonKey(required: true)
  late String description;

  @JsonKey(required: true)
  late DayType type;

  @JsonKey(required: true, name: 'is_rest')
  late bool isRest;

  @JsonKey(required: true, name: 'need_logs_to_advance')
  late bool needLogsToAdvance;

  @JsonKey(required: true)
  late num order;

  @JsonKey(required: true)
  late Object? config;

  @JsonKey(required: false, includeFromJson: true, includeToJson: false)
  List<Slot> slots = [];

  Day({
    this.id,
    required this.routineId,
    required this.name,
    this.description = '',
    this.isRest = false,
    this.needLogsToAdvance = false,
    this.type = DayType.custom,
    this.order = 1,
    this.config,
    this.slots = const [],
  });

  Day copyWith({
    int? id,
    int? routineId,
    String? name,
    String? description,
    DayType? type,
    bool? isRest,
    bool? needLogsToAdvance,
    num? order,
    Object? config,
    List<Slot>? slots,
  }) {
    return Day(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      isRest: isRest ?? this.isRest,
      needLogsToAdvance: needLogsToAdvance ?? this.needLogsToAdvance,
      order: order ?? this.order,
      config: config ?? this.config,
      slots: slots ?? this.slots,
    );
  }

  bool get isSpecialType => type != DayType.custom;

  String typeLabel() => isSpecialType ? '\n(${type.name.toUpperCase()})' : '';

  // Boilerplate
  factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);

  Map<String, dynamic> toJson() => _$DayToJson(this);
}
