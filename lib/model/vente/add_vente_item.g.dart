// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_vente_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddVenteItem _$AddVenteItemFromJson(Map<String, dynamic> json) => AddVenteItem(
  produitId: json['produitId'] as String,
  saleId: json['saleId'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  quantitySold: (json['quantitySold'] as num).toInt(),
  freeQuantity: (json['freeQuantity'] as num?)?.toInt(),
  unitPrice: (json['unitPrice'] as num?)?.toInt(),
  id: json['id'] as String?,
);

Map<String, dynamic> _$AddVenteItemToJson(AddVenteItem instance) =>
    <String, dynamic>{
      'produitId': instance.produitId,
      'saleId': instance.saleId,
      'quantity': instance.quantity,
      'quantitySold': instance.quantitySold,
      'freeQuantity': instance.freeQuantity,
      'unitPrice': instance.unitPrice,
      'id': instance.id,
    };
