---
description: List GitHub Issues filtered by label, state, or assignee. Read-only; no dry-run required. Load when discovering available work units, checking escalations, or reconciling instance state on startup.
user-invocable: false
allowed-tools:
  - "Bash(gh issue list *)"
---
# List Issues

List GitHub Issues filtered by label, state, or assignee. Read-only; no dry-run required.

## Usage

```sh
gh issue list \
  --label "<label>" \
  --state open \
  --json number,title,labels,assignees \
  --limit 100
```

Multiple `--label` flags act as AND (all labels must be present).

## Common queries

**Find available work units for a feature**:
```sh
gh issue list --label "work-unit" --label "feature/F001" --label "status/planned" --state open
```

**Find all in-progress work units**:
```sh
gh issue list --label "work-unit" --label "status/in-progress" --state open
```

**Find escalations needing attention**:
```sh
gh issue list --label "escalation-needed" --state open
```

**Find work claimed by this instance**:
```sh
gh issue list --label "claimed-by/<instance-id>" --state open
```

## Cold-start reconciliation

On instance startup, run `list-issues` to discover work this instance previously claimed (by `claimed-by/<instance-id>` label). Reconcile against local state to determine whether to resume or release abandoned claims.

## Dependency-ordered work selection

When selecting the next work unit to claim, prefer work units where all `depends-on` work units are in `status/complete`. Use `list-issues` to check dependency state before claiming.
