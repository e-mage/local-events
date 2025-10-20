# GEMINI.md

This document provides an overview of the `vllm_cli` application, its purpose, implementation details, and file layout.

## Purpose

The `vllm_cli` is a Dart command-line utility designed to provide a simple and efficient way to interact with a Vision Language Model (vLLM) service. It allows users to send a text prompt and an image URL to an OpenAI API-compatible vLLM instance and receive a textual response.

## Implementation Details

The application is built using the Dart SDK and leverages several core packages:

-   **`package:args`**: For parsing command-line arguments (`--image-url` and `--prompt`).
-   **`package:http`**: For making HTTP POST requests to the vLLM service.
-   **`package:test`**, **`package:mockito`**, and **`package:build_runner`**: For unit testing the API client.

The code is structured into two main components:

1.  **`VllmClient` (`lib/src/vllm_client.dart`)**: This class encapsulates all the logic for communicating with the vLLM API. It constructs the request, sends it, and parses the response. It is designed to be testable by allowing for the injection of an `http.Client`.

2.  **CLI Entrypoint (`bin/vllm_cli.dart`)**: This is the main executable file. It handles parsing the command-line arguments, instantiating the `VllmClient`, calling the `generate` method, and printing the output to the console. It also includes error handling to provide user-friendly messages.

## File Layout

```
.gitignore
analysis_options.yaml
CHANGELOG.md
lib/
  src/
    vllm_client.dart      # The API client for the vLLM service.
bin/
  vllm_cli.dart         # The main executable and CLI entrypoint.
pubspec.lock
pubspec.yaml
README.md
GEMINI.md               # This file.
specs/
  DESIGN.md             # The initial design document.
  IMPLEMENTATION.md     # The implementation plan.
test/
  vllm_client_test.dart # Unit tests for the VllmClient.
```
