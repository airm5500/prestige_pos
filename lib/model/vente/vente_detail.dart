import 'package:json_annotation/json_annotation.dart';

part 'vente_detail.g.dart';

@JsonSerializable()
class VenteDetail {
  final String id;
  final String saleId;
  final String produitId;
  final String produitName;
  final int unitPrice;
  final int quantity;
  final int quantiySold;
  final int amount;
  final String? produitCip;
  final String? produitEan;
  final int? discount;
  final bool? deconditionne;

  VenteDetail({
    required this.id,
    required this.saleId,
    required this.produitId,
    required this.produitName,
    required this.unitPrice,
    required this.quantity,
    required this.quantiySold,
    required this.amount,
    this.produitCip,
    this.produitEan,
    this.discount,
    this.deconditionne,
  });

  factory VenteDetail.fromJson(Map<String, dynamic> json) =>
      _$VenteDetailFromJson(json);

  Map<String, dynamic> toJson() => _$VenteDetailToJson(this);
}
