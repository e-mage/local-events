import 'dart:convert';

import 'package:http/http.dart' as http;

class VkApiClient {
  VkApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Map<String, dynamic>>> getWallPosts(
    String accessToken,
    String communityId,
    int sinceTimestamp,
  ) async {
    final uri = Uri.https('api.vk.com', '/method/wall.get', {
      'owner_id': communityId,
      'access_token': accessToken,
      'v': '5.199',
      'filter': 'owner',
      'count': '100',
    });

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load posts from VK: \${response.body}');
    }

    final data = json.decode(response.body);
    if (data['error'] != null) {
      throw Exception('VK API Error: \${data["error"]["error_msg"]}');
    }

    final items = data['response']['items'] as List;

    return items
        .where((post) => post['date'] > sinceTimestamp)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Future<List<Map<String, dynamic>>> getGroupsById(
    List<String> groupIds,
    String accessToken,
  ) async {
    final uri = Uri.https('api.vk.com', '/method/groups.getById', {
      'group_ids': groupIds.join(','),
      'access_token': accessToken,
      'v': '5.199',
      'fields': 'description',
    });

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load groups from VK: \${response.body}');
    }

    final data = json.decode(response.body);
    if (data['error'] != null) {
      throw Exception('VK API Error: \${data["error"]["error_msg"]}');
    }

    final dynamic responseData = data['response'];

    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    } else if (responseData is Map<String, dynamic>) {
      return [responseData];
    } else {
      throw Exception('Unexpected VK API response format for groups.getById');
    }
  }
}
