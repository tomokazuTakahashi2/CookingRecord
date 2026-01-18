import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class DatabaseHelper {
  static const _databaseName = "cooking_record.db";
  static const _databaseVersion = 3;

  static const table = 'cooking_records';

  static const columnId = 'id';
  static const columnDishName = 'dish_name';
  static const columnPhotoPath = 'photo_path';
  static const columnMemo = 'memo';
  static const columnCreatedAt = 'created_at';
  static const columnRating = 'rating';
  static const columnReferenceUrl = 'reference_url';

  // シングルトンクラスにする
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // データベースを開く。存在しない場合は作成する
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // データベースが作成されたときに呼ばれる
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnDishName TEXT NOT NULL,
        $columnPhotoPath TEXT,
        $columnMemo TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnRating INTEGER NOT NULL DEFAULT 0,
        $columnReferenceUrl TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $table ADD COLUMN $columnRating INTEGER NOT NULL DEFAULT 0
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE $table ADD COLUMN $columnReferenceUrl TEXT
      ''');
    }
  }
}
