import 'dart:io';

import 'package:args/args.dart';
import 'package:vllm_cli/src/db_client.dart';
import 'package:vllm_cli/src/vk_api_client.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('vk-token', help: 'VK API access token.')
    ..addOption('file', help: 'Path to a text file with community IDs.');

  try {
    final argResults = parser.parse(arguments);

    if (!argResults.options.contains('vk-token') ||
        !argResults.options.contains('file')) {
      print(
        'Usage: dart run init_db.dart --vk-token <token> --file <path_to_file>',
      );
      print(parser.usage);
      return;
    }

    final vkToken = argResults['vk-token'];
    final filePath = argResults['file'];

    final file = File(filePath);
    if (!await file.exists()) {
      print('Error: File not found at $filePath');
      return;
    }

    final communityIds = await file.readAsLines();
    //print(communityIds);

    final vkApiClient = VkApiClient();
    final dbClient = DbClient();

    print('Fetching group info from VK...');
    final groupsData = await vkApiClient.getGroupsById(communityIds, vkToken);
    //print(groupsData);

    final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
    final sinceTimestamp = twoWeeksAgo.millisecondsSinceEpoch ~/ 1000;

    print('Initializing database...');
    for (final groupData in groupsData[0]['groups']) {
      final communityId = groupData['id'].toString();
      final screenName = groupData['screen_name'].toString();
      final name = groupData['name'] as String? ?? '';
      final about = groupData['description'] as String? ?? '';

      dbClient.initializeGroup(
        '-$communityId', // VK community IDs are negative
        screenName,
        name,
        about,
        sinceTimestamp,
      );
      print('Added group: Name: $name, id: $communityId, screen_nane: $screenName, sinceTS: $sinceTimestamp');
    }

    dbClient.close();
    print('Database initialization complete!');
  } catch (e) {
    print('An error occurred: $e');
  }
}
