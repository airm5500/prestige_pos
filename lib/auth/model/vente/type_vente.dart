import 'package:json_annotation/json_annotation.dart';

part 'type_vente.g.dart';

@JsonSerializable()
class TypeVente {
  final String id;
  final String libelle;

  TypeVente({required this.id, required this.libelle});

  factory TypeVente.fromJson(Map<String, dynamic> json) =>
      _$TypeVenteFromJson(json);

  Map<String, dynamic> toJson() => _$TypeVenteToJson(this);
}
