import 'package:json_annotation/json_annotation.dart';

part 'fetch_item_params.g.dart';

@JsonSerializable()
class FetchItemParams {
  final String saleId;
  final String? searchTerm;
  final int? start;
  final int? limit;

  FetchItemParams({
    required this.saleId,
    this.searchTerm,
    this.start = 0,
    this.limit = 1000,
  });

  factory FetchItemParams.fromJson(Map<String, dynamic> json) =>
      _$FetchItemParamsFromJson(json);

  Map<String, dynamic> toJson() => _$FetchItemParamsToJson(this);
}
