// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Variation _$VariationFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id'],
  );
  return Variation(
    id: json['id'] as int,
  );
}

Map<String, dynamic> _$VariationToJson(Variation instance) => <String, dynamic>{
      'id': instance.id,
    };
