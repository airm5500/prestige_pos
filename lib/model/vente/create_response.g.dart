// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateResponse _$CreateResponseFromJson(Map<String, dynamic> json) =>
    CreateResponse(
      saleId: json['saleId'] as String,
      transactionNumber: json['transactionNumber'] as String?,
      amount: (json['amount'] as num).toInt(),
      discount: (json['discount'] as num?)?.toInt(),
      items: VenteDetailWrapper.fromJson(json['items'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateResponseToJson(CreateResponse instance) =>
    <String, dynamic>{
      'saleId': instance.saleId,
      'transactionNumber': instance.transactionNumber,
      'amount': instance.amount,
      'discount': instance.discount,
      'items': instance.items,
    };
