import 'package:json_annotation/json_annotation.dart';
import 'package:prestige_pos/model/vente/search_produit_result.dart';
import 'package:prestige_pos/model/vente/vente_detail.dart';

part 'add_vente_item.g.dart';

@JsonSerializable()
class AddVenteItem {
  final String produitId;
  final String? saleId;
  final int quantity;
  final int quantitySold;
  final int? freeQuantity;
  final int? unitPrice;
  final String? id;

  AddVenteItem({
    required this.produitId,
    this.saleId,
    required this.quantity,
    required this.quantitySold,
    this.freeQuantity,
    this.unitPrice,
    this.id,
  });

  factory AddVenteItem.fromVenteDetail(VenteDetail detail, String? saleId) {
    return AddVenteItem(
      produitId: detail.produitId,
      saleId: saleId,
      quantity: detail.quantity,
      quantitySold: detail.quantiySold,
      unitPrice: detail.unitPrice,
      id: detail.id,
    );
  }

  factory AddVenteItem.produit(
    SearchProduitResult selected,
    int quantity,
    String? saleId,
  ) {
    return AddVenteItem(
      produitId: selected.id,
      saleId: saleId,
      quantity: quantity,
      quantitySold: quantity,
      unitPrice: selected.regularUnitPrice,
    );
  }

  factory AddVenteItem.fromJson(Map<String, dynamic> json) =>
      _$AddVenteItemFromJson(json);

  Map<String, dynamic> toJson() => _$AddVenteItemToJson(this);
}
