---
description: Run the project build using the command from project.yaml. Load during implementation and at the work unit completion gate. Toolchain-agnostic. Build failures are hard blocks.
user-invocable: false
allowed-tools:
  - "Bash(*)"
  - Read
---
# Run Build

Run the project build using the command configured in `project.yaml`. This skill is toolchain-agnostic — it reads the command from config and executes it.

## Configuration

Read `toolchain.build` from `project.yaml`. If the field is missing or empty, report a configuration error and skip.

## Execution

Run the build command from the project root directory. Capture stdout and stderr.

Example (Rust): `cargo build`
Example (Node): `npm run build`
Example (Go): `go build ./...`

## Output

**Build passes**:
```
BUILD: pass
  Command: <command>
  Duration: <duration>
```

**Build fails**:
```
BUILD: fail
  Command: <command>
  Exit code: <N>

  <stderr output — first 2000 chars>

  This is a hard block. Resolve build errors before proceeding.
```

## When to run

- After each significant change during implementation (not every line edit, but after each logical chunk)
- As part of the work unit completion checklist before opening the PR

## Build failures during implementation

If the build fails during implementation, stop and fix the build errors before continuing. Do not commit code that does not build. If the same build error recurs more than twice, use `self-assess` to check for the stuck signal.
