---
description: Add and remove labels on GitHub Issues and Pull Requests. Invoke explicitly for status transitions, claim operations, and label cleanup. Dry-run by default. Reference for the full label taxonomy.
disable-model-invocation: true
allowed-tools:
  - "Bash(gh issue edit *)"
  - "Bash(gh label create *)"
  - "Bash(gh label list *)"
---
# Label Operations

Add and remove labels on GitHub Issues and Pull Requests using the `gh` CLI.

## Standard label taxonomy

**Status labels** (mutually exclusive — only one at a time):
- `status/planned` — work unit not yet started
- `status/in-progress` — actively being worked
- `status/blocked` — waiting on escalation resolution
- `status/paused` — paused due to L1 revision
- `status/review` — in peer review
- `status/complete` — done, peer review passed
- `status/cancelled` — will not be implemented

**Feature labels**:
- `feature/F001`, `feature/F002`, etc.

**Type labels**:
- `work-unit` — a work unit issue
- `planning` — a planning document PR
- `l1-revision` — an L1 planning update PR
- `escalation-needed` — requires human decision
- `needs-human-review` — requires human review before merge
- `needs-review` — requires peer review

**Claimed-by labels** (instance identity):
- `claimed-by/<instance-id>` — e.g., `claimed-by/alice-myproject-f001`

## Dry-run (default)

```
[dry-run] would update labels on #<number>:
  add: <labels>
  remove: <labels>
```

## Live execution

Only when `--execute` is confirmed:

```sh
gh issue edit <number> --add-label "<label>" --remove-label "<label>"
```

## Creating labels

If a required label does not exist in the repo, create it first:

```sh
gh label create "<name>" --color "<hex>" --description "<description>"
```

Required labels should be created by `orchestrate new` during project initialization. Do not create labels ad-hoc during work unit execution.
