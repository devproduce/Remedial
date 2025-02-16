import 'dart:async';
import 'package:first_flutter/core/utils/modal_class_task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'task_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        priority INTEGER NOT NULL,
        timeForTask TEXT NOT NULL,
        amountOfTime TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTask(TaskModalClass task) async {
    Database db = await database;
    return await db.insert(
      'tasks',
      task.taskToMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TaskModalClass>> getTasks() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return TaskModalClass.withId(
        maps[i]['id'],
        maps[i]['title'],
        maps[i]['description'],
        maps[i]['priority'],
        maps[i]['timeForTask'],
        maps[i]['amountOfTime'],
      );
    });
  }

  Future<int> updateTask(TaskModalClass task) async {
    Database db = await database;
    return await db.update(
      'tasks',
      task.taskToMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllTasks() async {
    Database db = await database;
    await db.delete('tasks');
  }


   Future<List<TaskModalClass>> getSortedTask() async {

    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
    'tasks',
    orderBy: 'timeForTask DESC', 
  );

    return List.generate(maps.length, (i) {
      return TaskModalClass.withId(
        maps[i]['id'],
        maps[i]['title'],
        maps[i]['description'],
        maps[i]['priority'],
        maps[i]['timeForTask'],
        maps[i]['amountOfTime'],
      );
    });


  

   }
}
