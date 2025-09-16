import 'package:json_annotation/json_annotation.dart';
part 'mode_reglement.g.dart';
@JsonSerializable()
class ModeReglement {
  final String id;
  final String libelle;
  final  int  order;

  ModeReglement({
    required this.id,
    required this.libelle,
    required this.order,
  });

  factory ModeReglement.fromJson(Map<String, dynamic> json) => _$ModeReglementFromJson(json);
  Map<String, dynamic> toJson() => _$ModeReglementToJson(this);
}