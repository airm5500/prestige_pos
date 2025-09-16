// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'officine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Officine _$OfficineFromJson(Map<String, dynamic> json) => Officine(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$OfficineToJson(Officine instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'phone': instance.phone,
  'email': instance.email,
  'note': instance.note,
};
