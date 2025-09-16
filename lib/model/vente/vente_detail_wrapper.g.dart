// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vente_detail_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenteDetailWrapper _$VenteDetailWrapperFromJson(Map<String, dynamic> json) =>
    VenteDetailWrapper(
      total: (json['total'] as num).toInt(),
      content: (json['content'] as List<dynamic>)
          .map((e) => VenteDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VenteDetailWrapperToJson(VenteDetailWrapper instance) =>
    <String, dynamic>{'total': instance.total, 'content': instance.content};
