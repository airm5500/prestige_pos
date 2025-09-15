import 'package:json_annotation/json_annotation.dart';
import 'package:prestige_pos/auth/model/vente/payment.dart';
part 'cloutre_vente.g.dart';
@JsonSerializable()
class CloutreVente {
  final String venteId;
  final int montantRecu;

  final String typeRegleId;
  final String? remiseId;
  final String? userVendeurId;
  final String? commentaire;
  final String? clientId;
  final String? banque;

  final String? lieux;

  final String? nom;

  final int? montantRemis;

  final int? totalRecap;

  final int? montantPaye;
  final Payment? data;

  CloutreVente({
    required this.venteId,
    required this.montantRecu,
    required this.typeRegleId,
    this.remiseId,
    this.userVendeurId,
    this.commentaire,
    this.clientId,
    this.banque='',
    this.lieux='',
    this.nom='',
    this.montantRemis=0,
    this.totalRecap,
    this.montantPaye,
    this.data,
  });
  factory CloutreVente.fromJson(Map<String, dynamic> json) =>
      _$CloutreVenteFromJson(json);
  Map<String, dynamic> toJson() => _$CloutreVenteToJson(this);
}
