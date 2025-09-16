import 'package:json_annotation/json_annotation.dart';
part 'vente_detail.g.dart';
@JsonSerializable()
class VenteDetail {
  final String id;
  final String saleId;
  final String? transactionNumber;
  final String produitId;
  final String produitName;
  final String? produitCip;
  final String? produitEan;
  final String? transactionDate;
  final int unitPrice;
  final int quantity;
  final int quantiySold;
  final int amount;
  final int? discount;
  final String? dateHeure;
  final int? quantityAvoir;
  final int? uniteGratuite;
  final bool? avoir;
  final DateTime? mvtDate;
  final bool? deconditionne;

  VenteDetail({
    required this.id,
    required this.saleId,
    this.transactionNumber,
    required this.produitId,
    required this.produitName,
    this.produitCip,
    this.produitEan,
    this.transactionDate,
    required this.unitPrice,
    required this.quantity,
    required this.quantiySold,
    required this.amount,
    this.discount,
    this.dateHeure,
    this.quantityAvoir,
    this.uniteGratuite,
    this.avoir,
    this.mvtDate,
    this.deconditionne,
  });

  factory VenteDetail.fromJson(Map<String, dynamic> json) =>
      _$VenteDetailFromJson(json);
  Map<String, dynamic> toJson() => _$VenteDetailToJson(this);
}
