import 'package:json_annotation/json_annotation.dart';

part 'add_remise.g.dart';

@JsonSerializable()
class AddRemise {
  final String saleId;
  final String id;

  AddRemise({required this.saleId, required this.id});

  factory AddRemise.fromJson(Map<String, dynamic> json) =>
      _$AddRemiseFromJson(json);

  Map<String, dynamic> toJson() => _$AddRemiseToJson(this);

  factory AddRemise.newAddRemise(String saleId, String id) {
    return AddRemise(saleId: saleId, id: id);
  }
}
