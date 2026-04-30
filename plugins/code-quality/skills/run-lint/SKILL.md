---
description: Run the project linter using the command from project.yaml. Load at the work unit completion gate before PR submission. Lint errors are a hard block; warnings are surfaced but do not block.
user-invocable: false
allowed-tools:
  - "Bash(*)"
  - Read
---
# Run Lint

Run the project linter using the command configured in `project.yaml`. Lint errors are a hard block for PR submission; warnings are surfaced but do not block.

## Configuration

Read `toolchain.lint` from `project.yaml`. If the field is missing or empty, skip and note lint was not configured.

## Execution

Run the lint command from the project root. Capture stdout and stderr.

Example (Rust): `cargo clippy -- -D warnings`
Example (Node): `npm run lint`
Example (Python): `ruff check .`

Treat any non-zero exit code as a lint failure.

## Output

**Lint passes**:
```
LINT: pass
  Command: <command>
  Warnings: 0
```

**Lint passes with warnings** (exit 0 but warnings in output):
```
LINT: pass (with warnings)
  Command: <command>
  Warnings: <N>

  <warning summary — first 1000 chars>
```

**Lint fails**:
```
LINT: fail
  Command: <command>
  Exit code: <N>

  <errors — first 2000 chars>

  This is a hard block. Fix lint errors before submitting the PR.
```

## House style note

For Rust, `cargo clippy -- -D warnings` is the required lint command. All warnings are errors. No `#[allow(...)]` suppressions without a documented reason comment. See the `rust-guide` skill for details.
