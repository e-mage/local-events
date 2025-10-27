import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:vllm_cli/src/vk_api_client.dart';

import 'vllm_client_test.mocks.dart';

void main() {
  group('VkApiClient', () {
    test(
      'getWallPosts returns filtered posts on successful response',
      () async {
        final client = MockClient();
        final vkApiClient = VkApiClient(client: client);

        final responseJson = {
          'response': {
            'items': [
              {
                'id': 1,
                'date': 1672531200,
                'text': 'Post 1',
              }, // Exactly at timestamp
              {
                'id': 2,
                'date': 1672531201,
                'text': 'Post 2',
              }, // After timestamp
              {
                'id': 3,
                'date': 1672531199,
                'text': 'Post 3',
              }, // Before timestamp
            ],
          },
        };

        when(client.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(responseJson), 200),
        );

        final posts = await vkApiClient.getWallPosts(
          'token',
          '-123',
          1672531200,
        );

        expect(posts.length, 1);
        expect(posts[0]['id'], 2);
      },
    );

    test('getWallPosts throws exception on failed response', () async {
      final client = MockClient();
      final vkApiClient = VkApiClient(client: client);

      when(
        client.get(any),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => vkApiClient.getWallPosts('token', '-123', 1672531200),
        throwsA(isA<Exception>()),
      );
    });

    test('getWallPosts throws exception on VK API error', () async {
      final client = MockClient();
      final vkApiClient = VkApiClient(client: client);

      final errorResponse = {
        'error': {'error_code': 5, 'error_msg': 'User authorization failed'},
      };

      when(
        client.get(any),
      ).thenAnswer((_) async => http.Response(json.encode(errorResponse), 200));

      expect(
        () => vkApiClient.getWallPosts('token', '-123', 1672531200),
        throwsA(isA<Exception>()),
      );
    });

    test('getGroupsById returns groups on successful response', () async {
      final client = MockClient();
      final vkApiClient = VkApiClient(client: client);

      final responseJson = {
        'response': [
          {'id': 1, 'name': 'Group 1', 'description': 'Desc 1'},
          {'id': 2, 'name': 'Group 2', 'description': 'Desc 2'},
        ],
      };

      when(
        client.get(any),
      ).thenAnswer((_) async => http.Response(json.encode(responseJson), 200));

      final groups = await vkApiClient.getGroupsById(['-1', '-2'], 'token');

      expect(groups.length, 2);
      expect(groups[0]['name'], 'Group 1');
    });
  });
}
