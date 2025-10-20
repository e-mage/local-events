import 'package:args/args.dart';
import 'package:vllm_cli/src/vllm_client.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('image-url', help: 'The URL of the image to analyze.')
    ..addOption('prompt', help: 'The text prompt to send to the model.');

  try {
    final argResults = parser.parse(arguments);

    if (!argResults.options.contains('image-url') ||
        !argResults.options.contains('prompt')) {
      print('Usage: dart run vllm_cli --image-url <url> --prompt <text>');
      print(parser.usage);
      return;
    }

    final imageUrl = argResults['image-url'];
    final prompt = argResults['prompt'];

    final client = VllmClient();
    final response = await client.generate(imageUrl, prompt);

    print(response);
  } catch (e) {
    print('Error: \$e');
  }
}
