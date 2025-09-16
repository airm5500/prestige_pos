// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Remise _$RemiseFromJson(Map<String, dynamic> json) => Remise(
  id: json['id'] as String?,
  libelle: json['libelle'] as String,
  code: json['code'] as String,
  typeRemiseId: json['typeRemiseId'] as String,
  typeLibelle: json['typeLibelle'] as String,
  taux: (json['taux'] as num).toDouble(),
);

Map<String, dynamic> _$RemiseToJson(Remise instance) => <String, dynamic>{
  'id': instance.id,
  'libelle': instance.libelle,
  'code': instance.code,
  'typeRemiseId': instance.typeRemiseId,
  'typeLibelle': instance.typeLibelle,
  'taux': instance.taux,
};
