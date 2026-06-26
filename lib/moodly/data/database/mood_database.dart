import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/mood_entry.dart';

class MoodDatabase {
  MoodDatabase._();

  static final MoodDatabase instance = MoodDatabase._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'moodly.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mood_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        moodLevel INTEGER NOT NULL,
        note TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertMoodEntry(MoodEntry entry) async {
    final db = await database;
    return db.insert(
      'mood_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MoodEntry>> getMoodEntries() async {
    final db = await database;
    final rows = await db.query('mood_entries', orderBy: 'date DESC');
    return rows.map((row) => MoodEntry.fromMap(row)).toList();
  }

  Future<List<MoodEntry>> getEntriesForWeek(DateTime date) async {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final db = await database;
    final rows = await db.query(
      'mood_entries',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [monday.toIso8601String(), sunday.toIso8601String()],
      orderBy: 'date ASC',
    );
    return rows.map((row) => MoodEntry.fromMap(row)).toList();
  }
}
