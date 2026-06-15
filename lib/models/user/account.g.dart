// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'username',
      'email',
      'email_verified',
      'is_trustworthy',
    ],
  );
  return Account(
    username: json['username'] as String,
    email: json['email'] as String,
    emailVerified: json['email_verified'] as bool,
    isTrustworthy: json['is_trustworthy'] as bool,
  );
}
