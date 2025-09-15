// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientUser _$ClientUserFromJson(Map<String, dynamic> json) => ClientUser(
  firstname: json['firstname'] as String,
  lastname: json['lastname'] as String,
  id: json['id'] as String,
  username: json['username'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$ClientUserToJson(ClientUser instance) =>
    <String, dynamic>{
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'id': instance.id,
      'username': instance.username,
      'password': instance.password,
    };
