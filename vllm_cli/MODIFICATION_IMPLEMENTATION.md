# Modification Implementation Plan: VK Integration

This document outlines the phased implementation plan for integrating VK.com functionality into the `vllm_cli` tool.

## Journal

**Phase 1 (2025-10-20):**
- Ran existing tests to ensure a stable baseline.
- Created placeholder files for the new VK integration (`bin/vllm_cli_vk.dart` and `lib/src/vk_api_client.dart`).

**Phase 2 & 3 (2025-10-20):**
- Implemented the `VkApiClient` to fetch and filter posts from a VK community wall.
- Created unit tests for the `VkApiClient`.
- Implemented the new CLI entrypoint (`bin/vllm_cli_vk.dart`) to handle argument parsing and orchestrate the new workflow.
- Fixed several bugs in the test files and the `VkApiClient` related to string escaping and JSON encoding.

**Phase 4 (2025-10-20):**
- Updated the `README.md` and `GEMINI.md` files with details about the new VK integration.

---

## Phased Implementation

### Phase 1: Initial Setup and Test Verification

- [x] Run all existing tests to ensure the project is in a good state before starting modifications.
- [x] Create a new entrypoint file: `bin/vllm_cli_vk.dart` with a basic "Hello World" main function.
- [x] Create the `lib/src/vk_api_client.dart` file with an empty `VkApiClient` class.

### Phase 2: Implement the VK API Client

- [x] Add the `http` package dependency if it's not already there (it should be).
- [x] Implement the `VkApiClient` class in `lib/src/vk_api_client.dart`.
    -   The constructor should accept an `http.Client` for testing.
    -   Implement the `getWallPosts(String accessToken, String communityId, int sinceTimestamp)` method.
- [x] The `getWallPosts` method will:
    -   Construct the request URL for the `wall.get` VK API method.
    -   Make a GET request.
    -   Parse the JSON response.
    -   Filter the posts based on the `sinceTimestamp`.
    -   Return a list of post objects.
- [x] Add unit tests for the `VkApiClient` in a new `test/vk_api_client_test.dart` file.
    -   Mock the `http.Client`.
    -   Test successful response parsing and filtering.
    -   Test API error handling.

### Phase 3: Implement the VK CLI Entrypoint

- [x] In `bin/vllm_cli_vk.dart`, implement the argument parsing using the `args` package.
    -   `--vk-token` (required)
    -   `--community-id` (required)
    -   `--since-timestamp` (required, should be parsed as an integer).
- [x] Add logic to validate the presence of all required arguments.
- [x] Instantiate `VkApiClient` and `VllmClient`.
- [x] Call `vkApiClient.getWallPosts` with the parsed arguments.
- [x] Loop through the returned posts:
    -   Extract `text` and the largest photo URL from the `attachments`.
    -   If both are present, call `vllmClient.generate()`.
    -   Print the results in a readable format.
- [x] Add `try-catch` blocks to handle errors gracefully.

### Phase 4: Finalization and Documentation

- [x] Update the main `README.md` to include a section about the new `vllm_cli_vk` tool, its purpose, and usage examples.
- [x] Update the `GEMINI.md` file to include details about the new files (`vk_api_client.dart`, `vllm_cli_vk.dart`) and their roles.
- [ ] Ask the user to inspect the final code and the new CLI tool to ensure it meets their requirements.

---

## General Instructions for Each Phase

After completing the tasks in each phase, the following steps must be taken:

- [ ] If any `TODO`s were added to the code or anything was not fully implemented, add new tasks to this plan to address them later.
- [ ] Create or modify unit tests for the code added or modified in this phase, if relevant.
- [ ] Run `dart fix --apply` to clean up the code.
- [ ] Run `dart analyze` to identify and fix any static analysis issues.
- [ ] Run all tests to ensure they pass.
- [ ] Run `dart format .` to ensure correct formatting.
- [ ] Re-read this `MODIFICATION_IMPLEMENTATION.md` file to check for any changes and address them.
- [ ] Update this `MODIFICATION_IMPLEMENTATION.md` file with the current state, checking off completed tasks and updating the Journal.
- [ ] Use `git diff` to verify the changes made, and create a suitable commit message. Present the message to the user for approval before committing.
- [ ] Wait for user approval before committing and moving to the next phase.
