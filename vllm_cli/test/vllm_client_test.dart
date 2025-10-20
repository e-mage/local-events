import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:vllm_cli/src/vllm_client.dart';

import 'vllm_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('VllmClient', () {
    test('generate returns content on successful response', () async {
      final client = MockClient();
      final vllmClient = VllmClient(client: client);

      when(
        client.post(any, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => http.Response(
          '{"choices": [{"message": {"content": "Test response"}}]}',
          200,
        ),
      );

      final response = await vllmClient.generate('image_url', 'prompt');

      expect(response, 'Test response');
    });

    test('generate throws exception on failed response', () async {
      final client = MockClient();
      final vllmClient = VllmClient(client: client);

      when(
        client.post(any, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => vllmClient.generate('image_url', 'prompt'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
