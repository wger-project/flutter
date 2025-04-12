// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IngredientApiSearchDetails _$IngredientApiSearchDetailsFromJson(Map<String, dynamic> json) =>
    _IngredientApiSearchDetails(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      image: json['image'] as String?,
      imageThumbnail: json['image_thumbnail'] as String?,
    );

Map<String, dynamic> _$IngredientApiSearchDetailsToJson(_IngredientApiSearchDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'image_thumbnail': instance.imageThumbnail,
    };

_IngredientApiSearchEntry _$IngredientApiSearchEntryFromJson(Map<String, dynamic> json) =>
    _IngredientApiSearchEntry(
      value: json['value'] as String,
      data: IngredientApiSearchDetails.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IngredientApiSearchEntryToJson(_IngredientApiSearchEntry instance) =>
    <String, dynamic>{
      'value': instance.value,
      'data': instance.data,
    };

_IngredientApiSearch _$IngredientApiSearchFromJson(Map<String, dynamic> json) =>
    _IngredientApiSearch(
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => IngredientApiSearchEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$IngredientApiSearchToJson(_IngredientApiSearch instance) =>
    <String, dynamic>{
      'suggestions': instance.suggestions,
    };
