import 'dart:collection';

import 'package:fredstalker/backend/db_factory.dart';
import 'package:fredstalker/models/channel.dart';
import 'package:fredstalker/models/source.dart';
import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

const int pageSize = 36;

class Sql {
  static commitWrite(
    List<Future<void> Function(SqliteWriteContext, Map<String, String>)>
    commits,
  ) async {
    var db = await DbFactory.db;
    Map<String, String> memory = {};
    await db.writeTransaction((tx) async {
      for (var commit in commits) {
        await commit(tx, memory);
      }
    });
  }

  static Future<void> Function(SqliteWriteContext, Map<String, String>)
  addSource(Source source) {
    return (SqliteWriteContext tx, Map<String, String> memory) async {
      await tx.execute(
        '''
            INSERT INTO sources (name, url, mac) VALUES (?, ?, ?);
          ''',
        [source.name, source.url, source.mac],
      );
      memory['sourceId'] = (await tx.get(
        "SELECT last_insert_rowid();",
      )).columnAt(0).toString();
    };
  }

  static Future<bool> sourceNameExists(String? name) async {
    var db = await DbFactory.db;
    var result = await db.getOptional(
      '''
      SELECT 1
      FROM sources
      WHERE name = ?
    ''',
      [name],
    );
    return result?.columnAt(0) == 1;
  }

  static Future<List<Source>> getSources() async {
    var db = await DbFactory.db;
    var results = await db.getAll('''
      SELECT *
      FROM sources
    ''');
    return results.map(rowToSource).toList();
  }

  static Source rowToSource(Row row) {
    return Source(
      id: row.columnAt(0),
      name: row.columnAt(1),
      url: row.columnAt(2),
      mac: row.columnAt(3),
    );
  }

  static Future<bool> hasSources() async {
    var db = await DbFactory.db;
    var result = await db.getOptional('''
      SELECT 1
      FROM sources
      LIMIT 1
    ''');
    return result?.columnAt(0) == 1;
  }

  static Future<HashMap<String, String>> getSettings() async {
    var db = await DbFactory.db;
    var results = await db.getAll('''SELECT key, value FROM Settings''');
    return HashMap.fromEntries(
      results.map((f) => MapEntry(f.columnAt(0), f.columnAt(1))),
    );
  }

  static Future<void> updateSettings(HashMap<String, String> settings) async {
    var db = await DbFactory.db;
    await db.writeTransaction((tx) async {
      for (var entry in settings.entries) {
        await tx.execute(
          '''
        INSERT INTO Settings (key, value)
        VALUES (?, ?)
        ON CONFLICT(key) DO UPDATE SET value = ?''',
          [entry.key, entry.value, entry.value],
        );
      }
    });
  }

  static deleteSource(int sourceId) async {
    var db = await DbFactory.db;
    await db.writeTransaction((tx) async {
      await tx.execute("DELETE FROM sources WHERE id = ?", [sourceId]);
    });
  }

  static updateSource(Source source) async {
    var db = await DbFactory.db;
    await db.execute(
      '''
      UPDATE sources
      SET url = ?, mac = ?
      WHERE id = ?
    ''',
      [source.url, source.mac, source.id],
    );
  }

  static Future<Source> getSourceFromId(int id) async {
    var db = await DbFactory.db;
    var result = await db.get('''SELECT * FROM sources WHERE id = ?''', [id]);
    return rowToSource(result);
  }

  static Future setPosition(int channelId, int seconds) async {
    var db = await DbFactory.db;
    await db.execute(
      '''
      INSERT INTO movie_positions (channel_id, position)
      VALUES (?, ?)
      ON CONFLICT (channel_id)
      DO UPDATE SET
      position = excluded.position;
    ''',
      [channelId, seconds],
    );
  }

  static Future<int?> getPosition(int channelId) async {
    var db = await DbFactory.db;
    var result = await db.getOptional(
      '''
      SELECT position FROM movie_positions
      WHERE channel_id = ?
    ''',
      [channelId],
    );
    return result?.columnAt(0);
  }

  static Future<void> addToHistory(int id) async {
    var db = await DbFactory.db;
    await db.execute(
      '''
      UPDATE channels
      SET last_watched = strftime('%s', 'now')
      WHERE id = ?
    ''',
      [id],
    );
    await db.execute('''
      UPDATE channels
      SET last_watched = NULL
      WHERE last_watched IS NOT NULL
		  AND id NOT IN (
				SELECT id
				FROM channels
				WHERE last_watched IS NOT NULL
				ORDER BY last_watched DESC
				LIMIT 36
		  )
    ''');
  }

  static Future<void> addFavorite(Channel channel, int sourceId) async {
    var db = await DbFactory.db;
    await db.execute(
      '''
      INSERT INTO favorites (name, cmd, image, stalker_id, source_id)
      VALUES (?, ?, ? ,?, ?);
    ''',
      [channel.name, channel.cmd, channel.image, channel.id, sourceId],
    );
  }

  static Future<LinkedHashMap<String, Channel>> getAllFavs(int sourceId) async {
    final db = await DbFactory.db;
    final results = await db.getAll(
      '''
      SELECT name, cmd, image, stalker_id
      FROM favorites
      WHERE source_id = ?
    ''',
      [sourceId],
    );
    return LinkedHashMap.fromEntries(
      results.map(rowToChannel).map((x) => MapEntry(x.id!, x)),
    );
  }

  static Future<(List<Channel>, int)> searchFavs(
    String? query,
    int sourceId,
    int page,
    int pageSize,
  ) async {
    final db = await DbFactory.db;
    final results = await db.getAll(
      '''
      SELECT name, cmd, image, stalker_id
      FROM favorites
      WHERE source_id = ?
      AND name like ?
      LIMIT ?, ?
    ''',
      [sourceId, "%$query%", (page - 1) * pageSize, pageSize],
    );
    final int count = (await db.get(
      '''
    SELECT COUNT(*)
    FROM favorites
    WHERE source_id = ?
    AND name LIKE ?
    ''',
      [sourceId, "%$query%"],
    )).columnAt(0);
    return (results.map(rowToChannel).toList(), count);
  }

  static Channel rowToChannel(Row row) {
    return Channel(
      name: row.columnAt(0),
      cmd: row.columnAt(1),
      image: row.columnAt(2),
      id: row.columnAt(3),
    );
  }
}
