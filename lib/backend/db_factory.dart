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
          "channel_id" varchar(50),
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
          await tx.execute('''
            CREATE TABLE "favorites" (
              "id" INTEGER PRIMARY KEY,
              "stalker_id" varchar(50),
              "name" varchar(100),
              "cmd" varchar(200),
              "image" varchar(200),
              "media_type" INTEGER,
              "source_id" INTEGER,
              FOREIGN KEY (source_id) REFERENCES sources(id) ON DELETE CASCADE
            );
          ''');
          await tx.execute('''
            CREATE UNIQUE INDEX index_favorites_unique ON favorites(stalker_id, source_id);
          ''');
          await tx.execute('''
            CREATE TABLE "history" (
              "id" INTEGER PRIMARY KEY,
              "stalker_id" varchar(50),
              "name" varchar(100),
              "cmd" varchar(200),
              "image" varchar(200),
              "media_type" INTEGER,
              "source_id" integer,
              "last_watched" integer,
              FOREIGN KEY (source_id) REFERENCES sources(id) ON DELETE CASCADE
            );
          ''');
          await tx.execute('''
            CREATE UNIQUE INDEX index_history_stalker ON history(stalker_id, source_id);
          ''');
          await tx.execute('''
            CREATE INDEX index_history_last_watched ON history(last_watched);
          ''');
          await tx.execute('''
            CREATE INDEX index_history_name ON history(name);
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
