// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vente _$VenteFromJson(Map<String, dynamic> json) => Vente(
  typeVenteId: json['typeVenteId'] as String,
  natureVenteId: json['natureVenteId'] as String,
  remiseId: json['remiseId'] as String?,
  userVendeurId: json['userVendeurId'] as String?,
  bonRef: json['bonRef'] as String?,
  saleId: json['saleId'] as String?,
  remiseDepot: (json['remiseDepot'] as num?)?.toInt(),
  prevente: json['prevente'] as bool,
  clientId: json['clientId'] as String?,
  montantTp: (json['montantTp'] as num?)?.toInt(),
  totalRecap: (json['totalRecap'] as num?)?.toInt(),
  emplacementId: json['emplacementId'] as String?,
  item: AddVenteItem.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VenteToJson(Vente instance) => <String, dynamic>{
  'typeVenteId': instance.typeVenteId,
  'natureVenteId': instance.natureVenteId,
  'remiseId': instance.remiseId,
  'userVendeurId': instance.userVendeurId,
  'bonRef': instance.bonRef,
  'saleId': instance.saleId,
  'remiseDepot': instance.remiseDepot,
  'prevente': instance.prevente,
  'clientId': instance.clientId,
  'montantTp': instance.montantTp,
  'totalRecap': instance.totalRecap,
  'emplacementId': instance.emplacementId,
  'item': instance.item,
};
