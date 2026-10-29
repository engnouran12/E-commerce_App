import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/search_history_model.dart';

/// Local SQLite datasource that caches the user's product search queries.
class SearchHistoryLocalDatasource {
  static const _dbName = 'search_history.db';
  static const _dbVersion = 1;
  static const _tableName = 'search_history';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL UNIQUE,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_search_history_createdAt ON $_tableName(createdAt)
    ''');
  }

  Future<List<SearchHistoryEntry>> getHistory({int limit = 20}) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'createdAt DESC, id DESC',
      limit: limit,
    );
    return maps.map(SearchHistoryEntry.fromMap).toList();
  }

  /// Inserts [query] or moves an existing identical query to the top.
  Future<void> saveQuery(String query) async {
    final db = await database;
    await db.insert(_tableName, {
      'query': query,
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete(_tableName);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
