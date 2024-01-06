import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  factory DatabaseHelper() => _instance;
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();

  final _log = Logger('FollowedUsers');

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // TODO: This hard-coded database name should be managed through a configuration option
    _database = await openDatabase(
      join(await getDatabasesPath(), 'data.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE followed_users (id TEXT PRIMARY KEY)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          _log.warning('Performing migration of followed_users table: $oldVersion to $newVersion');
          // Migrate from an integer ID to String ID for user IDs
          db.execute('CREATE TABLE followed_users_NEW (id TEXT PRIMARY KEY)');
          db.execute('INSERT INTO followed_users_NEW SELECT * FROM followed_users');
          db.execute('DROP TABLE followed_users');
          db.execute('ALTER TABLE followed_users_NEW RENAME TO followed_users');
        }
      },
      version: 2,
    );
    return _database!;
  }
}
