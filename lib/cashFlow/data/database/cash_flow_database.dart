import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/expense.dart';
import '../models/expense_share.dart';
import '../models/participant.dart';

class CashFlowDatabase {
  CashFlowDatabase._();

  static final CashFlowDatabase instance = CashFlowDatabase._();

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
    final path = join(await getDatabasesPath(), 'cash_flow.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE participants(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        payerId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(payerId) REFERENCES participants(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE expense_shares(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expenseId INTEGER NOT NULL,
        participantId INTEGER NOT NULL,
        shareAmount REAL NOT NULL,
        paid INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(expenseId) REFERENCES expenses(id),
        FOREIGN KEY(participantId) REFERENCES participants(id)
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE expense_shares
        ADD COLUMN paid INTEGER NOT NULL DEFAULT 0
      ''');
    }
  }

  Future<int> insertParticipant(Participant participant) async {
    final db = await database;
    return db.insert('participants', participant.toMap());
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return db.insert('expenses', expense.toMap());
  }

  Future<int> insertExpenseShare(ExpenseShare share) async {
    final db = await database;
    return db.insert('expense_shares', share.toMap());
  }

  Future<int> updateExpenseSharePaid(int id, bool paid) async {
    final db = await database;
    return db.update(
      'expense_shares',
      {'paid': paid ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Participant>> getParticipants() async {
    final db = await database;
    final rows = await db.query('participants', orderBy: 'name ASC');
    return rows.map((row) => Participant.fromMap(row)).toList();
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final rows = await db.query('expenses', orderBy: 'createdAt DESC');
    return rows.map((row) => Expense.fromMap(row)).toList();
  }

  Future<List<ExpenseShare>> getExpenseShares() async {
    final db = await database;
    final rows = await db.query('expense_shares');
    return rows.map((row) => ExpenseShare.fromMap(row)).toList();
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('expense_shares');
    await db.delete('expenses');
    await db.delete('participants');
  }
}
