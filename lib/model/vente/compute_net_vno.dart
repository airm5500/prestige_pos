import 'package:json_annotation/json_annotation.dart';

part 'compute_net_vno.g.dart';

@JsonSerializable()
class ComputeNetVno {
  final String saleId;
  final String? remiseId;

  ComputeNetVno({required this.saleId, this.remiseId});

  factory ComputeNetVno.fromJson(Map<String, dynamic> json) =>
      _$ComputeNetVnoFromJson(json);

  Map<String, dynamic> toJson() => _$ComputeNetVnoToJson(this);
}
