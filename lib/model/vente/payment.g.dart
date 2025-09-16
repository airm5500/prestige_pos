// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  remise: (json['remise'] as num).toInt(),
  marge: (json['marge'] as num).toInt(),
  montantTva: (json['montantTva'] as num).toInt(),
  montantNet: (json['montantNet'] as num).toInt(),
  montant: (json['montant'] as num).toInt(),
  montantTp: (json['montantTp'] as num).toInt(),
  montantAccount: (json['montantAccount'] as num).toInt(),
  montantNetUg: (json['montantNetUg'] as num).toInt(),
  montantTtcUg: (json['montantTtcUg'] as num).toInt(),
  margeUg: (json['margeUg'] as num).toInt(),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'remise': instance.remise,
  'marge': instance.marge,
  'montantTva': instance.montantTva,
  'montantNet': instance.montantNet,
  'montant': instance.montant,
  'montantTp': instance.montantTp,
  'montantAccount': instance.montantAccount,
  'montantNetUg': instance.montantNetUg,
  'montantTtcUg': instance.montantTtcUg,
  'margeUg': instance.margeUg,
};
