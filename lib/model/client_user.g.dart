// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientUser _$ClientUserFromJson(Map<String, dynamic> json) => ClientUser(
  firstname: json['firstname'] as String,
  lastname: json['lastname'] as String,
  id: json['id'] as String,
  username: json['username'] as String?,
  password: json['password'] as String?,
  authorities: json['authorities'] as String?,
  enabled: json['enabled'] as bool?,
  accountNonLocked: json['accountNonLocked'] as bool?,
  accountNonExpired: json['accountNonExpired'] as bool?,
  credentialsNonExpired: json['credentialsNonExpired'] as bool?,
);

Map<String, dynamic> _$ClientUserToJson(ClientUser instance) =>
    <String, dynamic>{
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'id': instance.id,
      'username': instance.username,
      'password': instance.password,
      'authorities': instance.authorities,
      'enabled': instance.enabled,
      'accountNonLocked': instance.accountNonLocked,
      'accountNonExpired': instance.accountNonExpired,
      'credentialsNonExpired': instance.credentialsNonExpired,
    };
