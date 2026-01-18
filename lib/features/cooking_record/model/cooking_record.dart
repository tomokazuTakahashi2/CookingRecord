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
    @Default(0) int rating,  // 0: ★なし、1: ★、2: ★★、3: ★★★
    String? referenceUrl,
  }) = _CookingRecord;

  factory CookingRecord.fromJson(Map<String, dynamic> json) =>
      _$CookingRecordFromJson(json);
}
