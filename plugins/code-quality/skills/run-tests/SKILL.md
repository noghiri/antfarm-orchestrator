---
description: Run the full test suite using the command from project.yaml. Load during implementation (TDD loop) and at the work unit completion gate. All tests must pass before PR submission.
user-invocable: false
allowed-tools:
  - "Bash(*)"
  - Read
---
# Run Tests

Run the project test suite using the command configured in `project.yaml`. All tests must pass before a work unit PR can be submitted.

## Configuration

Read `toolchain.test` from `project.yaml`. If the field is missing or empty, report a configuration error and skip.

## Execution

Run the test command from the project root. Capture stdout and stderr.

Example (Rust): `cargo test`
Example (Node): `npm test`
Example (Go): `go test ./...`

## Output

**All tests pass**:
```
TESTS: pass
  Command: <command>
  Tests run: <N>
  Duration: <duration>
```

**Tests fail**:
```
TESTS: fail
  Command: <command>
  Failed: <N> of <total>

  <failure output — first 3000 chars>

  This is a hard block. All tests must pass before PR submission.
```

## TDD workflow

Tests should be written before implementation. The expected workflow is:

1. Write tests that fail (because the implementation does not exist yet)
2. Confirm the tests fail for the right reason (missing function, not wrong assertion)
3. Implement until all tests pass
4. Run `run-lint` and `run-build` to confirm no regressions

If you are given a work unit where tests already exist, run them first to confirm the baseline before making changes.

## Test scope

When running tests for a specific work unit, prefer to run the full suite to catch regressions. If the suite is slow, identify and run the relevant subset, but run the full suite before PR submission.
