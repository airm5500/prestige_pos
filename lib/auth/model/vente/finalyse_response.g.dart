// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finalyse_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinalyseResponse _$FinalyseResponseFromJson(Map<String, dynamic> json) =>
    FinalyseResponse(
      id: json['id'] as String,
      success: json['success'] as bool,
      message: json['message'] as String?,
      codeError: (json['codeError'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FinalyseResponseToJson(FinalyseResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'success': instance.success,
      'message': instance.message,
      'codeError': instance.codeError,
    };
