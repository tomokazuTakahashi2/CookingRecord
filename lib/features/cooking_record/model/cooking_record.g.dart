// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CookingRecordImpl _$$CookingRecordImplFromJson(Map<String, dynamic> json) =>
    _$CookingRecordImpl(
      id: json['id'] as String,
      dishName: json['dishName'] as String,
      memo: json['memo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      photoPath: json['photoPath'] as String?,
    );

Map<String, dynamic> _$$CookingRecordImplToJson(_$CookingRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dishName': instance.dishName,
      'memo': instance.memo,
      'createdAt': instance.createdAt.toIso8601String(),
      'photoPath': instance.photoPath,
    };
