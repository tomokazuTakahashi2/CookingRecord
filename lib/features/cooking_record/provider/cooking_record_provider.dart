import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cooking_record/features/cooking_record/data/cooking_record_repository.dart';
import 'package:cooking_record/features/cooking_record/model/cooking_record.dart';

final cookingRecordsProvider = AsyncNotifierProvider<CookingRecordsNotifier, List<CookingRecord>>(() {
  return CookingRecordsNotifier();
});

class CookingRecordsNotifier extends AsyncNotifier<List<CookingRecord>> {
  late final CookingRecordRepository _repository;

  @override
  Future<List<CookingRecord>> build() async {
    _repository = ref.watch(cookingRecordRepositoryProvider);
    return _repository.getRecords();
  }

  Future<void> addRecord(CookingRecord record) async {
    // いま表示しているリストを保持（nullなら空）
    final current = state.value ?? <CookingRecord>[];
    
    // UIはすぐ更新（体感速度UP）
    state = AsyncValue.data([record, ...current]);
    
    debugPrint('PROVIDER: Starting addRecord() - local state already updated');
    
    // DB保存（ここが失敗したら巻き戻す）
    try {
      await _repository.addRecord(record);
      debugPrint('PROVIDER: Record saved to DB successfully');
    } catch (e, st) {
      debugPrint('PROVIDER: Error saving record: $e');
      // エラー時は元に戻す
      state = AsyncValue.data(current);
      // エラーを再スロー
      rethrow;
    }
  }

  Future<void> deleteRecord(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteRecord(id);
      return _repository.getRecords();
    });
  }

  Future<void> updateRecord(CookingRecord record) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateRecord(record);
      return _repository.getRecords();
    });
  }

  Future<List<CookingRecord>> getRecords() async {
    return _repository.getRecords();
  }
}
