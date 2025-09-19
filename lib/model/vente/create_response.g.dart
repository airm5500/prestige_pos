// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateResponse _$CreateResponseFromJson(Map<String, dynamic> json) =>
    CreateResponse(
      saleId: json['saleId'] as String,
      amount: (json['amount'] as num).toInt(),
      items: VenteDetailWrapper.fromJson(json['items'] as Map<String, dynamic>),
      transactionNumber: json['transactionNumber'] as String?,
      discount: (json['discount'] as num?)?.toInt(),
      montantNet: (json['montantNet'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateResponseToJson(CreateResponse instance) =>
    <String, dynamic>{
      'saleId': instance.saleId,
      'amount': instance.amount,
      'items': instance.items,
      'transactionNumber': instance.transactionNumber,
      'discount': instance.discount,
      'montantNet': instance.montantNet,
    };
