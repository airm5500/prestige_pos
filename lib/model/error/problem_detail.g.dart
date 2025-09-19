// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProblemDetail _$ProblemDetailFromJson(Map<String, dynamic> json) =>
    ProblemDetail(
      title: json['title'] as String,
      status: (json['status'] as num).toInt(),
      detail: json['detail'] as String?,
      instance: json['instance'] as String?,
      errorKey: json['errorKey'] as String?,
      errorValue: json['errorValue'] as String?,
    );

Map<String, dynamic> _$ProblemDetailToJson(ProblemDetail instance) =>
    <String, dynamic>{
      'title': instance.title,
      'status': instance.status,
      'detail': instance.detail,
      'instance': instance.instance,
      'errorKey': instance.errorKey,
      'errorValue': instance.errorValue,
    };
