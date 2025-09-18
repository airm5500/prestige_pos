// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vente_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenteDetail _$VenteDetailFromJson(Map<String, dynamic> json) => VenteDetail(
  id: json['id'] as String,
  saleId: json['saleId'] as String,
  produitId: json['produitId'] as String,
  produitName: json['produitName'] as String,
  unitPrice: (json['unitPrice'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  quantiySold: (json['quantiySold'] as num).toInt(),
  amount: (json['amount'] as num).toInt(),
  produitCip: json['produitCip'] as String?,
  produitEan: json['produitEan'] as String?,
  discount: (json['discount'] as num?)?.toInt(),
  deconditionne: json['deconditionne'] as bool?,
);

Map<String, dynamic> _$VenteDetailToJson(VenteDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'produitId': instance.produitId,
      'produitName': instance.produitName,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'quantiySold': instance.quantiySold,
      'amount': instance.amount,
      'produitCip': instance.produitCip,
      'produitEan': instance.produitEan,
      'discount': instance.discount,
      'deconditionne': instance.deconditionne,
    };
