import 'package:args/args.dart';
import 'package:vllm_cli/src/vllm_client.dart';
import 'package:vllm_cli/src/vk_api_client.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('vk-token', help: 'VK API access token.')
    ..addOption('community-id', help: 'VK community ID.')
    ..addOption('since-timestamp', help: 'Unix timestamp to filter posts.');

  try {
    final argResults = parser.parse(arguments);

    if (!argResults.options.contains('vk-token') ||
        !argResults.options.contains('community-id') ||
        !argResults.options.contains('since-timestamp')) {
      print(
        'Usage: dart run vllm_cli_vk --vk-token <token> --community-id <id> --since-timestamp <timestamp>',
      );
      print(parser.usage);
      return;
    }

    final vkToken = argResults['vk-token'];
    final communityId = argResults['community-id'];
    final sinceTimestamp = int.parse(argResults['since-timestamp']);

    final vkApiClient = VkApiClient();
    final vllmClient = VllmClient();

    final posts = await vkApiClient.getWallPosts(
      vkToken,
      communityId,
      sinceTimestamp,
    );

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

            print('---\nPost: $text');
            print('Image: $imageUrl');

            final response = await vllmClient.generate(imageUrl, text);
            print('VLLM Response: $response');
            break; // Process only the first photo in a post
          }
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
