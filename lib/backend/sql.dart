import 'dart:collection';

import 'package:fredstalker/backend/db_factory.dart';
import 'package:fredstalker/models/channel.dart';
import 'package:fredstalker/models/filters.dart';
import 'package:fredstalker/models/media_type.dart';
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

  static Future setPosition(String channelId, int sourceId, int seconds) async {
    var db = await DbFactory.db;
    await db.execute(
      '''
      INSERT INTO movie_positions (channel_id, position, source_id)
      VALUES (?, ?, ?)
      ON CONFLICT (channel_id, source_id)
      DO UPDATE SET
      position = excluded.position;
    ''',
      [channelId, seconds, sourceId],
    );
  }

  static Future<int?> getPosition(String channelId, int sourceId) async {
    var db = await DbFactory.db;
    var result = await db.getOptional(
      '''
      SELECT position FROM movie_positions
      WHERE channel_id = ?
        AND source_id = ?
    ''',
      [channelId, sourceId],
    );
    return result?.columnAt(0);
  }

  static Future<void> addFavorite(Channel channel, int sourceId) async {
    var db = await DbFactory.db;
    await db.execute(
      '''
      INSERT INTO favorites (name, cmd, image, stalker_id, media_type, source_id, episode_num)
      VALUES (?, ?, ? ,?, ?, ?);
    ''',
      [
        channel.name,
        channel.cmd,
        channel.image,
        channel.id,
        channel.mediaType.index,
        sourceId,
        channel.episodeNum,
      ],
    );
  }

  static Future<void> removeFavorite(String id, int sourceId) async {
    var db = await DbFactory.db;
    await db.execute(
      '''
      DELETE FROM favorites
      WHERE stalker_id = ? 
        AND source_id = ?;
    ''',
      [id, sourceId],
    );
  }

  static Future<LinkedHashMap<String, Channel>> getAllFavs(int sourceId) async {
    final db = await DbFactory.db;
    final results = await db.getAll(
      '''
      SELECT name, cmd, image, stalker_id, media_type, episode_num
      FROM favorites
      WHERE source_id = ?
    ''',
      [sourceId],
    );
    return LinkedHashMap.fromEntries(
      results.map(rowToChannel).map((x) => MapEntry(x.id!, x)),
    );
  }

  static Channel rowToChannel(Row row) {
    return Channel(
      name: row.columnAt(0),
      cmd: row.columnAt(1),
      image: row.columnAt(2),
      id: row.columnAt(3),
      mediaType: MediaType.values[row.columnAt(4)],
      episodeNum: row.columnAt(5),
    );
  }

  static Future<void> addToHistory(Channel channel, int sourceId) async {
    var db = await DbFactory.db;
    await db.execute(
      '''
      INSERT INTO history (stalker_id, name, cmd, image, media_type, source_id, episode_num, last_watched)
      VALUES (?, ?, ?, ?, ?, ?, ?, strftime('%s', 'now'))
      ON CONFLICT (stalker_id, source_id)
      DO UPDATE SET
      last_watched = excluded.last_watched;
    ''',
      [
        channel.id,
        channel.name,
        channel.cmd,
        channel.image,
        channel.mediaType.index,
        sourceId,
        channel.episodeNum,
      ],
    );
    await db.execute('''
      DELETE FROM history
		  WHERE id NOT IN (
				SELECT id 
				FROM history
				ORDER BY last_watched DESC
				LIMIT 28
		  )
    ''');
  }

  static Future<(List<Channel>, int rowCount)> getHistory(
    String? query,
    int sourceId,
  ) async {
    var db = await DbFactory.db;
    final results = await db.getAll(
      '''
      SELECT name, cmd, image, stalker_id, media_type, episode_num
      FROM history
      WHERE source_id = ?
      AND name like ?
      ORDER BY last_watched DESC
    ''',
      [sourceId, query != null ? "%$query%" : "%"],
    );
    final int count = (await db.get(
      '''
      SELECT count(*)
      FROM history
      WHERE source_id = ?
      AND name like ?
      ORDER BY last_watched DESC
    ''',
      [sourceId, query != null ? "%$query%" : "%"],
    )).columnAt(0);
    return (results.map(rowToChannel).toList(), count);
  }
}
