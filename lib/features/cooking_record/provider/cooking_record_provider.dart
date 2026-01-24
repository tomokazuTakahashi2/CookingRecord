import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cooking_record/features/cooking_record/data/cooking_record_repository.dart';
import 'package:cooking_record/features/cooking_record/model/cooking_record.dart';

final cookingRecordsProvider = AsyncNotifierProvider<CookingRecordsNotifier, List<CookingRecord>>(
  CookingRecordsNotifier.new
);

class CookingRecordsNotifier extends AsyncNotifier<List<CookingRecord>> {
  // Use getter instead of field to avoid build() issues
  CookingRecordRepository get _repo => ref.read(cookingRecordRepositoryProvider);

  @override
  Future<List<CookingRecord>> build() async {
    return _repo.getRecords();
  }


  Future<bool> addRecord(CookingRecord record) async {
    final current = state.valueOrNull ?? <CookingRecord>[];
    
    // UIはすぐ更新（体感速度UP）- AsyncData keeps existing state, doesn't trigger loading
    state = AsyncData([record, ...current]);
    
    debugPrint('PROVIDER: Starting addRecord() - local state already updated');
    
    // DB保存（ここが失敗したら巻き戻す）
    try {
      await _repo.addRecord(record);
      debugPrint('PROVIDER: Record saved to DB successfully');
      return true;
    } catch (e, st) {
      debugPrint('PROVIDER: Error saving record: $e');
      // エラー時は元に戻す
      state = AsyncData(current);
      // エラーを再スロー
      throw AsyncError(e, st);
    }
  }

  Future<void> deleteRecord(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteRecord(id);
      return _repo.getRecords();
    });
  }

  Future<bool> updateRecord(CookingRecord record) async {
    // Don't set loading state when updating - prevents router from reacting
    try {
      await _repo.updateRecord(record);
      // Only update state after success
      final records = await _repo.getRecords();
      state = AsyncData(records);
      return true;
    } catch (e, st) {
      debugPrint('PROVIDER: Error updating record: $e');
      state = AsyncError(e, st);
      throw AsyncError(e, st);
    }
  }

  Future<List<CookingRecord>> getRecords() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _repo.getRecords();
    });
    return state.valueOrNull ?? [];
  }
}
