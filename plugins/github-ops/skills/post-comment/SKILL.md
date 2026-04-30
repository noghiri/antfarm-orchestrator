---
description: Post a comment to a GitHub Issue or Pull Request. Invoke explicitly for escalation notices, status updates, review feedback, and pause/release notifications. Dry-run by default.
disable-model-invocation: true
allowed-tools:
  - "Bash(gh issue comment *)"
  - "Bash(gh pr comment *)"
---
# Post Comment

Post a comment to a GitHub Issue or Pull Request using the `gh` CLI.

## Dry-run (default)

```
[dry-run] would post comment to #<number>:
  body: <first 300 chars of comment>
```

## Live execution

Only when `--execute` is confirmed:

```sh
# Comment on an issue
gh issue comment <number> --body "<comment>"

# Comment on a PR
gh pr comment <number> --body "<comment>"
```

## Comment conventions

**Escalation notice**:
```
## Escalation Needed

**Instance**: <instance-id>
**Work Unit**: <work-unit-id>
**Blocker**: <description>

**What was tried**:
- <attempt 1>
- <attempt 2>

**Decision needed**: <clear question or options>

/cc @<escalation-target>
```

**Status update** (significant milestones):
```
**Status**: <status>
**Instance**: <instance-id>

<brief description of what happened>
```

**Review feedback** (from reviewer agent):
```
## Review: <pass | revision-needed>

**Reviewer**: <instance-id>

<findings, organized by severity>
```

## When to comment

- Escalation is triggered
- Work unit transitions to a new status
- Peer review completes (pass or fail)
- L1 revision is requested or completed
- Work unit is paused or released
