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
      userName: json['userName'] as String?,
      heure: json['heure'] as String?,
      transactionDate: json['transactionDate'] as String?,
      remiseId: json['remiseId'] as String?,
      saleRef: json['saleRef'] as String?,
      discount: (json['discount'] as num?)?.toInt(),
      montantNet: (json['montantNet'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'PROGRESS',
    );

Map<String, dynamic> _$CreateResponseToJson(CreateResponse instance) =>
    <String, dynamic>{
      'saleId': instance.saleId,
      'amount': instance.amount,
      'items': instance.items,
      'transactionNumber': instance.transactionNumber,
      'discount': instance.discount,
      'montantNet': instance.montantNet,
      'userName': instance.userName,
      'heure': instance.heure,
      'transactionDate': instance.transactionDate,
      'remiseId': instance.remiseId,
      'saleRef': instance.saleRef,
      'status': instance.status,
    };
