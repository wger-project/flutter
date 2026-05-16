import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/core/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/models/measurements/measurement_group.dart';

part 'measurement_category.g.dart';

@JsonSerializable(explicitToJson: true)
class MeasurementCategory extends Equatable {
  @JsonKey(required: true)
  final int? id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String unit;

  @JsonKey(name: 'group', includeToJson: true)
  final int? groupId;

  @JsonKey(name: 'group_detail', includeToJson: false)
  final MeasurementGroup? groupDetail;

  @JsonKey(name: 'formula', includeToJson: true)
  final String? formula;

  @JsonKey(name: 'is_dynamic', includeToJson: false, defaultValue: false)
  final bool isDynamic;

  @JsonKey(defaultValue: [], toJson: _nullValue)
  final List<MeasurementEntry> entries;

  const MeasurementCategory({
    required this.id,
    required this.name,
    required this.unit,
    this.groupId,
    this.groupDetail,
    this.formula,
    this.isDynamic = false,
    this.entries = const [],
  });

  MeasurementCategory copyWith({
    int? id,
    String? name,
    String? unit,
    int? groupId,
    MeasurementGroup? groupDetail,
    String? formula,
    bool? isDynamic,
    List<MeasurementEntry>? entries,
  }) {
    return MeasurementCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      groupId: groupId ?? this.groupId,
      groupDetail: groupDetail ?? this.groupDetail,
      formula: formula ?? this.formula,
      isDynamic: isDynamic ?? this.isDynamic,
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
  List<Object?> get props => [id, name, unit, groupId, formula, isDynamic, entries];

  // Helper function which makes the entries list of the toJson output null, as it isn't needed
  static Null _nullValue(List<MeasurementEntry> _) => null;
}
