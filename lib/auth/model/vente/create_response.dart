import 'package:json_annotation/json_annotation.dart';

import 'package:prestige_pos/auth/model/vente/vente_detail_wrapper.dart';

part 'create_response.g.dart';

@JsonSerializable()
class CreateResponse {
  final String saleId;
  final String? transactionNumber;
  final int amount;
  final int? discount;
  final VenteDetailWrapper items;

  CreateResponse({
    required this.saleId,
    this.transactionNumber,
    required this.amount,
    this.discount,
    required this.items,
  });

  factory CreateResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateResponseToJson(this);
}
