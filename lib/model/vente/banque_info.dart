import 'package:json_annotation/json_annotation.dart';

part 'banque_info.g.dart';

@JsonSerializable()
class BanqueInfo {
  final String nom;
  final String? banque;

  BanqueInfo({required this.nom, this.banque});

  factory BanqueInfo.fromJson(Map<String, dynamic> json) =>
      _$BanqueInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BanqueInfoToJson(this);
}
