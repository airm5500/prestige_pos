import 'package:json_annotation/json_annotation.dart';

part 'finalyse_response.g.dart';

@JsonSerializable()
class FinalyseResponse {
  final String id;
  final bool success;
  final String? message;
  final int? codeError;

  FinalyseResponse({
    required this.id,
    required this.success,
    this.message,
    this.codeError,
  });

  factory FinalyseResponse.fromJson(Map<String, dynamic> json) =>
      _$FinalyseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FinalyseResponseToJson(this);
}
