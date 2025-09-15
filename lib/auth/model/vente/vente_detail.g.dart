// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vente_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenteDetail _$VenteDetailFromJson(Map<String, dynamic> json) => VenteDetail(
  id: json['id'] as String,
  saleId: json['saleId'] as String,
  transactionNumber: json['transactionNumber'] as String?,
  produitId: json['produitId'] as String,
  produitName: json['produitName'] as String,
  produitCip: json['produitCip'] as String?,
  produitEan: json['produitEan'] as String?,
  transactionDate: json['transactionDate'] as String?,
  unitPrice: (json['unitPrice'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  quantiySold: (json['quantiySold'] as num).toInt(),
  amount: (json['amount'] as num).toInt(),
  discount: (json['discount'] as num?)?.toInt(),
  dateHeure: json['dateHeure'] as String?,
  quantityAvoir: (json['quantityAvoir'] as num?)?.toInt(),
  uniteGratuite: (json['uniteGratuite'] as num?)?.toInt(),
  avoir: json['avoir'] as bool?,
  mvtDate: json['mvtDate'] == null
      ? null
      : DateTime.parse(json['mvtDate'] as String),
  deconditionne: json['deconditionne'] as bool?,
);

Map<String, dynamic> _$VenteDetailToJson(VenteDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'transactionNumber': instance.transactionNumber,
      'produitId': instance.produitId,
      'produitName': instance.produitName,
      'produitCip': instance.produitCip,
      'produitEan': instance.produitEan,
      'transactionDate': instance.transactionDate,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'quantiySold': instance.quantiySold,
      'amount': instance.amount,
      'discount': instance.discount,
      'dateHeure': instance.dateHeure,
      'quantityAvoir': instance.quantityAvoir,
      'uniteGratuite': instance.uniteGratuite,
      'avoir': instance.avoir,
      'mvtDate': instance.mvtDate?.toIso8601String(),
      'deconditionne': instance.deconditionne,
    };
