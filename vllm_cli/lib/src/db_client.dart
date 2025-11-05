import 'dart:io';

import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';

class DbClient {
  late final Database _database;

  DbClient({String? path}) {
    final dbPath = path ?? join(Directory.current.path, 'vllm_cli.db');
    _database = sqlite3.open(dbPath);
    _initDB();
  }

  // Test-only constructor
  DbClient.forTest(this._database) {
    _initDB();
  }

  void _initDB() {
    _database.execute('''
      CREATE TABLE IF NOT EXISTS groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        community_id TEXT NOT NULL UNIQUE,
        screen_name TEXT NOT NULL,
        name TEXT,
        about TEXT,
        since_timestamp INTEGER NOT NULL
      )
    ''');
  }

  void initializeGroup(
    String communityId,
    String screenName,
    String name,
    String about,
    int sinceTimestamp,
  ) {
    final stmt = _database.prepare(
      'INSERT OR IGNORE INTO groups (community_id, screen_name, name, about, since_timestamp) VALUES (?, ?, ?, ?, ?)',
    );
    stmt.execute([communityId, screenName, name, about, sinceTimestamp]);
    stmt.dispose();
  }

  List<Map<String, dynamic>> getAllGroups() {
    final ResultSet resultSet = _database.select('SELECT * FROM groups');
    return resultSet
        .map(
          (row) => {
            'id': row['id'],
            'community_id': row['community_id'],
            'screen_name': row['screen_name'],
            'name': row['name'],
            'about': row['about'],
            'since_timestamp': row['since_timestamp'],
          },
        )
        .toList();
  }

  void updateGroupTimestamp(int id, int newTimestamp) {
    final stmt = _database.prepare(
      'UPDATE groups SET since_timestamp = ? WHERE id = ?',
    );
    stmt.execute([newTimestamp, id]);
    stmt.dispose();
  }

  void close() {
    _database.dispose();
  }
}
