// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mode_reglement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModeReglement _$ModeReglementFromJson(Map<String, dynamic> json) =>
    ModeReglement(
      id: json['id'] as String,
      libelle: json['libelle'] as String,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$ModeReglementToJson(ModeReglement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'libelle': instance.libelle,
      'order': instance.order,
    };
