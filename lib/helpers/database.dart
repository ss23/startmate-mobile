import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // TODO: This hard-coded database name should be managed through a configuration option
    _database = await openDatabase(
      join(await getDatabasesPath(), 'data.db'),
      onCreate: (db, version) {
        // TODO: Create tables and define the schema
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // TODO: Implement this
      },
      version: 1,
    );
    return _database!;
  }
}
