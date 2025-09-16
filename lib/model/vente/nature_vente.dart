import 'package:json_annotation/json_annotation.dart';
part 'nature_vente.g.dart';
@JsonSerializable()
class NatureVente {
  final String id;
  final String libelle;

  NatureVente({required this.id, required this.libelle});
  factory NatureVente.fromJson(Map<String, dynamic> json) => _$NatureVenteFromJson(json);
  Map<String, dynamic> toJson() => _$NatureVenteToJson(this);
}