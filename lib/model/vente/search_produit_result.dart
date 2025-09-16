import 'package:json_annotation/json_annotation.dart';

part 'search_produit_result.g.dart';

@JsonSerializable()
class SearchProduitResult {
  final String id;
  final String libelle;
  final String codeCip;
  final String? name;
  final String? rayonLibelle;
  final String? parentId;
  final int regularUnitPrice;
  final int quantity;
  final int? itemQty;

  SearchProduitResult({
    required this.id,
    required this.libelle,
    required this.codeCip,
    this.name,
    this.rayonLibelle,
    this.parentId,
    required this.regularUnitPrice,
    required this.quantity,
    this.itemQty,
  });

  factory SearchProduitResult.fromJson(Map<String, dynamic> json) =>
      _$SearchProduitResultFromJson(json);

  Map<String, dynamic> toJson() => _$SearchProduitResultToJson(this);
}
