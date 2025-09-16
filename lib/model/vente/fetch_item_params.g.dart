// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_item_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FetchItemParams _$FetchItemParamsFromJson(Map<String, dynamic> json) =>
    FetchItemParams(
      saleId: json['saleId'] as String,
      searchTerm: json['searchTerm'] as String?,
      start: (json['start'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 1000,
    );

Map<String, dynamic> _$FetchItemParamsToJson(FetchItemParams instance) =>
    <String, dynamic>{
      'saleId': instance.saleId,
      'searchTerm': instance.searchTerm,
      'start': instance.start,
      'limit': instance.limit,
    };
