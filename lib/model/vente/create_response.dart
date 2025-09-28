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
  final String? userName;
  final String? heure;
  final String? transactionDate;
  final String? remiseId;
  final String? saleRef;
  String status;

  CreateResponse({
    required this.saleId,
    required this.amount,
    required this.items,
    this.transactionNumber,
    this.userName,
    this.heure,
    this.transactionDate,
    this.remiseId,
    this.saleRef,
    this.discount,
    this.montantNet,
    this.status = 'PROGRESS',
  });

  bool get isCompleted => status == 'CLOSED';

  bool get isInProgress => status == 'PROGRESS';

  factory CreateResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateResponseToJson(this);
}
