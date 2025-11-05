import 'package:args/args.dart';
import 'package:vllm_cli/src/db_client.dart';
import 'package:vllm_cli/src/vllm_client.dart';
import 'package:vllm_cli/src/vk_api_client.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('vk-token', help: 'VK API access token.');

  try {
    final argResults = parser.parse(arguments);

    if (!argResults.options.contains('vk-token')) {
      print('Usage: dart run batch_process.dart --vk-token <token>');
      print(parser.usage);
      return;
    }

    final vkToken = argResults['vk-token'];

    final dbClient = DbClient();
    final vkApiClient = VkApiClient();
    final vllmClient = VllmClient();

    print('Starting batch processing...');
    final groups = dbClient.getAllGroups();
    final newTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    for (final group in groups) {
      final groupId = group['id'] as int;
      final communityId = group['community_id'] as String;
      final sinceTimestamp = group['since_timestamp'] as int;

      print('\nProcessing group: ${group['name']}');

      try {
        final posts = await vkApiClient.getWallPosts(
          vkToken,
          communityId,
          sinceTimestamp,
        );

        if (posts.isEmpty) {
          print('  No new posts found.');
          continue;
        }

        for (final post in posts) {
          final text = post['text'] as String;
          final attachments = post['attachments'] as List?;

          if (text.isNotEmpty && attachments != null) {
            for (final attachment in attachments) {
              if (attachment['type'] == 'photo') {
                final photo = attachment['photo'];
                final sizes = photo['sizes'] as List;
                final largestImage = sizes.last;
                final imageUrl = largestImage['url'] as String;

                print('  ---\n  Post: $text');
                print('  Image: $imageUrl');

                final prompt =
                    'Текст поста: """$text""". Является ли картинка вместе с текстом поста анонсом предстоящего мероприятия? Если да, то выдай структурированную информацию с полями: 1) Кто (название артиста/коллектива), 2) Где, 3) Когда (Дата, Время), 4) Сколько стоит, 5) Где купить билеты, 6) Стоимость.';
                final response = await vllmClient.generate(imageUrl, prompt);
                print('  VLLM Response: $response');
                break; // Process only the first photo
              }
            }
          }
        }

        dbClient.updateGroupTimestamp(groupId, newTimestamp);
        print('  Updated timestamp for group ${group['name']}.');
      } catch (e) {
        print('  Error processing group ${group['name']}: $e');
      }
    }

    dbClient.close();
    print('\nBatch processing complete!');
  } catch (e) {
    print('An error occurred: $e');
  }
}
