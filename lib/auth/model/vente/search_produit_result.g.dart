// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_produit_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchProduitResult _$SearchProduitResultFromJson(Map<String, dynamic> json) =>
    SearchProduitResult(
      id: json['id'] as String,
      libelle: json['libelle'] as String,
      codeCip: json['codeCip'] as String,
      name: json['name'] as String?,
      rayonLibelle: json['rayonLibelle'] as String?,
      parentId: json['parentId'] as String?,
      regularUnitPrice: (json['regularUnitPrice'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      itemQty: (json['itemQty'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SearchProduitResultToJson(
  SearchProduitResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'libelle': instance.libelle,
  'codeCip': instance.codeCip,
  'name': instance.name,
  'rayonLibelle': instance.rayonLibelle,
  'parentId': instance.parentId,
  'regularUnitPrice': instance.regularUnitPrice,
  'quantity': instance.quantity,
  'itemQty': instance.itemQty,
};
