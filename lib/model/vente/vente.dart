import 'package:json_annotation/json_annotation.dart';
import 'package:prestige_pos/model/vente/add_vente_item.dart';
import 'package:prestige_pos/model/vente/search_produit_result.dart';

part 'vente.g.dart';

@JsonSerializable()
class Vente {
  final String typeVenteId;
  final String natureVenteId;
  final String? remiseId;
  final String? saleId;
  final bool prevente;
  final String? clientId;
  final int? totalRecap;
  final AddVenteItem item;

  Vente({
    required this.typeVenteId,
    required this.natureVenteId,
    this.remiseId,
    this.saleId,
    required this.prevente,
    this.clientId,
    this.totalRecap,
    required this.item,
  });

  factory Vente.fromJson(Map<String, dynamic> json) => _$VenteFromJson(json);

  Map<String, dynamic> toJson() => _$VenteToJson(this);

  factory Vente.newVente(AddVenteItem item, bool isPrevente) {
    return Vente(
      typeVenteId: '1',
      natureVenteId: '1',
      prevente: isPrevente,
      item: item,
    );
  }
}
