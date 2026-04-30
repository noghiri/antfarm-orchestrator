# Claim Work Unit

Claim a work unit GitHub Issue for this instance, preventing other instances from picking it up.

## Claiming protocol

1. Read the issue to verify it is in `status/planned` state and has no `claimed-by/*` label.
2. If already claimed by another instance, do not claim — skip to the next available work unit.
3. If unclaimed, perform the claim atomically:
   - Add label `claimed-by/<instance-id>` (e.g., `claimed-by/alice-myproject-feature`)
   - Add label `status/in-progress`
   - Remove label `status/planned`
   - Assign to the instance GitHub username
4. After claiming, re-read the issue to confirm the labels are present. If another instance also claimed it simultaneously (race condition), the last writer wins on labels but the issue body will show both assignments. In this case, release and pick a different work unit.

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
