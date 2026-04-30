# Multi-Instance Coordination

Rules for running multiple orchestrator instances against the same project simultaneously.

## Instance identity

Each instance has a unique identity derived from:
```
<github-username>/<project-slug>/<feature-slug>
```

In label form (replace `/` with `-`):
```
claimed-by/alice-myproject-f001
```

The feature-slug component scopes this instance to one feature. **Instances should stay scoped to a single feature** — this keeps context clean and prevents conflicts.

## Feature scoping

Each instance should be started with a specific feature assignment:
- `orchestrate resume --project <slug> --feature F001`

An instance scoped to F001 should only claim work units for F001. If F001 is complete and F002 is now ready (its dependency on F001 is satisfied), a new instance should be started for F002, or the F001 instance can be re-scoped with human approval.

## Claim races

Work unit claiming uses GitHub Issue labels as a distributed mutex. The claiming protocol (`claim-work-unit`) is:
1. Check that no `claimed-by/*` label exists
2. Add `claimed-by/<instance-id>` label
3. Re-read the issue to confirm the label is present

If two instances claim the same issue simultaneously, both will add their `claimed-by/*` labels. The correct behavior after a race:
- Both instances re-read the issue
- If multiple `claimed-by/*` labels are present, this is a race condition
- The instance whose label appears **first alphabetically** yields: it removes its own `claimed-by/*` label and picks a different work unit
- The other instance proceeds

## Cross-instance communication

Instances communicate through GitHub Issues:
- **Status**: work unit issue labels (`status/*`, `claimed-by/*`)
- **Escalations**: `escalation-needed` label on issue; comment with details
- **Pause notices**: comment on work unit issues when pausing

Instances do not communicate directly. The GitHub Issue is the canonical shared state.

## L1 revision and all-instance pause

When an L1 revision is needed:
1. The orchestrator instance that discovered the need posts a pause notice to ALL open work unit issues
2. All instances detecting this notice release their claims on next startup (via `reconcile-state`)
3. No new claims are made until the `l1_revision` field in the state file is cleared

Instances detect an active L1 revision by checking their local state file's `l1_revision` field. If non-null, they do not claim new work and wait for it to clear.

## Single-user (single-instance) mode

For a single-user single-instance setup:
- Instance scoping rules still apply (clean context per feature)
- Claim races cannot occur
- L1 revision pause is immediate (only one instance to pause)
- The orchestrator is re-instantiated for each feature with a fresh context
