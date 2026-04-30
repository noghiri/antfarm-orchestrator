# Reconcile State

On orchestrator startup (cold start), reconcile the local state file against GitHub Issues to detect inconsistencies from a previous session. Run this before starting any new work.

## Reconciliation procedure

1. Read the local state file (`state/<project-slug>.json`).
2. Fetch all open issues with the `work-unit` label using `list-issues`.
3. Also fetch issues with `claimed-by/<instance-id>` (this instance's previous claims).

### Consistency checks

For each issue this instance previously claimed:

**Scenario A: Issue still has `claimed-by/<instance-id>` and `status/in-progress`**
- The previous session ended without releasing the claim.
- Action: Resume the work unit, or release and re-queue if context was lost.
- Surface to the human: "Resuming previously claimed WU-N" or "Releasing abandoned claim on WU-N".

**Scenario B: Issue has `claimed-by/<instance-id>` but `status/complete` or `status/review`**
- The work unit was completed or sent for review in the previous session.
- Action: No action needed; remove stale claim from local state.

**Scenario C: Issue has no `claimed-by` label but local state shows it was in-progress**
- Another instance or manual action released the claim.
- Action: Do not re-claim; update local state to reflect the current issue state.

**Scenario D: Local state references an issue that no longer exists or is closed**
- The issue was closed manually or the work unit was cancelled.
- Action: Remove from local state and skip.

### Pending escalations

Check for open issues with `escalation-needed`. If any exist for this instance's features, summarize them to the human before starting new work.

## Output

```
RECONCILIATION COMPLETE:
  Resumed: WU-003 (issue #42)
  Released: WU-007 (issue #51) — no context, re-queued as status/planned
  Skipped: WU-009 (issue #55) — closed
  Pending escalations: 1 (issue #48)
```

Surface escalations to the human immediately after reconciliation.
