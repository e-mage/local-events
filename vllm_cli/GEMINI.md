# GEMINI.md

This document provides an overview of the `vllm_cli` application, its purpose, implementation details, and file layout.

## Purpose

The `vllm_cli` is a Dart command-line utility designed to provide a simple and efficient way to interact with a Vision Language Model (vLLM) service. It allows users to send a text prompt and an image URL to an OpenAI API-compatible vLLM instance and receive a textual response.

## Implementation Details

The application is built using the Dart SDK and leverages several core packages:

-   **`package:args`**: For parsing command-line arguments (`--image-url` and `--prompt`).
-   **`package:http`**: For making HTTP POST requests to the vLLM service.
-   **`package:test`**, **`package:mockito`**, and **`package:build_runner`**: For unit testing the API client.

The code is structured into four main components:

1.  **`VllmClient` (`lib/src/vllm_client.dart`)**: This class encapsulates all the logic for communicating with the vLLM API.

2.  **`VkApiClient` (`lib/src/vk_api_client.dart`)**: This class handles communication with the VK.com API to fetch wall posts.

3.  **CLI Entrypoint (`bin/vllm_cli.dart`)**: The main executable for processing direct image URLs.

4.  **VK CLI Entrypoint (`bin/vllm_cli_vk.dart`)**: The executable for sourcing content from a VK community wall.

## File Layout

```
.gitignore
analysis_options.yaml
CHANGELOG.md
lib/
  src/
    vllm_client.dart      # The API client for the vLLM service.
    vk_api_client.dart    # The API client for the VK.com service.
bin/
  vllm_cli.dart         # The main executable and CLI entrypoint.
  vllm_cli_vk.dart      # The entrypoint for the VK integration.
pubspec.lock
pubspec.yaml
README.md
GEMINI.md               # This file.
specs/
  DESIGN.md             # The initial design document.
  IMPLEMENTATION.md     # The implementation plan.
test/
  vllm_client_test.dart # Unit tests for the VllmClient.
  vk_api_client_test.dart # Unit tests for the VkApiClient.
```
