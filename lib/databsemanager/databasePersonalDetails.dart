import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PersonalDetails {
  String? name;
  String? profession;
  String? ageRange;
  int? id;
  int? isUserLoggedIn;

  PersonalDetails(this.name, this.ageRange, this.profession, this.isUserLoggedIn);
  PersonalDetails.withId(this.id, this.name, this.ageRange, this.profession);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ageRange': ageRange,
      'profession': profession,
      'isUserLoggedIn': isUserLoggedIn
    };
  }

  static PersonalDetails? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    } else {
      return PersonalDetails.withId(
        map['id'] as int,
        map['name'] as String,
        map['ageRange'] as String,
        map['profession'] as String,
      );
    }
  }
}

class DatabasePersonalDetails {
  static final DatabasePersonalDetails _instance = DatabasePersonalDetails._internal();
  static Database? _database;

  factory DatabasePersonalDetails() {
    return _instance;
  }

  DatabasePersonalDetails._internal();

  static const _databaseName = 'personal_details.db';
  static const _databaseVersion = 1;
  static const _table = 'personal_details';

  Future<void> initializeDatabase() async {
    final path = await getDatabasesPath();
    String dbPath = join(path, _databaseName);
    _database = await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        ageRange TEXT,
        profession TEXT,
        isUserLoggedIn INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> addPersonalDetails(PersonalDetails personalDetails) async {
    await _database?.insert(_table, personalDetails.toMap());
  }

  Future<PersonalDetails?> getPersonalDetails() async {
    final List<Map<String, dynamic>>? maps = await (_database?.query(_table));
    if (maps == null || maps.isEmpty) {
      return null;
    } else {
      return PersonalDetails.fromMap(maps.first);
    }
  }

  Future<void> updatePersonalDetails(PersonalDetails personalDetails) async {
    await _database?.update(_table, personalDetails.toMap(),
        where: 'id = ?', whereArgs: [personalDetails.id]);
  }

  Future<void> deletePersonalDetails(int id) async {
    await _database?.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllPersonalDetails() async {
    await _database?.delete(_table);
  }
}
