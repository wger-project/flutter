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

  @JsonKey(name: 'dynamic_type', includeToJson: true)
  final String? formula;

  @JsonKey(name: 'dynamic_params', includeToJson: true, defaultValue: <String, dynamic>{})
  final Map<String, dynamic> dynamicParams;

  @JsonKey(defaultValue: [], toJson: _nullValue)
  final List<MeasurementEntry> entries;

  const MeasurementCategory({
    required this.id,
    required this.name,
    required this.unit,
    this.groupId,
    this.groupDetail,
    this.formula,
    this.dynamicParams = const {},
    this.entries = const [],
  });

  bool get isDynamic => formula != null && formula != 'NONE';

  MeasurementCategory copyWith({
    int? id,
    String? name,
    String? unit,
    int? groupId,
    bool clearGroup = false,
    MeasurementGroup? groupDetail,
    bool clearGroupDetail = false,
    String? formula,
    Map<String, dynamic>? dynamicParams,
    List<MeasurementEntry>? entries,
  }) {
    return MeasurementCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      groupId: clearGroup ? null : (groupId ?? this.groupId),
      groupDetail: clearGroupDetail ? null : (groupDetail ?? this.groupDetail),
      formula: formula ?? this.formula,
      dynamicParams: dynamicParams ?? this.dynamicParams,
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
  List<Object?> get props => [id, name, unit, groupId, formula, dynamicParams, entries];

  // Helper function which makes the entries list of the toJson output null, as it isn't needed
  static Null _nullValue(List<MeasurementEntry> _) => null;
}
