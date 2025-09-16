// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vente _$VenteFromJson(Map<String, dynamic> json) => Vente(
  typeVenteId: json['typeVenteId'] as String,
  natureVenteId: json['natureVenteId'] as String,
  remiseId: json['remiseId'] as String?,
  saleId: json['saleId'] as String?,
  prevente: json['prevente'] as bool,
  clientId: json['clientId'] as String?,
  totalRecap: (json['totalRecap'] as num?)?.toInt(),
  item: AddVenteItem.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VenteToJson(Vente instance) => <String, dynamic>{
  'typeVenteId': instance.typeVenteId,
  'natureVenteId': instance.natureVenteId,
  'remiseId': instance.remiseId,
  'saleId': instance.saleId,
  'prevente': instance.prevente,
  'clientId': instance.clientId,
  'totalRecap': instance.totalRecap,
  'item': instance.item,
};
