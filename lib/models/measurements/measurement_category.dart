import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

part 'measurement_category.g.dart';

@JsonSerializable(explicitToJson: true)
class MeasurementCategory extends Equatable {
  @JsonKey(required: true)
  final int? id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true, name: 'internal_name')
  final String? internalName;

  @JsonKey(required: true)
  final String unit;

  @JsonKey(required: true, name: 'externally_synced')
  final bool externallySynced;

  @JsonKey(toJson: _nullValue)
  final List<MeasurementEntry> entries;

  const MeasurementCategory({
    this.id,
    required this.name,
    required this.unit,
    this.entries = const [],
    this.internalName,
    this.externallySynced = false,
  });

  MeasurementCategory copyWith({
    int? id,
    String? name,
    String? internalName,
    String? unit,
    bool? externallySynced,
    List<MeasurementEntry>? entries,
  }) {
    return MeasurementCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      internalName: internalName ?? this.internalName,
      unit: unit ?? this.unit,
      externallySynced: externallySynced ?? this.externallySynced,
      entries: entries ?? this.entries,
    );
  }

  MeasurementEntry findEntryById(int entryId) {
    return entries.firstWhere(
      (entry) => entry.id == entryId,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

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
