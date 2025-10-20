import 'dart:convert';
import 'package:http/http.dart' as http;

class VllmClient {
  VllmClient({this.endpoint = 'http://localhost:8000'});

  final String endpoint;

  Future<String> generate(String imageUrl, String prompt) async {
    final url = Uri.parse('$endpoint/v1/chat/completions');
    final headers = {'Content-Type': 'application/json'};
    final body = {
      'model': 'llava-1.5-7b-hf',
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
      final response = await http.post(
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
