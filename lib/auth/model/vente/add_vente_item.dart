import 'package:json_annotation/json_annotation.dart';

part 'add_vente_item.g.dart';

@JsonSerializable()
class AddVenteItem {
  final String produitId;
  final String? saleId;
  final int quantity;
  final int quantitySold;
  final int freeQuantity;
  final int unitPrice;
  final String? id;

  AddVenteItem({
    required this.produitId,
    this.saleId,
    required this.quantity,
    required this.quantitySold,
    required this.freeQuantity,
    required this.unitPrice,
    this.id,
  });
  factory AddVenteItem.fromJson(Map<String, dynamic> json) =>
      _$AddVenteItemFromJson(json);
  Map<String, dynamic> toJson() => _$AddVenteItemToJson(this);
}
