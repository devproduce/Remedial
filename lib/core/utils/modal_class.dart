import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqlite_api.dart';

class FreeSlotsModalClass {
  int? id;
  int? numberOfFreeSlots;
  int? day;
  String? fromTime;
  String? toTime;

  FreeSlotsModalClass.withId(
      this.id, this.day, this.numberOfFreeSlots, this.fromTime, this.toTime);

  FreeSlotsModalClass(
      this.day, this.numberOfFreeSlots, this.fromTime, this.toTime);

  int? get idGet => id;

  set toTimeGet(String? toTime) {
    if (fromTime == toTime) {
      throw InvalidSlotException('From Time and TO Time cannot be equal');
    }
    this.toTime = toTime;
  }

  Map<String, dynamic> freeTimeSlotsToMap() {
    return {
      'day': day ?? 0, // Default value if day is null
      'numberOfFreeSlots': numberOfFreeSlots ?? 0, // Default value if null
      'fromTime': fromTime ?? '', // Empty string if null
      'toTime': toTime ?? '', // Empty string if null
    };
  }

  void mapToslots(Map<String, dynamic> dbMap) {
    id = dbMap['id'];
    day = dbMap['day'];
    numberOfFreeSlots = dbMap['numberOfFreeSlots'];
    fromTime = dbMap['fromTime'];
    toTime = dbMap['toTime'];
  }
}


class InvalidSlotException implements Exception {
  String message;
  InvalidSlotException(this.message);
  @override
  String toString() {
    return 'InvalidSlotException: $message';
  }
}

class DatabaseService {
  static final _instance = DatabaseService._internal();
  static Database? _database;

  final _databaseName = 'FreeTimeSlots';
  final _databaseIdName = 'id';
  final _dayColumnName = 'day';
  final _numberOfFreeSlotsColumnName = 'numberOfFreeSlots';
  final _fromTimeColumnName = 'fromTime';
  final _toTimeColumnName = 'toTime';

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_databaseName (
          $_databaseIdName INTEGER PRIMARY KEY,
          $_dayColumnName INTEGER,
          $_numberOfFreeSlotsColumnName INTEGER,
          $_fromTimeColumnName TEXT,
          $_toTimeColumnName TEXT
        )
        ''');
      },
    );

    return _database!;
  }

  Future<int> addTimeSlot(FreeSlotsModalClass timeslot) async {
    Database db = await getDatabase();
    return await db.insert(
      _databaseName,
      timeslot.freeTimeSlotsToMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTimeSlot(FreeSlotsModalClass timeslot) async {
    Database db = await getDatabase();
    return await db.update(
      _databaseName,
      timeslot.freeTimeSlotsToMap(),
      where: '$_databaseIdName = ?',
      whereArgs: [timeslot.id],
    );
  }

  Future<int> deleteTimeSlot(int id) async {
    Database db = await getDatabase();
    return await db.delete(
      _databaseName,
      where: '$_databaseIdName = ?',
      whereArgs: [id],
    );
  }

  Future<List<FreeSlotsModalClass>> getTimeSlots() async {
    Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(_databaseName);

    return List.generate(maps.length, (i) {
      return FreeSlotsModalClass.withId(
        maps[i][_databaseIdName],
        maps[i][_dayColumnName] ?? 0,
        maps[i][_numberOfFreeSlotsColumnName] ?? 0,
        maps[i][_fromTimeColumnName] ?? '',
        maps[i][_toTimeColumnName] ?? '',
      );
    });
  }

  Future<List<FreeSlotsModalClass>> getTimeSlotsForDay(int dayIndex) async {
    Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      _databaseName,
      where: '$_dayColumnName = ?',
      whereArgs: [dayIndex],
    );

    return maps.map((map) {
      return FreeSlotsModalClass.withId(
        map[_databaseIdName],
        map[_dayColumnName] ?? 0,
        map[_numberOfFreeSlotsColumnName] ?? 0,
        map[_fromTimeColumnName] ?? '',
        map[_toTimeColumnName] ?? '',
      );
    }).toList();
  }


  Future<void> deleteAllTimeSlots() async {
    Database db = await _database!;
    await db.delete(_databaseName);
  }
}
