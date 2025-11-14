import 'dart:convert';

import 'package:args/args.dart';
import 'package:vllm_cli/src/db_client.dart';
import 'package:vllm_cli/src/vllm_client.dart';
import 'package:vllm_cli/src/vk_api_client.dart';
import 'package:remove_emoji/remove_emoji.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('vk-token', help: 'VK API access token.');
  //var remove = RemoveEmoji();

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
      List<(int, int, int, String?, String?, String?, String?, String?, String?, String?, String?, String?)> groupEvents = [];

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
            List<String> imageUrls = [];
            for (final attachment in attachments) {
              if (attachment['type'] == 'photo') {
                final photo = attachment['photo'];
                final sizes = photo['sizes'] as List;
                final largestImage = sizes.last;
                final imageUrl = largestImage['url'] as String;
                //print('  Image: $imageUrl');
                imageUrls.add(imageUrl);
                if (imageUrls.length >= 5) { break; }
                //break; // Process only the first photo
              }
            }
            print('  --- Число картинок: ${imageUrls.length} ---\n  Post: ${text.removEmoji} \n===');
            final prompt = '''
                    Проанализируй картинки и текст поста между тройными кавычками: """${text.removEmoji}""".

                    Являются ли картинки и текст поста анонсами предстоящих мероприятий?
                    Если являются, то для каждого мероприятия найди следующую информацию:
                      Кто? (название выступающиего артиста/коллектива);
                      Как называется мероприятие?;
                      Тип мероприятия? (один из следующий вариантов: "концерт", "театр", "кино", "поэзия", "спорт", "игры", "выставка", "лекция", "мастер-класс", "клуб по интересам", "для детей", "фестиваль", "презентация", "экскурсия", "дегустация", "танцы", "неопределен");
                      Где? (место проведения мероприятия);
                      Когда? (дата проведения мероприятия);
                      Во сколько? (время начала мероприятия);
                      Сколько стоит?;
                      Где купить билеты?;
                      Кто организатор мероприятия?.

                    Выдай ответ в структурированном виде в формате JSON (без обертки в markdown), содержащим следующие поля:
                    "name" - Кто? (название выступающего артиста/коллектива);
                    "title" - Как называется мероприятие?;
                    "type" - Тип мероприятия? (один из следующий вариантов: "концерт", "театр", "кино", "поэзия", "спорт", "игры", "выставка", "лекция", "мастер-класс", "клуб по интересам", "для детей", "фестиваль", "презентация", "экскурсия", "дегустация", "танцы", "неопределен");
                    "location" - Где? (место проведения мероприятия);
                    "date" - Когда? (дата проведения мероприятия);
                    "time" - Во сколько? (время начала мероприятия);
                    "price" - Сколько стоит?;
                    "tickets" - Где купить билеты?;
                    "organizer" - Кто организатор мероприятия?.

                    Пример ответа в случае, если пост содержит анонсы:
                    [
                      {
                        "name": "Рок-группа Самоцветы",
                        "title": "Золотые хиты 80-х",
                        "type": "концерт",
                        "location": "ул. Пушкина, дом 1",
                        "date": "25.10.2025",
                        "time": "19:30",
                        "price": "600 рублей",
                        "tickets": "https://mytickets.com/id/201345",
                        "organizer": "Дому Культуры"
                      },
                      {
                        "name": "Джазовый коллектив JazzBand",
                        "title": "Музыка Нового Орлеана",
                        "type": "концерт",
                        "location": "ул. Ленина, дом 2",
                        "date": "30.10.2025",
                        "time": "20:00",
                        "price": "500 рублей",
                        "tickets": "https://mytickets.com/id/201346",
                        "organizer": "Областная филармония"
                      }
                    ]

                    Пример ответа, если пост не содержит анонсы:
                    []
                    ''';
            //print('--- New prompt: $prompt');
            final response = await vllmClient.generate(imageUrls, prompt);
            print('---  VLLM Response: $response');
            //await Future.delayed(Duration(seconds: 3)); // Pause for vLLM
            final dynamic responseData = json.decode(response);
            late List<Map<String,dynamic>> data;
            if (responseData is List) {
              data = responseData.cast<Map<String, dynamic>>();
            } else if (responseData is Map<String, dynamic>) {
              data = [responseData];
            } else {
              throw Exception('Unexpected response JSON format from vLLM');
            }
            //final List<Map<String,dynamic>> data = json.decode(response).cast<Map<String, dynamic>>();
            print('Decoded data: $data');
            for (var event in data) {
              groupEvents.add((groupId, post['id'], post['date'], event['name'], event['title'], event['type'], event['location'], event['date'], event['time'], event['price'], event['tickets'], event['organizer']));
              //dbClient.addEvent(groupId, post['id'], post['date'], event['name'], event['location'], event['date'], event['time'], event['price'], event['tickets'], event['organizer']);
            }
          }
        }
        for (var event in groupEvents) {
          dbClient.addEvent(event.$1, event.$2, event.$3, event.$4, event.$5, event.$6, event.$7, event.$8, event.$9, event.$10, event.$11, event.$12);
        }
        dbClient.updateGroupTimestamp(groupId, newTimestamp);
        print('  Updated timestamp for group ${group['name']}.');
      } catch (e) {
        print('  Error processing group ${group['name']}: $e');
      }
    }

    final allEvents = dbClient.getAllEvents();
    print('All events from DB: $allEvents');

    dbClient.close();
    print('\nBatch processing complete!');
  } catch (e) {
    print('An error occurred: $e');
  }
}
