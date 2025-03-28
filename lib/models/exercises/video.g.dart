// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'uuid',
      'video',
      'exercise',
      'size',
      'duration',
      'width',
      'height',
      'codec',
      'codec_long',
      'license',
      'license_author'
    ],
  );
  return Video(
    id: (json['id'] as num).toInt(),
    uuid: json['uuid'] as String,
    exerciseId: (json['exercise'] as num).toInt(),
    size: (json['size'] as num).toInt(),
    url: json['video'] as String,
    duration: stringToNum(json['duration'] as String?),
    width: (json['width'] as num).toInt(),
    height: (json['height'] as num).toInt(),
    codec: json['codec'] as String,
    codecLong: json['codec_long'] as String,
    license: (json['license'] as num).toInt(),
    licenseAuthor: json['license_author'] as String?,
  );
}

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'video': instance.url,
      'exercise': instance.exerciseId,
      'size': instance.size,
      'duration': numToString(instance.duration),
      'width': instance.width,
      'height': instance.height,
      'codec': instance.codec,
      'codec_long': instance.codecLong,
      'license': instance.license,
      'license_author': instance.licenseAuthor,
    };
