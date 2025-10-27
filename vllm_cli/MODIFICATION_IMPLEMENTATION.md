# Modification Implementation Plan: Database Integration

This document outlines the phased implementation plan for integrating a SQLite database and batch processing capabilities into the `vllm_cli` tool.

## Journal

**Phase 1 (2025-10-20):**
- Ran existing tests to ensure a stable baseline.
- Created placeholder files for the new VK integration (`bin/vllm_cli_vk.dart` and `lib/src/vk_api_client.dart`).

**Phase 2 & 3 (2025-10-20):**
- Implemented the `VkApiClient` to fetch and filter posts from a VK community wall.
- Created unit tests for the `VkApiClient`.
- Implemented the new CLI entrypoint (`bin/vllm_cli_vk.dart`) to handle argument parsing and orchestrate the new workflow.
- Fixed several bugs in the test files and the `VkApiClient` related to string escaping and JSON encoding.

**Phase 1 (Database Integration) (2025-10-20):**
- Added `sqlite3` and `path` dependencies.
- Implemented `DbClient` for SQLite operations.
- Added `getGroupsById` method to `VkApiClient`.
- Implemented unit tests for `DbClient` and `VkApiClient.getGroupsById`.
- Fixed issues with `sqlite3` library loading and test setup.

**Phase 2 (Database Initialization Script) (2025-10-20):**
- Created `bin/init_db.dart` script.
- Implemented argument parsing for `--vk-token` and `--file`.
- Added logic to read community IDs from a file, fetch group data from VK API, and populate the database.

---

## Phased Implementation

### Phase 1: Setup and Database Client

- [x] Run all existing tests to ensure the project is in a good state.
- [x] Add the `sqflite` and `path` packages to `pubspec.yaml`.
- [x] Create the `lib/src/db_client.dart` file.
- [x] Implement the `DbClient` class with the following methods:
    -   `initDB()`: To create the database file and the `groups` table.
    -   `initializeGroup(String communityId, String name, String about, int sinceTimestamp)`: To insert a new group, checking for duplicates.
    -   `getAllGroups()`: To fetch all groups.
    -   `updateGroupTimestamp(int id, int newTimestamp)`: To update a group's timestamp.
- [x] Add a new method `getGroupsById(List<String> groupIds, String accessToken)` to the `VkApiClient` in `lib/src/vk_api_client.dart`.
- [x] Add unit tests for the new `DbClient` methods and the new `VkApiClient.getGroupsById` method.

### Phase 2: Implement the Database Initialization Script

- [x] Create the `bin/init_db.dart` script.
- [x] Implement argument parsing for `--vk-token` and `--file`.
- [x] Add logic to read community IDs from the specified file.
- [x] Use `VkApiClient.getGroupsById` to fetch community data.
- [x] Use `DbClient.initializeGroup` to populate the database.
- [x] Add user-friendly print statements to show progress and success/error messages.

**Phase 3 (Batch Processing Script) (2025-10-20):**
- Created the `bin/batch_process.dart` script to iterate through the database, fetch new posts, and process them.
- Implemented the full batch processing logic, including timestamp updates and error handling.

- [x] Create the `bin/batch_process.dart` script.
- [x] Implement argument parsing for `--vk-token`.
- [x] Add the main logic:
    1.  Instantiate all clients (`DbClient`, `VkApiClient`, `VllmClient`).
    2.  Fetch all groups from the database.
    3.  Loop through each group, fetch new posts, and process them with the vLLM.
    4.  Update the `since_timestamp` for each group after it has been processed.
- [x] Add robust error handling and print statements to log the script's activity.

**Phase 4 (Finalization and Documentation) (2025-10-20):**
- Updated `README.md` with instructions for `init_db.dart` and `batch_process.dart`.
- Updated `GEMINI.md` to reflect the new database components and scripts.

- [x] Update the main `README.md` to include instructions for the two new scripts (`init_db.dart` and `batch_process.dart`).
- [x] Update the `GEMINI.md` file to reflect the new database components and scripts.
- [ ] Ask the user to inspect the final code and the new scripts to ensure they meet all requirements.

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