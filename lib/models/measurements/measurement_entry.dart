import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'measurement_entry.g.dart';

@JsonSerializable()
class MeasurementEntry extends Equatable {
  @JsonKey(required: true)
  final int? id;

  @JsonKey(required: true)
  final int category;

  @JsonKey(required: true, toJson: toDate)
  final DateTime date;

  @JsonKey(required: true)
  final num value;

  @JsonKey(required: true, defaultValue: '')
  final String notes;

  const MeasurementEntry({
    required this.id,
    required this.category,
    required this.date,
    required this.value,
    required this.notes,
  });

  MeasurementEntry copyWith({int? id, int? category, DateTime? date, num? value, String? notes}) =>
      MeasurementEntry(
        id: id ?? this.id,
        category: category ?? this.category,
        date: date ?? this.date,
        value: value ?? this.value,
        notes: notes ?? this.notes,
      );

  // Boilerplate
  factory MeasurementEntry.fromJson(Map<String, dynamic> json) => _$MeasurementEntryFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementEntryToJson(this);

  @override
  List<Object?> get props => [id, category, date, value, notes];
}
