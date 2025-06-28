import 'package:fredstalker/backend/utils.dart';
import 'package:sqlite_async/sqlite_async.dart';

class DbFactory {
  static SqliteDatabase? _db;

  static Future<SqliteDatabase> _createDB() async {
    var db = SqliteDatabase(path: "${await Utils.appDir}/db.sqlite");
    var migrations = SqliteMigrations()
      ..add(
        SqliteMigration(1, (tx) async {
          await tx.execute('''
        CREATE TABLE "sources" (
          "id"          INTEGER PRIMARY KEY,
          "name"        varchar(100),
          "url"         varchar(500),
          "mac"         varchar(100)
        );
        ''');
          //@TODO: Probably not going to work unless we match IDs
          await tx.execute('''
        CREATE TABLE "movie_positions" (
          "id" INTEGER PRIMARY KEY,
          "channel_id" integer,
          "source_id" integer,
          "position" int,
          FOREIGN KEY (source_id) REFERENCES sources(id) ON DELETE CASCADE
        )
        ''');
          await tx.execute('''
        CREATE TABLE "settings" (
          "key" VARCHAR(50) PRIMARY KEY,
          "value" VARCHAR(100)
        );
        ''');
          await tx.execute(
            '''CREATE UNIQUE INDEX index_source_name ON sources(name);''',
          );
          await tx.execute('''
          CREATE UNIQUE INDEX index_movie_positions_channel_id ON movie_positions(channel_id, source_id);
        ''');
        }),
      )
      ..add(
        SqliteMigration(2, (tx) async {
          await tx.execute('''
            CREATE TABLE "favorites" (
              "id" INTEGER PRIMARY KEY,
              "name" varchar(100),
              "cmd" varchar(200),
              "image" varchar(200)
            );
          ''');
        }),
      );
    await migrations.migrate(db);
    return db;
  }

  static Future<SqliteDatabase> get db async {
    _db ??= await _createDB();
    return _db!;
  }
}
