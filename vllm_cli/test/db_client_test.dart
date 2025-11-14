import 'dart:ffi';

import 'package:sqlite3/open.dart';
import 'package:test/test.dart';
import 'package:vllm_cli/src/db_client.dart';

void main() {
  open.overrideFor(OperatingSystem.linux, () {
    return DynamicLibrary.open('/usr/lib/x86_64-linux-gnu/libsqlite3.so.0');
  });

  group('DbClient', () {
    late DbClient dbClient;

    setUp(() {
      // Use an in-memory database for testing
      dbClient = DbClient(path: ':memory:');
    });

    tearDown(() {
      dbClient.close();
    });

    test('should initialize the database and create the groups table', () {
      // The table is created in the constructor, so we just need to check if it exists.
      final groups = dbClient.getAllGroups();
      expect(groups, isEmpty);
    });

    test('should insert a new group', () async {
      dbClient.initializeGroup('-123', 'test_group', 'Test Group', 'About Test', 1672531200);
      final groups = dbClient.getAllGroups();
      expect(groups.length, 1);
      expect(groups.first['community_id'], '-123');
    });

    test('should ignore duplicate groups', () async {
      dbClient.initializeGroup('-123', 'test_group', 'Test Group', 'About Test', 1672531200);
      dbClient.initializeGroup(
        '-123',
        'test_group',
        'Test Group 2',
        'About Test 2',
        1672531201,
      );
      final groups = dbClient.getAllGroups();
      expect(groups.length, 1);
      expect(groups.first['name'], 'Test Group');
    });

    test('should get all groups', () async {
      dbClient.initializeGroup('-1', 'g1', 'G1', 'A1', 1);
      dbClient.initializeGroup('-2', 'g2', 'G2', 'A2', 2);
      final groups = dbClient.getAllGroups();
      expect(groups.length, 2);
    });

    test('should update a group timestamp', () async {
      dbClient.initializeGroup('-123', 'test_group', 'Test Group', 'About Test', 1672531200);
      var group = dbClient.getAllGroups().first;
      final newTimestamp = 1672531205;
      dbClient.updateGroupTimestamp(group['id'] as int, newTimestamp);
      group = dbClient.getAllGroups().first;
      expect(group['since_timestamp'], newTimestamp);
    });
  });
}
