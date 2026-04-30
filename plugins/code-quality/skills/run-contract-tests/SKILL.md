---
description: Run the contract tests for a feature's output interfaces. Load at the Feature Design stage gate and at feature integration. Contract tests verify boundary contracts defined in the Feature Design.
user-invocable: false
allowed-tools:
  - "Bash(*)"
  - Read
---
# Run Contract Tests

Run the contract tests for a feature's output interfaces. Contract tests are a distinct subset of the test suite, authored from the Feature Design's **Output Contracts** section before any implementation begins.

## What are contract tests

Contract tests verify that the interfaces a feature exposes (function signatures, API shapes, file formats, CLI output) match the contract defined in the Feature Design. They are not unit tests of internal logic — they test the boundary.

Contract tests must:
- Be authored by the feature-planner as part of the Feature Design stage
- Be committed to the feature branch before implementation begins
- Fail initially (because the implementation does not yet exist)
- Pass when the feature is correctly implemented

## Running contract tests

Contract tests are tagged with a marker or placed in a dedicated location, depending on the toolchain:

- **Rust**: `#[cfg(test)]` module with a `// contract-test` comment; run with `cargo test contract`
- **Node/Jest**: files named `*.contract.test.ts`; run with `jest --testPathPattern="contract"`
- **Python**: files named `test_contract_*.py`; run with `pytest -m contract`

Read the Feature Design's **Contract Tests** section to identify which tests to run. If the tests are not yet tagged, identify them by name from the Feature Design and run them explicitly.

## Output

**Contract tests pass**:
```
CONTRACT TESTS: pass
  Feature: <feature-id> — <feature-name>
  Tests run: <N>
  Duration: <duration>
```

**Contract tests fail**:
```
CONTRACT TESTS: fail
  Feature: <feature-id> — <feature-name>
  Failed: <N> of <total>

  <failure details>

  This is a hard block. The implementation does not satisfy the feature contract.
```

## Integration gate

Contract tests are run at the feature integration step, after all work units for a feature are complete. A failed contract test at this stage indicates an implementation error in one or more work units. Identify which work unit is responsible and open a new bug work unit.
