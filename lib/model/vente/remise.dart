import 'package:json_annotation/json_annotation.dart';
part 'remise.g.dart';
@JsonSerializable()
class Remise {
  final String id;
  final String? libelle;
  final String? code;
  final String? typeRemiseId;
  final String? typeLibelle;
  final double? taux;


  Remise({
    required this.id,
    this.libelle,
    this.code,
    this.typeRemiseId,
    this.typeLibelle,
    this.taux,
  });


  factory Remise.fromJson(Map<String, dynamic> json) => _$RemiseFromJson(json);
  Map<String, dynamic> toJson() => _$RemiseToJson(this);
}