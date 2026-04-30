# Release Work Unit

Release a previously claimed work unit, allowing another instance to pick it up or returning it to the available pool.

## When to release

- Work unit is complete (transition to `status/complete` after peer review passes)
- Work unit is paused due to an escalation (`status/blocked`)
- Work unit is paused because an L1 revision is in progress (`status/paused`)
- This instance is shutting down or reassigning

## Release protocol

1. Determine the new status label:
   - Complete: `status/complete`
   - Blocked/escalated: `status/blocked`
   - Paused (L1 revision): `status/paused`
   - Released back to pool: `status/planned`
2. Remove the `claimed-by/<instance-id>` label.
3. Remove the `status/in-progress` label.
4. Add the appropriate new status label.
5. Remove the assignee.
6. If pausing, post a comment explaining why the work unit is paused.

## Dry-run (default)

```
[dry-run] would release issue #<number>:
  remove labels: claimed-by/<instance-id>, status/in-progress
  add labels: <new-status-label>
  remove assignee: <github-username>
```

## Label cleanup

At the end of a completed work unit (after peer review passes and the PR is merged), run a label cleanup to remove any transient labels: all `claimed-by/*`, `status/in-progress`, `escalation-needed`. This is the final step before closing the issue.
