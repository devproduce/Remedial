import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TimeSlot {
  final int? id;
  final int dayIndex;
  final DateTime fromTime;
  final DateTime toTime;

  TimeSlot({this.id, required this.dayIndex, required this.fromTime, required this.toTime});

  Map<String, dynamic> toMap() {
    return {
      'dayIndex': dayIndex,
      'fromTime': fromTime.toIso8601String(),
      'toTime': toTime.toIso8601String(),
    };
  }

  static TimeSlot fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      dayIndex: map['dayIndex'],
      fromTime: DateTime.parse(map['fromTime']),
      toTime: DateTime.parse(map['toTime']),
    );
  }
}

class TimeSlotDatabaseHelper {
  static final TimeSlotDatabaseHelper _instance = TimeSlotDatabaseHelper._internal();
  static Database? _database;

  factory TimeSlotDatabaseHelper() {
    return _instance;
  }

  TimeSlotDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'timeslot_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE timeslots (
        dayIndex INTEGER NOT NULL,
        fromTime TEXT NOT NULL,
        toTime TEXT NOT NULL,
        PRIMARY KEY (dayIndex, fromTime)
      )
    ''');
  }

  Future<int> insertTimeSlot(TimeSlot timeSlot) async {
    Database db = await database;
    return await db.insert(
      'timeslots',
      timeSlot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TimeSlot>> getTimeSlots() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('timeslots');

    return List.generate(maps.length, (i) {
      return TimeSlot.fromMap(maps[i]);
    });
  }

  Future<int> updateTimeSlot(TimeSlot timeSlot, int dayIndex, DateTime from) async {
    Database db = await database;
    return await db.update(
      'timeslots',
      timeSlot.toMap(),
      where: 'dayIndex = ? AND fromTime = ?',
      whereArgs: [dayIndex, from.toIso8601String()],
    );
  }

  Future<int> deleteTimeSlot(int dayIndex, DateTime fromTime) async {
    Database db = await database;
    return await db.delete(
      'timeslots',
      where: 'dayIndex = ? AND fromTime = ?',
      whereArgs: [dayIndex, fromTime.toIso8601String()],
    );
  }

  Future<void> deleteAllTimeSlots() async {
    Database db = await database;
    await db.delete('timeslots');
  }

  Future<List<TimeSlot>> getSortedTimeSlots() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'timeslots',
      orderBy: 'fromTime ASC',
    );

    return List.generate(maps.length, (i) {
      return TimeSlot.fromMap(maps[i]);
    });
  }
}
