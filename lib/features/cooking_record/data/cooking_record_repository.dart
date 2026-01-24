import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cooking_record/features/cooking_record/model/cooking_record.dart';
import 'package:cooking_record/features/cooking_record/data/database_helper.dart';

final cookingRecordRepositoryProvider = Provider<CookingRecordRepository>(
  (ref) => CookingRecordRepository(),
);

class CookingRecordRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<void> _cleanupOrphanedPhotos() async {
    final db = await dbHelper.database;
    final records = await db.query(DatabaseHelper.table);
    final validPhotoNames = records
        .map((r) => r[DatabaseHelper.columnPhotoPath] as String?)
        .where((path) => path != null)
        .toSet();

    final appDir = await getApplicationDocumentsDirectory();
    final files = appDir.listSync();
    for (final file in files) {
      if (file is File && file.path.endsWith('.jpg')) {
        final fileName = file.path.split('/').last;
        if (!validPhotoNames.contains(fileName)) {
          try {
            file.deleteSync();
            debugPrint('Deleted orphaned photo: ${file.path}');
          } catch (e) {
            debugPrint('Failed to delete orphaned photo: ${file.path}, error: $e');
          }
        }
      }
    }
  }

  Future<void> _resetDatabase() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbFile = File('${appDir.path}/cooking_record.db');
    if (await dbFile.exists()) {
      await dbFile.delete();
      debugPrint('Database reset completed');
    }
  }

  Future<List<CookingRecord>> getRecords() async {
    // Note: Cleanup is expensive and causes timeouts when saving. 
    // Only run it occasionally, not on every data fetch
    
    // await _cleanupOrphanedPhotos(); // Disabled for performance
    final db = await dbHelper.database;
    final records = await db.query(DatabaseHelper.table);
    final appDir = await getApplicationDocumentsDirectory();

    return records.map((record) {
      String? photoPath = record[DatabaseHelper.columnPhotoPath] as String?;
      String? fullPhotoPath;
      
      // 写真パスが存在する場合、ファイルの存在を確認
      if (photoPath != null) {
        // フルパスの場合は最後のファイル名部分だけを使用
        final fileName = photoPath.split('/').last;
        final file = File('${appDir.path}/$fileName');
        if (file.existsSync()) {
          fullPhotoPath = file.path;
        } else {
          debugPrint('Warning: Photo file not found: $fileName');
        }
      }

      // SQLiteのカラム名からJSONのキー名に変換
      return CookingRecord.fromJson({
        'id': record[DatabaseHelper.columnId] as String,
        'dishName': record[DatabaseHelper.columnDishName] as String,
        'memo': record[DatabaseHelper.columnMemo] as String?,
        'createdAt': DateTime.parse(record[DatabaseHelper.columnCreatedAt] as String).toIso8601String(),
        'photoPath': fullPhotoPath,
        'rating': record[DatabaseHelper.columnRating] as int? ?? 0,
        'referenceUrl': record[DatabaseHelper.columnReferenceUrl] as String?,
      });
    }).toList();
  }

  Future<void> addRecord(CookingRecord record) async {
    // Add debug log to track execution time
    final startTime = DateTime.now();
    debugPrint('REPOSITORY: Starting addRecord() at $startTime');

    try {
      final db = await dbHelper.database;
    String? relativePhotoPath;
    
    if (record.photoPath != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final sourceFile = File(record.photoPath!);
        
        // パスが Documents ディレクトリ内かどうかを確認
        if (sourceFile.path.startsWith(appDir.path)) {
          // Documents ディレクトリ内の場合はファイル名だけを保存
          relativePhotoPath = sourceFile.path.split('/').last;
          debugPrint('Using existing image at: ${sourceFile.path}');
        } else {
          // Documents ディレクトリ外の場合は新しい場所にコピー
          final fileName = '${const Uuid().v4()}.jpg';
          final savedImage = File('${appDir.path}/$fileName');
          if (await sourceFile.exists()) {
            await sourceFile.copy(savedImage.path);
            relativePhotoPath = fileName;
            debugPrint('Copied image to: ${savedImage.path}');
          } else {
            debugPrint('Source image file not found: ${record.photoPath}');
          }
        }
      } catch (e) {
        debugPrint('Error processing image: $e');
      }
    }

    await db.insert(
      DatabaseHelper.table,
      {
        DatabaseHelper.columnId: record.id,
        DatabaseHelper.columnDishName: record.dishName,
        DatabaseHelper.columnPhotoPath: relativePhotoPath,
        DatabaseHelper.columnMemo: record.memo,
        DatabaseHelper.columnCreatedAt: record.createdAt.toIso8601String(),
        DatabaseHelper.columnRating: record.rating,
        DatabaseHelper.columnReferenceUrl: record.referenceUrl,
      },
    );
    
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint('REPOSITORY: Completed addRecord() in ${duration.inMilliseconds}ms');
      
      // Force a notification that data has been saved
      // This ensures other code waiting for this completion gets notified
      debugPrint('REPOSITORY: ✅✅✅ RECORD SAVED SUCCESSFULLY ✅✅✅');
    } catch (e) {
      debugPrint('REPOSITORY: ❌❌❌ ERROR IN addRecord: $e ❌❌❌');
      rethrow;
    }
  }

  Future<void> updateRecord(CookingRecord record) async {
    final db = await dbHelper.database;
    String? relativePhotoPath;
    
    if (record.photoPath != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final sourceFile = File(record.photoPath!);
        
        // パスが Documents ディレクトリ内かどうかを確認
        if (sourceFile.path.startsWith(appDir.path)) {
          // Documents ディレクトリ内の場合はファイル名だけを保存
          relativePhotoPath = sourceFile.path.split('/').last;
          debugPrint('Using existing image at: ${sourceFile.path}');
        } else {
          // Documents ディレクトリ外の場合は新しい場所にコピー
          final fileName = '${const Uuid().v4()}.jpg';
          final savedImage = File('${appDir.path}/$fileName');
          if (await sourceFile.exists()) {
            await sourceFile.copy(savedImage.path);
            relativePhotoPath = fileName;
            debugPrint('Copied image to: ${savedImage.path}');
          } else {
            debugPrint('Source image file not found: ${record.photoPath}');
          }
        }
      } catch (e) {
        debugPrint('Error processing image: $e');
      }
    }

    await db.update(
      DatabaseHelper.table,
      {
        DatabaseHelper.columnDishName: record.dishName,
        DatabaseHelper.columnPhotoPath: relativePhotoPath,
        DatabaseHelper.columnMemo: record.memo,
        DatabaseHelper.columnRating: record.rating,
        DatabaseHelper.columnReferenceUrl: record.referenceUrl,
      },
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteRecord(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      DatabaseHelper.table,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
  }
  
  // Simple direct save method that bypasses some complexity
  // This is a simpler approach for debugging purposes
  Future<bool> saveRecordDirect(CookingRecord record) async {
    debugPrint('REPOSITORY: Starting directSave() for record ${record.id}');
    try {
      final db = await dbHelper.database;
      
      await db.insert(
        DatabaseHelper.table,
        {
          DatabaseHelper.columnId: record.id,
          DatabaseHelper.columnDishName: record.dishName,
          DatabaseHelper.columnMemo: record.memo,
          DatabaseHelper.columnCreatedAt: record.createdAt.toIso8601String(),
          DatabaseHelper.columnRating: record.rating,
          DatabaseHelper.columnReferenceUrl: record.referenceUrl,
        },
      );
      
      debugPrint('REPOSITORY: Direct save completed successfully');
      return true;
    } catch (e) {
      debugPrint('REPOSITORY: Direct save failed: $e');
      return false;
    }
  }
}
