# Dry-Run Compliance

Any operation that is destructive, irreversible, affects shared state, or calls an external service MUST support a dry-run mode. This is a non-negotiable house standard.

## What requires dry-run

- File deletion or overwrite
- Git push, force-push, branch deletion
- GitHub API mutations: issue creation/update, PR creation, label changes
- Shell commands that modify system state
- Any network call that causes side effects (not read-only fetches)
- Database writes or schema changes

## How to implement dry-run

Before executing any operation in the list above, check whether dry-run mode is active:

```
if DRY_RUN:
    print(f"[dry-run] would execute: {describe_operation()}")
    return
```

The dry-run output must be specific enough that a human can verify correctness without running the real operation. Include: what would happen, to which resource, with what parameters.

## Dry-run must be the default

When building any script, skill, or command that performs destructive operations, `--dry-run` (or equivalent) must be the default. The user must explicitly opt in to live execution with `--execute` or `--no-dry-run`.

## Dry-run is not optional compliance

Dry-run support is not a "nice to have." Omitting it is a spec violation and will be caught during peer review. A reviewer that notices missing dry-run support must block the work unit.
