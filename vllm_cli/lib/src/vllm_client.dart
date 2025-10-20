import 'dart:convert';

import 'package:http/http.dart' as http;

class VllmClient {
  VllmClient({this.endpoint = 'http://localhost:8000', http.Client? client})
    : _client = client ?? http.Client();

  final String endpoint;
  final http.Client _client;

  Future<String> generate(String imageUrl, String prompt) async {
    final url = Uri.parse('$endpoint/v1/chat/completions');
    final headers = {'Content-Type': 'application/json'};
    final body = {
      'model': 'Qwen/Qwen3-VL-4B-Instruct-FP8',
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {'url': imageUrl},
            },
          ],
        },
      ],
      'max_tokens': 300,
    };

    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate response: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the vLLM service: \$e');
    }
  }
}
