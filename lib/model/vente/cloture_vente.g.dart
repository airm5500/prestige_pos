// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloture_vente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClotureVente _$ClotureVenteFromJson(Map<String, dynamic> json) => ClotureVente(
  venteId: json['venteId'] as String,
  montantRecu: (json['montantRecu'] as num).toInt(),
  typeRegleId: json['typeRegleId'] as String,
  remiseId: json['remiseId'] as String?,
  userVendeurId: json['userVendeurId'] as String?,
  typeVenteId: json['typeVenteId'] as String?,
  commentaire: json['commentaire'] as String?,
  clientId: json['clientId'] as String?,
  banque: json['banque'] as String? ?? '',
  lieux: json['lieux'] as String? ?? '',
  nom: json['nom'] as String? ?? '',
  montantRemis: (json['montantRemis'] as num?)?.toInt() ?? 0,
  totalRecap: (json['totalRecap'] as num?)?.toInt(),
  montantPaye: (json['montantPaye'] as num?)?.toInt(),
  data: json['data'] == null
      ? null
      : Payment.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ClotureVenteToJson(ClotureVente instance) =>
    <String, dynamic>{
      'venteId': instance.venteId,
      'montantRecu': instance.montantRecu,
      'typeRegleId': instance.typeRegleId,
      'remiseId': instance.remiseId,
      'userVendeurId': instance.userVendeurId,
      'typeVenteId': instance.typeVenteId,
      'commentaire': instance.commentaire,
      'clientId': instance.clientId,
      'banque': instance.banque,
      'lieux': instance.lieux,
      'nom': instance.nom,
      'montantRemis': instance.montantRemis,
      'totalRecap': instance.totalRecap,
      'montantPaye': instance.montantPaye,
      'data': instance.data,
    };
