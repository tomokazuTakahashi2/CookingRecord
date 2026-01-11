import 'package:freezed_annotation/freezed_annotation.dart';

part 'cooking_record.freezed.dart';
part 'cooking_record.g.dart';

@freezed
class CookingRecord with _$CookingRecord {
  const factory CookingRecord({
    required String id,
    required String dishName,
    String? memo,
    required DateTime createdAt,
    String? photoPath,
  }) = _CookingRecord;

  factory CookingRecord.fromJson(Map<String, dynamic> json) =>
      _$CookingRecordFromJson(json);
}
