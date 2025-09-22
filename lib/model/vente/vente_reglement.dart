import 'package:json_annotation/json_annotation.dart';

part 'vente_reglement.g.dart';

@JsonSerializable()
class VenteReglement {
  final String? typeReglement;
  final int montant;
  final int? montantAttentu;
  final String typeReglementId;

  VenteReglement({
    this.typeReglement,
    required this.montant,
    this.montantAttentu,
    required this.typeReglementId,
  });

  factory VenteReglement.fromJson(Map<String, dynamic> json) =>
      _$VenteReglementFromJson(json);

  Map<String, dynamic> toJson() => _$VenteReglementToJson(this);

  factory VenteReglement.newVenteReglement(String modeId, int amount) {
    return VenteReglement(
      montant: amount,
      typeReglementId: modeId,
      montantAttentu: amount,
      typeReglement: modeId,
    );
  }
}
