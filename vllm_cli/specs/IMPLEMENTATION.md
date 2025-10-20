# Implementation Plan: vllm_cli

This document outlines the phased implementation plan for the `vllm_cli` package.

## Journal

*This section will be updated after each phase with a log of actions, learnings, and any deviations from the plan.*

---

## Phased Implementation

### Phase 1: Project Scaffolding and Initialization

- [ ] Create a Dart console application in the current directory (`.`).
- [ ] Add the `args` and `http` packages as dependencies.
- [ ] Update the `description` in `pubspec.yaml` to a more descriptive one and set the version to `0.1.0`.
- [ ] Delete the boilerplate `lib/vllm_cli.dart` and `test/` directory.
- [ ] Create a placeholder `README.md` with a brief description.
- [ ] Create a `CHANGELOG.md` with an initial entry for version `0.1.0`.
- [ ] Commit the initial project structure to the `feature/vllm-cli` branch.

### Phase 2: Implement the VLLM API Client

- [ ] Create a new file `lib/src/vllm_client.dart`.
- [ ] Implement the `VllmClient` class.
    - It should have a constructor that accepts the API endpoint URL.
    - It should have a public method `generate(String imageUrl, String prompt)`.
- [ ] The `generate` method will handle the logic for:
    - Creating the JSON request body.
    - Making the POST request using the `http` package.
    - Handling successful responses and extracting the message content.
    - Handling error responses (e.g., non-200 status codes).
- [ ] Add basic error handling for network exceptions.

### Phase 3: Implement the CLI Entrypoint

- [ ] Create the main entrypoint file `bin/vllm_cli.dart`.
- [ ] Use the `args` package to set up an `ArgParser` that requires two options:
    - `--image-url`: The URL of the image to analyze.
    - `--prompt`: The text prompt to send to the model.
- [ ] Parse the command-line arguments.
- [ ] If arguments are invalid or missing, print the usage information and exit.
- [ ] Instantiate `VllmClient`.
- [ ] Call the `generate` method and print the result to the console.
- [ ] Wrap the call in a `try/catch` block to gracefully handle and report any errors from the client.

### Phase 4: Testing and Refinement

- [ ] Create unit tests for the `VllmClient` in the `test/` directory. Use a mocking library like `mockito` to mock the `http.Client` and test:
    - Successful response parsing.
    - HTTP error handling.
    - Network error handling.
- [ ] Manually test the CLI executable against the live vLLM service to ensure end-to-end functionality.

### Phase 5: Finalization and Documentation

- [ ] Create a comprehensive `README.md` file that includes:
    - A clear description of what the tool does.
    - Installation instructions (how to build the executable).
    - Detailed usage examples.
- [ ] Create a `GEMINI.md` file in the project directory that describes the app, its purpose, and implementation details of the application and the layout of the files.
- [ ] Ask the user to inspect the app and the code and say if they are satisfied with it, or if any modifications are needed.

---

## General Instructions for Each Phase

After completing the tasks in each phase, the following steps must be taken:

- [ ] If any `TODO`s were added to the code or anything was not fully implemented, add new tasks to this plan to address them later.
- [ ] Create or modify unit tests for the code added or modified in this phase, if relevant.
- [ ] Run `dart fix --apply` to clean up the code.
- [ ] Run `dart analyze` to identify and fix any static analysis issues.
- [ ] Run all tests to ensure they pass.
- [ ] Run `dart format .` to ensure correct formatting.
- [ ] Re-read this `IMPLEMENTATION.md` file to check for any changes and address them.
- [ ] Update this `IMPLEMENTATION.md` file with the current state, checking off completed tasks and updating the Journal.
- [ ] Use `git diff` to verify the changes made, and create a suitable commit message. Present the message to the user for approval before committing.
- [ ] Wait for user approval before committing and moving to the next phase.
