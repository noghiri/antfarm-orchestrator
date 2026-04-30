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

## Contract test location and naming convention

Contract tests are identified by a consistent naming convention that allows them to be run in isolation from the full test suite. The convention varies by toolchain:

| Toolchain | File location | Function/test name | Run command |
|-----------|---------------|--------------------|-------------|
| **Rust** | `tests/contracts/` directory (integration tests) | Functions prefixed `contract_` | `cargo test contract_` |
| **Node/Jest** | Same directory as source, named `*.contract.test.ts` | Any name | `jest --testPathPattern="contract"` |
| **Python** | `tests/` directory, files named `test_contract_*.py` | Functions prefixed `test_contract_` | `pytest -m contract` (mark with `@pytest.mark.contract`) |
| **Go** | Same package as the code under test, files named `*_contract_test.go` | Functions prefixed `TestContract` | `go test -run TestContract ./...` |

**Rust note**: Place contract tests under `tests/contracts/<feature-id>.rs` (integration test directory, not `src/`). Use the `contract_` function name prefix so `cargo test contract_` runs only them. Example:
```rust
// tests/contracts/f001.rs
#[test]
fn contract_health_returns_200() { /* ... */ }
```

**Python note**: Annotate each contract test function with `@pytest.mark.contract` and register the marker in `pyproject.toml` or `pytest.ini`:
```ini
[pytest]
markers = contract: contract tests for feature output interfaces
```

Read the Feature Design's **Contract Tests** section to identify which tests to write and run. The test names in the Feature Design must match the actual function names in the stubs.

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
