import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

part 'measurement_category.g.dart';

@JsonSerializable(explicitToJson: true)
class MeasurementCategory extends Equatable {
  @JsonKey(required: true)
  final int? id;

  @JsonKey(required: true)
  final String? uuid;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true, name: 'internal_name')
  final String? internalName;

  @JsonKey(required: true)
  final String unit;

  @JsonKey(required: true)
  final String source;

  @JsonKey(defaultValue: [], toJson: _nullValue)
  final List<MeasurementEntry> entries;

  MeasurementCategory({
    this.id,
    required this.name,
    required this.unit,
    this.entries = const [],
    this.internalName,
    this.source = 'manual',
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v7();

  MeasurementCategory copyWith({
    int? id,
    String? uuid,
    String? name,
    String? internalName,
    String? unit,
    String? source,
    List<MeasurementEntry>? entries,
  }) {
    return MeasurementCategory(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      internalName: internalName ?? this.internalName,
      unit: unit ?? this.unit,
      source: source ?? this.source,
      entries: entries ?? this.entries,
    );
  }

  MeasurementEntry findEntryById(int entryId) {
    return entries.firstWhere(
      (entry) => entry.id == entryId,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  bool get isExternal => source != 'manual';

  bool get isInternal => source == 'manual';

  // Boilerplate
  factory MeasurementCategory.fromJson(Map<String, dynamic> json) =>
      _$MeasurementCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementCategoryToJson(this);

  @override
  List<Object?> get props => [id, name, unit, entries];

  // Helper function which makes the entries list of the toJson output null, as it isn't needed
  //ignore: always_declare_return_types
  static _nullValue(_) => null;
}
