import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product_rating_model.dart';
//commitnnn


/// Local SQLite datasource for product ratings.
class RatingsLocalDatasource {
  static const _dbName = 'ratings.db';
  static const _dbVersion = 1;
  static const _tableName = 'product_ratings';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT NOT NULL,
        date TEXT NOT NULL,
        reviewerName TEXT NOT NULL,
        reviewerEmail TEXT NOT NULL,
        photoPath TEXT
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_product_ratings_productId ON $_tableName(productId)
    ''');
  }

  Future<ProductRatingModel> insertRating(ProductRatingModel rating) async {
    final db = await database;
    final id = await db.insert(
      _tableName,
      rating.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return rating.copyWith(id: id);
  }

  Future<int> updateRating(ProductRatingModel rating) async {
    final db = await database;
    return db.update(
      _tableName,
      rating.toMap(),
      where: 'id = ?',
      whereArgs: [rating.id],
    );
  }

  Future<ProductRatingModel?> getRatingById(int id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ProductRatingModel.fromMap(maps.first);
  }

  Future<List<ProductRatingModel>> getRatingsForProduct(int productId) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map((m) => ProductRatingModel.fromMap(m)).toList();
  }

  Future<double> getAverageRatingForProduct(int productId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(rating) as avg FROM $_tableName WHERE productId = ?',
      [productId],
    );
    if (result.isEmpty) return 0.0;
    final avg = result.first['avg'];
    if (avg == null) return 0.0;
    if (avg is int) return avg.toDouble();
    if (avg is double) return avg;
    return double.tryParse(avg.toString()) ?? 0.0;
  }

  Future<int> getRatingCountForProduct(int productId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE productId = ?',
      [productId],
    );
    if (result.isEmpty) return 0;
    final count = result.first['count'];
    if (count is int) return count;
    return int.tryParse(count.toString()) ?? 0;
  }

  Future<void> deleteRating(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
