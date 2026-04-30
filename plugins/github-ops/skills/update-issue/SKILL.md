---
description: Update a GitHub Issue's state, body, labels, or assignee. Mutating operation — invoke explicitly with dry-run by default and --execute to apply.
disable-model-invocation: true
allowed-tools:
  - "Bash(gh issue edit *)"
  - "Bash(gh issue close *)"
  - "Bash(gh issue reopen *)"
---
# Update Issue

Update a GitHub Issue's state, body, labels, or assignee using the `gh` CLI. All mutations must respect dry-run mode.

## Dry-run (default)

Output what would change:

```
[dry-run] would update issue #<number>:
  state: open → closed   (if closing)
  add labels: <labels>
  remove labels: <labels>
  assignee: <username>   (if changing)
```

## Live execution

Only when `--execute` is explicitly confirmed:

```sh
# Close an issue
gh issue close <number>

# Reopen an issue
gh issue reopen <number>

# Edit body
gh issue edit <number> --body "<new body>"

# Add labels
gh issue edit <number> --add-label "<label>"

# Remove labels
gh issue edit <number> --remove-label "<label>"

# Add assignee
gh issue edit <number> --add-assignee "<username>"

# Remove assignee
gh issue edit <number> --remove-assignee "<username>"
```

Multiple edits can be combined in a single `gh issue edit` call.

## Work unit state transitions

When updating a work unit issue to reflect stage progress, use `label-ops` to change the `status/*` label simultaneously. Keep the issue body in sync with the latest work unit spec if it changes.
