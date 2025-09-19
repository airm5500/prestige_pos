import 'package:json_annotation/json_annotation.dart';
part 'problem_detail.g.dart';
@JsonSerializable()
class ProblemDetail {
  final String title;
  final int status;
  final String? detail;
  final String? instance;
  final String? errorKey;
  final String? errorValue;

  ProblemDetail({
    required this.title,
    required this.status,
    this.detail,
    this.instance,
    this.errorKey,
    this.errorValue,
  });

  factory ProblemDetail.fromJson(Map<String, dynamic> json) =>
      _$ProblemDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemDetailToJson(this);
}
