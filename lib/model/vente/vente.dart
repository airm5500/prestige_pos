import 'package:json_annotation/json_annotation.dart';
import 'package:prestige_pos/model/vente/add_vente_item.dart';

part 'vente.g.dart';
@JsonSerializable()
class Vente {
  final String typeVenteId;
  final String natureVenteId;
  final String? remiseId;
  final String? userVendeurId;
  final String? bonRef;
  final String? saleId;
  final int? remiseDepot;
  final bool prevente;
  final String? clientId;
  final int? montantTp;
  final int? totalRecap;
  final String? emplacementId;
  final AddVenteItem item;

  Vente({
    required this.typeVenteId,
    required this.natureVenteId,
    this.remiseId,
    this.userVendeurId,
    this.bonRef,
    this.saleId,
    this.remiseDepot,
    required this.prevente,
    this.clientId,
    this.montantTp,
    this.totalRecap,
    this.emplacementId,
    required this.item,
  });

  factory Vente.fromJson(Map<String, dynamic> json) => _$VenteFromJson(json);
  Map<String, dynamic> toJson() => _$VenteToJson(this);
}
