---
description: Multi-instance coordination rules for running parallel orchestrator instances. Load when configuring a multi-instance setup or resolving claim race conditions. Covers instance identity, feature scoping, and L1 pause protocol.
user-invocable: false
---
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

Each instance must be started with a specific feature assignment:
- `orchestrate resume --project <slug> --feature F001`

**Feature-boundary claiming is the primary exclusion mechanism.** Each instance claims all work units for its assigned feature and works through them sequentially. Other instances never touch work units belonging to a feature they are not assigned to. This prevents the work-unit-level race conditions that would arise if instances competed for individual issues.

The feature scope is enforced by `claim-work-unit`: before claiming any issue, the skill verifies that the issue carries the correct `feature/<feature-id>` label for this instance's assigned feature. If it does not, the claim is skipped regardless of availability.

If a feature is complete and F002 is now ready, a new instance should be started for F002, or the existing instance can be re-scoped with human approval.

**Starting two instances scoped to the same feature is a configuration error.** The `orchestrate resume --feature <id>` command should be invoked at most once per feature at a time. If it happens accidentally, the claim-race resolution below applies, but prevention is preferred.

## Claim races

Feature-boundary claiming makes races rare (two instances would have to be incorrectly assigned the same feature simultaneously). The residual race protocol:

Work unit claiming uses GitHub Issue labels as a distributed mutex:
1. Check that no `claimed-by/*` label exists on the issue
2. Add `claimed-by/<instance-id>` label
3. Re-read the issue to confirm only this instance's label is present

If two instances somehow claim the same issue simultaneously (both labels present):
- The instance whose label appears **first alphabetically** yields: remove its own `claimed-by/*` label and pick a different work unit
- The other instance proceeds
- Surface the race as a warning to the human

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
