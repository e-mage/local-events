# Design Document: vllm_cli

## Overview

`vllm_cli` is a command-line interface (CLI) utility built with Dart that enables users to interact with a vLLM (Vision Language Model) service. The tool accepts two primary arguments: a URL for an image and a text prompt. It sends this information to a specified vLLM instance, which is expected to be API-compatible with OpenAI's chat completions endpoint, and then prints the model's textual response to the console.

## Problem Analysis

The primary goal is to create a simple, efficient, and easy-to-use tool for developers and researchers to query a running vLLM instance from the command line. The current workflow for interacting with such models often involves writing custom scripts (e.g., Python with `requests`) or using more complex GUI-based tools. A dedicated CLI tool streamlines this process, making it faster and more convenient to test and interact with vision-language models.

The tool needs to:
1.  Parse command-line arguments for an image URL and a text prompt.
2.  Construct a JSON payload that conforms to the OpenAI chat completions API format for multimodal inputs.
3.  Send this payload as a POST request to a hardcoded vLLM endpoint (`localhost:8000`).
4.  Receive the JSON response from the service.
5.  Parse the response to extract the generated text.
6.  Print the extracted text to standard output.
7.  Handle potential errors gracefully (e.g., network issues, invalid arguments, API errors).

## Alternatives Considered

### 1. Python/Shell Scripts

- **Description:** A simple script using `curl` or Python's `requests` library could achieve the same core functionality.
- **Pros:** Quick to write for a single user.
- **Cons:** Less portable. Requires the user to have a specific environment (Python, required libraries) set up. Harder to distribute as a standalone executable. Dart, with its ability to compile to a native executable, provides a much better distribution story.

### 2. GUI Application

- **Description:** A graphical user interface could be built using Flutter or another framework.
- **Pros:** Could offer a more interactive and user-friendly experience.
- **Cons:** Significantly more complex and time-consuming to develop. Overkill for the stated problem, which is to provide a quick and simple command-line utility.

The CLI approach with Dart was chosen for its balance of simplicity, performance, and excellent portability as a self-contained native executable.

## Detailed Design

The application will be structured into a few key components: the CLI entrypoint, an API client for communicating with the vLLM service, and the data models for serialization/deserialization.

### 1. CLI Entrypoint (`bin/vllm_cli.dart`)

- This will be the main executable file.
- It will use the `package:args` library to define and parse the command-line arguments.
    - `--image-url`: A required `String` option for the image URL.
    - `--prompt`: A required `String` option for the text prompt.
- The main function will:
    1.  Initialize an `ArgParser`.
    2.  Parse the incoming arguments.
    3.  Validate that both required arguments are present. If not, it will print a usage message and exit.
    4.  Instantiate the `VllmClient`.
    5.  Call the client's `generate` method with the provided arguments.
    6.  Use a `try-catch` block to handle any exceptions from the client, printing a user-friendly error message.
    7.  If successful, print the returned response string to the console.

### 2. VLLM API Client (`lib/src/vllm_client.dart`)

- A class, `VllmClient`, will encapsulate all logic for interacting with the vLLM API.
- **Constructor:** It will take the base URL of the vLLM service (`http://localhost:8000`) as an optional parameter, with a default value.
- **`generate(String imageUrl, String prompt)` method:**
    1.  This asynchronous method will return a `Future<String>`.
    2.  It will construct the request body as a Dart `Map<String, dynamic>`. This map will be structured to match the JSON payload for the OpenAI API with vision, as discovered in the research phase.
    3.  It will use `json.encode` to serialize the map into a JSON string.
    4.  It will use the `package:http` to send a `POST` request to the `/v1/chat/completions` endpoint.
        - The `Content-Type` header will be set to `application/json`.
        - The encoded JSON string will be the request body.
    5.  It will check the status code of the response. If it's not 200, it will throw an exception with a descriptive error message.
    6.  It will parse the JSON response body using `json.decode`.
    7.  It will navigate the parsed JSON to extract the content of the message from the first choice (`response['choices'][0]['message']['content']`).
    8.  It will return the extracted content as a `String`.

### 3. Mermaid Diagram

```mermaid
sequenceDiagram
    participant User
    participant CLI (bin/vllm_cli.dart)
    participant VllmClient (lib/src/vllm_client.dart)
    participant vLLM API (localhost:8000)

    User->>+CLI: dart run vllm_cli --image-url <url> --prompt <text>
    CLI->>+VllmClient: generate(imageUrl, prompt)
    VllmClient->>+vLLM API: POST /v1/chat/completions (JSON with image URL and prompt)
    vLLM API-->>-VllmClient: JSON Response
    VllmClient-->>-CLI: Returns generated text as String
    CLI-->>-User: prints response text
```

## Summary

The proposed design outlines a simple, robust, and maintainable Dart CLI application. It leverages standard, well-supported Dart packages (`args` for argument parsing, `http` for network requests) to interact with an OpenAI-compatible vLLM API. The code is structured with a clear separation of concerns between the command-line interface logic and the API communication logic, which will make it easy to test and extend in the future.

## Research URLs

- **OpenAI API Chat Completions with Image URL:** [https://platform.openai.com/docs/guides/vision](https://platform.openai.com/docs/guides/vision)
- **`package:http` documentation:** [https://pub.dev/documentation/http/latest/](https://pub.dev/documentation/http/latest/)
- **`package:args` documentation:** [https://pub.dev/documentation/args/latest/](https://pub.dev/documentation/args/latest/)
