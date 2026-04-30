---
description: Fetch full details of a GitHub Issue. Read-only; no dry-run required. Load when you need to read a work unit spec, check claim status, or determine work unit state from labels.
user-invocable: false
allowed-tools:
  - "Bash(gh issue view *)"
---
# Get Issue

Fetch the full details of a GitHub Issue using the `gh` CLI. Read-only; no dry-run required.

## Usage

```sh
gh issue view <number> --json title,body,labels,assignees,state
```

## Parsing the result

The output is JSON. Extract:
- `title` — issue title
- `body` — full issue body (work unit spec or escalation summary)
- `labels[].name` — all current labels
- `assignees[].login` — current assignees
- `state` — `OPEN` or `CLOSED`

## Work unit state from labels

Determine work unit state by reading the `status/*` label. If multiple `status/*` labels are present (should not happen), report the conflict and escalate.

## Claim check

To check if a work unit is already claimed, look for a `claimed-by/*` label. Extract the instance ID from the label name.

## Usage in context assembly

When assembling context for an agent, fetch the work unit issue to include the full spec and current state in the context. Use the body as the authoritative work unit spec — it should be kept in sync with the Feature Design document.
