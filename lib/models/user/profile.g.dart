// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['username', 'email_verified', 'email'],
  );
  return Profile(
    username: json['username'] as String,
    emailVerified: json['email_verified'] as bool,
    email: json['email'] as String,
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'username': instance.username,
      'email_verified': instance.emailVerified,
      'email': instance.email,
    };
