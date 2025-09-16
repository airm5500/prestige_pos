import 'package:json_annotation/json_annotation.dart';
part 'remise.g.dart';
@JsonSerializable()
class Remise {
  final String? id;
  final String libelle;
  final String code;
  final String typeRemiseId;
  final String typeLibelle;
  final double taux;

  Remise({
    this.id,
    required this.libelle,
    required this.code,
    required this.typeRemiseId,
    required this.typeLibelle,
    required this.taux,
  });
  factory Remise.fromJson(Map<String, dynamic> json) => _$RemiseFromJson(json);
  Map<String, dynamic> toJson() => _$RemiseToJson(this);
}