

import 'package:json_annotation/json_annotation.dart';
part 'payment.g.dart';
@JsonSerializable()
class Payment {
  final int remise ;
  final int marge ;
  final int montantTva ;
  final int montantNet ;
  final int montant ;
  final int montantTp ;
  final int montantAccount;
  final int montantNetUg ;
  final int montantTtcUg ;
  final int margeUg ;

  Payment({
    required this.remise,
    required this.marge,
    required this.montantTva,
    required this.montantNet,
    required this.montant,
    required this.montantTp,
    required this.montantAccount,
    required this.montantNetUg,
    required this.montantTtcUg,
    required this.margeUg,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

}