---
description: Claim a work unit GitHub Issue for this instance using label-based locking. Invoke explicitly before starting a work unit to prevent multi-instance conflicts. Dry-run by default.
disable-model-invocation: true
allowed-tools:
  - "Bash(gh issue view *)"
  - "Bash(gh issue edit *)"
---
# Claim Work Unit

Claim a work unit GitHub Issue for this instance, preventing other instances from picking it up.

## Claiming protocol

1. **Verify feature scope.** Check that the issue carries the `feature/<feature-id>` label matching this instance's assigned feature (from the `--feature` flag at startup). If the label does not match, do not claim — this work unit belongs to a different instance's scope.
2. Read the issue to verify it is in `status/planned` state and has no `claimed-by/*` label.
3. If already claimed by another instance, do not claim — skip to the next available work unit within this feature.
4. If unclaimed and in scope, perform the claim:
   - Add label `claimed-by/<instance-id>` (e.g., `claimed-by/alice-myproject-f001`)
   - Add label `status/in-progress`
   - Remove label `status/planned`
   - Assign to the instance GitHub username
5. After claiming, re-read the issue to confirm only this instance's `claimed-by/*` label is present. If multiple `claimed-by/*` labels are present (race condition), follow the race resolution protocol in `workflow-utils/multi-instance`.

## Instance ID format

The instance ID used in the `claimed-by` label is: `<github-username>/<project-slug>/<feature-slug>`, with `/` replaced by `-` in the label name.

Example: `claimed-by/alice-myproject-f001`

## Dry-run (default)

```
[dry-run] would claim issue #<number>:
  add labels: claimed-by/<instance-id>, status/in-progress
  remove labels: status/planned
  assignee: <github-username>
```

## Live execution

Only when `--execute` is confirmed. Use `update-issue` and `label-ops` to apply the changes.
