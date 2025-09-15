// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vente_reglement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenteReglement _$VenteReglementFromJson(Map<String, dynamic> json) =>
    VenteReglement(
      typeReglement: json['typeReglement'] as String?,
      montant: (json['montant'] as num).toInt(),
      montantAttentu: (json['montantAttentu'] as num?)?.toInt(),
      typeReglementId: json['typeReglementId'] as String,
    );

Map<String, dynamic> _$VenteReglementToJson(VenteReglement instance) =>
    <String, dynamic>{
      'typeReglement': instance.typeReglement,
      'montant': instance.montant,
      'montantAttentu': instance.montantAttentu,
      'typeReglementId': instance.typeReglementId,
    };
