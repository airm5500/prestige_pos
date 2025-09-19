import 'package:json_annotation/json_annotation.dart';


import 'package:prestige_pos/model/vente/vente_detail_wrapper.dart';

part 'create_response.g.dart';

@JsonSerializable()
class CreateResponse {
  final String saleId;
  final int amount;
  final VenteDetailWrapper items;
  final String? transactionNumber;
  final int? discount;
  final int? montantNet;


  CreateResponse({
    required this.saleId,
    required this.amount,
    required this.items,
    this.transactionNumber,
    this.discount,
    this.montantNet,
  });

  factory CreateResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateResponseToJson(this);
}
