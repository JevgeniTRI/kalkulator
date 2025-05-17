import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/calculation_history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calculator_history.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expression TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future<void> insertHistory(CalculationHistory history) async {
    final db = await database;
    await db.insert('history', history.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CalculationHistory>> getHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('history', orderBy: 'id DESC');
    return maps.map((e) => CalculationHistory.fromMap(e)).toList();
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('history');
  }
}
