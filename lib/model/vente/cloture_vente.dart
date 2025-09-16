import 'package:json_annotation/json_annotation.dart';
import 'package:prestige_pos/model/vente/banque_info.dart';
import 'package:prestige_pos/model/vente/create_response.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/model/vente/payment.dart';

part 'cloture_vente.g.dart';

@JsonSerializable()
class ClotureVente {
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

  ClotureVente({
    required this.venteId,
    required this.montantRecu,
    required this.typeRegleId,
    this.remiseId,
    this.userVendeurId,
    this.commentaire,
    this.clientId,
    this.banque = '',
    this.lieux = '',
    this.nom = '',
    this.montantRemis = 0,
    this.totalRecap,
    this.montantPaye,
    this.data,
  });

  factory ClotureVente.fromJson(Map<String, dynamic> json) =>
      _$ClotureVenteFromJson(json);

  Map<String, dynamic> toJson() => _$ClotureVenteToJson(this);

  factory ClotureVente.newClotureVente(
    CreateResponse vente,
    String modeId,
    BanqueInfo? banqueInfo,
  ) {
    return ClotureVente(
      venteId: vente.saleId,
      montantRecu: vente.amount,
      typeRegleId: modeId,
      banque: '',
      lieux: '',
      nom: banqueInfo?.nom,
      montantPaye: vente.amount,
    );
  }
}
