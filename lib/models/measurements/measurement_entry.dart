import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'measurement_entry.g.dart';

@JsonSerializable()
class MeasurementEntry extends Equatable {
  @JsonKey(required: true)
  final int? id;

  @JsonKey(required: true)
  final String uuid;

  @JsonKey(required: true)
  final String source;

  @JsonKey(required: true)
  final int category;

  @JsonKey(required: true)
  final DateTime created;

  @JsonKey(required: true)
  final DateTime date;

  @JsonKey(required: true)
  final num value;

  @JsonKey(required: true, defaultValue: '')
  final String notes;

  MeasurementEntry({
    required this.id,
    required this.category,
    required this.date,
    required this.value,
    required this.notes,
    DateTime? created,
    String? source,
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v7(),
       source = source ?? 'manual',
       created = created ?? DateTime.now();

  MeasurementEntry copyWith({
    int? id,
    String? uuid,
    String? source,
    int? category,
    DateTime? created,
    DateTime? date,
    num? value,
    String? notes,
  }) => MeasurementEntry(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    source: source ?? this.source,
    category: category ?? this.category,
    created: created ?? this.created,
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
