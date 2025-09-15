import 'package:json_annotation/json_annotation.dart';
import 'package:prestige_pos/auth/model/vente/vente_detail.dart';

part 'vente_detail_wrapper.g.dart';
@JsonSerializable()
class VenteDetailWrapper {
  final int total;
  final List<VenteDetail> content;

  VenteDetailWrapper({required this.total, required this.content});
  factory VenteDetailWrapper.fromJson(Map<String, dynamic> json) => _$VenteDetailWrapperFromJson(json);
  Map<String, dynamic> toJson() => _$VenteDetailWrapperToJson(this);

}