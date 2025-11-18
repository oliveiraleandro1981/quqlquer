import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Log {
  final int? id;
  final String status;
  final int startTime;
  final int endTime;

  Log({this.id, required this.status, required this.startTime, required this.endTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'driving_log.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status TEXT,
        startTime INTEGER,
        endTime INTEGER
      )
    ''');
  }

  Future<void> addLog(Log log) async {
    final db = await database;
    await db.insert(
      'logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Log>> getLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('logs');
    return List.generate(maps.length, (i) {
      return Log(
        id: maps[i]['id'],
        status: maps[i]['status'],
        startTime: maps[i]['startTime'],
        endTime: maps[i]['endTime'],
      );
    });
  }

  Future<List<Log>> getDailyLogs(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
    final List<Map<String, dynamic>> maps = await db.query(
      'logs',
      where: 'startTime >= ? AND startTime <= ?',
      whereArgs: [startOfDay, endOfDay],
    );
    return List.generate(maps.length, (i) {
      return Log(
        id: maps[i]['id'],
        status: maps[i]['status'],
        startTime: maps[i]['startTime'],
        endTime: maps[i]['endTime'],
      );
    });
  }

  Future<List<Log>> getWeeklyLogs(DateTime date) async {
    final db = await database;
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final startTimestamp = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).millisecondsSinceEpoch;
    final endTimestamp = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59).millisecondsSinceEpoch;
    final List<Map<String, dynamic>> maps = await db.query(
      'logs',
      where: 'startTime >= ? AND startTime <= ?',
      whereArgs: [startTimestamp, endTimestamp],
    );
    return List.generate(maps.length, (i) {
      return Log(
        id: maps[i]['id'],
        status: maps[i]['status'],
        startTime: maps[i]['startTime'],
        endTime: maps[i]['endTime'],
      );
    });
  }
}
