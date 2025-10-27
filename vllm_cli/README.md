# vllm_cli

A command-line utility, written in Dart, to interact with a vLLM (Vision Language Model) service that is compatible with the OpenAI API.

## Description

This tool allows you to send a text prompt and an image URL to a running vLLM instance and receive a textual response. It is designed for quick and easy interaction with vision-language models from the command line.

## Installation

1.  Ensure you have the [Dart SDK](https://dart.dev/get-dart) installed.
2.  Clone this repository.
3.  Navigate to the project directory:
    ```sh
    cd vllm_cli
    ```
4.  Build the executable:
    ```sh
    dart compile exe bin/vllm_cli.dart -o vllm_cli
    ```
5.  (Optional) Move the executable to a directory in your system's PATH to make it accessible from anywhere:
    ```sh
    mv vllm_cli /usr/local/bin/
    ```

## Usage

Run the tool with the following command, providing both an image URL and a text prompt:

```sh
./vllm_cli --image-url <URL_to_your_image> --prompt "Your text prompt here"
```

### Example

```sh
./vllm_cli --image-url https://example.com/my-cat.jpg --prompt "What color is the cat in the image?"
```

## vllm_cli_vk

This is a variant of the `vllm_cli` tool that sources its content from a VK.com community wall.

### Installation

```sh
dart compile exe bin/vllm_cli_vk.dart -o vllm_cli_vk
```

### Usage

```sh
./vllm_cli_vk --vk-token <YOUR_VK_TOKEN> --community-id <YOUR_COMMUNITY_ID> --since-timestamp <UNIX_TIMESTAMP>
```

### init_db.dart

This script initializes the SQLite database with VK community information.

#### Usage

```sh
dart run bin/init_db.dart --vk-token <YOUR_VK_TOKEN> --file <PATH_TO_COMMUNITY_IDS_FILE>
```

Where `<PATH_TO_COMMUNITY_IDS_FILE>` is a text file with one community ID per line.

### batch_process.dart

This script iterates through the communities in the database, fetches new posts, and processes them with the VLLM.

#### Usage

```sh
dart run bin/batch_process.dart --vk-token <YOUR_VK_TOKEN>
```
