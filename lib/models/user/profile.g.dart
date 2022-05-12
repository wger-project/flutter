// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'email_verified', 'email'],
  );
  return Profile(
    id: json['id'] as int,
    emailVerified: json['email_verified'] as bool,
    email: json['email'] as String,
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'email_verified': instance.emailVerified,
      'email': instance.email,
    };
