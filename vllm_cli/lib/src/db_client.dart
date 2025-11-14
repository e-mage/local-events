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
    _database.execute('''
      CREATE TABLE IF NOT EXISTS events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        post_id INTEGER NOT NULL,
        post_timestamp INTEGER NOT NULL,
        name TEXT,
        title TEXT,
        type TEXT,
        location TEXT,
        date TEXT,
        time TEXT,
        price TEXT,
        tickets TEXT,
        organizer TEXT
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

  void addEvent(
    int groupId,
    int postId,
    int postTimestamp,
    String? name,
    String? title,
    String? type,
    String? location,
    String? date,
    String? time,
    String? price,
    String? tickets,
    String? organizer
  ) {
    final stmt = _database.prepare(
      'INSERT OR IGNORE INTO events (group_id, post_id, post_timestamp, name, title, type, location, date, time, price, tickets, organizer) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    );
    stmt.execute([groupId, postId, postTimestamp, name, title, type, location, date, time, price, tickets, organizer]);
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

  List<Map<String, dynamic>> getAllEvents() {
    final ResultSet resultSet = _database.select('SELECT * FROM events');
    return resultSet
        .map(
          (row) => {
            'id': row['id'],
            'group_id': row['group_id'],
            'post_id': row['post_id'],
            'post_timestamp': row['post_timestamp'],
            'name': row['name'],
            'title': row['title'],
            'type': row['type'],
            'location': row['location'],
            'date': row['date'],
            'time': row['time'],
            'price': row['price'],
            'tickets': row['tickets'],
            'organizer': row['organizer'],
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

  void updateEvent(int id, int newGroupId, int newPostId, int newPostTimestamp) {
    final stmt = _database.prepare(
      'UPDATE events SET group_id = ?, post_id = ?, post_timestamp = ? WHERE id = ?',
    );
    stmt.execute([newGroupId, newPostId, newPostTimestamp, id]);
    stmt.dispose();
  }

  void deleteEvent(int id) {
    final stmt = _database.prepare(
      'DELETE events WHERE id = ?'
    );
    stmt.execute([id]);
    stmt.dispose();
  }

  void close() {
    _database.dispose();
  }
}
