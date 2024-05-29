// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IngredientApiSearchDetailsImpl _$$IngredientApiSearchDetailsImplFromJson(
        Map<String, dynamic> json) =>
    _$IngredientApiSearchDetailsImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      image: json['image'] as String?,
      imageThumbnail: json['image_thumbnail'] as String?,
    );

Map<String, dynamic> _$$IngredientApiSearchDetailsImplToJson(
        _$IngredientApiSearchDetailsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'image_thumbnail': instance.imageThumbnail,
    };

_$IngredientApiSearchEntryImpl _$$IngredientApiSearchEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$IngredientApiSearchEntryImpl(
      value: json['value'] as String,
      data: IngredientApiSearchDetails.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$IngredientApiSearchEntryImplToJson(
        _$IngredientApiSearchEntryImpl instance) =>
    <String, dynamic>{
      'value': instance.value,
      'data': instance.data,
    };

_$IngredientApiSearchImpl _$$IngredientApiSearchImplFromJson(
        Map<String, dynamic> json) =>
    _$IngredientApiSearchImpl(
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) =>
              IngredientApiSearchEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$IngredientApiSearchImplToJson(
        _$IngredientApiSearchImpl instance) =>
    <String, dynamic>{
      'suggestions': instance.suggestions,
    };
