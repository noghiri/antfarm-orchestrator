# Pause at Boundary

Pause the orchestrator at the current stage boundary. Used when an L1 revision is needed, a human-initiated pause is requested, or a cross-cutting escalation requires all instances to stop.

## When to pause

- An escalation requires a change to L1 planning documents (project charter, system design, or feature registry)
- The human explicitly requests a pause
- A critical conflict between features is discovered that requires re-planning

## Pause procedure

1. **Do not start any new work units.** Finish the current atomic action (if mid-operation), then stop.

2. **Release all claimed work units** for this instance:
   - Use `list-issues` to find all issues with `claimed-by/<instance-id>`
   - For each: use `release-work-unit` with `status/paused`
   - Post a comment on each work unit issue: "Paused: [reason]. Will resume after [condition]."

3. **Update the state file**:
   - Set `paused: true`
   - Set `pause_reason: "<reason>"`
   - Save the state file

4. **Notify the human**:
   - If a pause is due to an L1 revision need, include the revision summary
   - Specify what condition must be met to resume (escalation resolved, PR merged, human confirmation)

## Multi-instance pause (L1 revision)

When an L1 revision is needed, ALL instances must pause, not just the triggering instance. The orchestrator coordinates this:

1. Post a pause notice to all open work unit issues with `status/in-progress`:
   ```
   [L1 REVISION IN PROGRESS] All work is paused pending an update to planning documents.
   Issue: <escalation issue number>
   Waiting for: <PR to be merged | human decision>
   ```
2. Release all claims across all instances.
3. Wait for the L1 revision to be merged.

## Resume procedure

To resume after a pause:
1. Verify the pause condition is resolved (PR merged, escalation answered).
2. Run `reconcile-state` to re-sync with GitHub Issue state.
3. Set `paused: false`, clear `pause_reason` in the state file.
4. Re-enter the building loop: pick up unclaimed work units in dependency order.

## Boundary respect

The orchestrator only pauses at stage boundaries — between work units, not mid-work-unit. If a pause request arrives mid-work-unit, complete the current work unit first, then pause.

Exception: if the pause is triggered by an L1 revision that contradicts the current work unit's spec, stop immediately and release the claim.
