---
description: Revision workflow for L1 planning documents (project charter, system design, feature registry) and cross-feature revisions to an already-approved Feature Design. Invoke explicitly when route-escalations determines a change to an approved planning document is required. Pauses affected work, hands the actual drafting off to the matching stage session, and waits for human merge before resuming.
allowed-tools:
  - Read
  - Write
  - "Bash(git checkout *)"
  - "Bash(git pull *)"
---
# L1 Revision Workflow

Manage the process of revising an already-approved planning document in response to an escalation: `project-charter.md`, `system-design.md`, `feature-registry.md` (all L1, on the `planning` branch), or a specific feature's `feature-design.md` (L2, cross-feature-scoped).

The coordinator never drafts the revision itself — that would put it back in the planning-document-authoring business it explicitly stays out of. This skill's job is to pause the right scope, record the revision request in the state file, and exit — the harness then launches the matching stage session (`charter`, `system-design`, `feature-registry`, or `feature-design`), which reads the revision request at startup and conducts the actual revision conversation with the human.

## When to trigger

Triggered when `route-escalations` determines an escalation requires changing an already-approved planning document. This includes:

- An architectural assumption is wrong and the system design must change
- A new major feature must be added to the feature registry
- A project-level constraint changes (scope, technology, etc.)
- A cross-feature conflict that can only be resolved by re-planning at the feature registry level
- A feature's already-approved Feature Design must change because of a discovery made in a different feature (e.g. an output contract needs to change) — this is L2-scoped but still requires the same controlled revision process, never a direct ad-hoc edit

## Determine the target and scope

1. Identify which document actually needs to change: `project-charter`, `system-design`, `feature-registry`, or a specific feature's `feature-design` (in which case also identify the feature ID).
2. Determine the pause scope:
   - **L1 target** (`project-charter`, `system-design`, `feature-registry`): affects potentially every feature. Run `pause-at-boundary` for **all** instances.
   - **feature-design target**: scoped to the affected feature. Release claims and post pause notices only for that feature's in-progress work units (reuse `pause-at-boundary`'s per-issue release/notify steps, scoped to `feature/<feature-id>` rather than every open issue).
3. Check whether the target feature (or, for an L1 target, any feature identified as affected) is already `status/complete` in `active_features` or on its GitHub Issues. A feature already marked complete does not become correct again just because nobody is actively working on it — if this revision changes anything it depends on, **reopen it**: set its `active_features` status back to `building` (or `designing`, if the Feature Design itself is what's being revised) and remove `status/complete` from its work unit issues that the change actually touches. Do not leave a feature marked complete once an escalation has established that its approved design or implementation no longer reflects reality.

## Revision procedure

### 1. Pause the determined scope

Follow the pause procedure above. Post to the affected work unit issue(s):

```
[REVISION IN PROGRESS] A change to <target> is required. Affected work is paused.
Revision: <one-line description of the change>
Tracking issue: #<escalation-issue-number>
```

### 2. Prepare the branch (L1 targets only)

L1 targets are revised on a dedicated branch, separate from normal planning-stage writes, because building may already be underway on top of the current approved docs:

```sh
git checkout planning
git pull origin planning
git checkout -b planning-revision-r<N>
```

Where `N` is the current revision number + 1 (track via `l1_revision.branch` from any prior revision, or start at 1).

A `feature-design` target does not need a new branch — it is revised directly on its existing `feature/<feature-id>-<slug>` branch, same as its original design.

### 3. Write the revision request and hand off

Write to the state file:

```json
"l1_revision": {
  "target": "<project-charter|system-design|feature-registry|feature-design>",
  "target_feature": "<feature-id, only when target is feature-design, else null>",
  "reason": "<escalation summary>",
  "tracking_issue": <escalation-issue-number>,
  "branch": "<planning-revision-r<N>, only for L1 targets, else null>",
  "pr_number": null,
  "initiated_at": "<ISO timestamp>"
}
```

Set `next_session` to the session matching `target` (`"charter"` for `project-charter`, `"system-design"`, `"feature-registry"`, or `"feature-design"`). If `target` is `feature-design`, also set `current_feature` to `target_feature`.

### 4. Exit

Tell the human: _"Revision request recorded for [target]. Press Ctrl+C or run `/exit` to end this session — the harness will launch the [target] session with the revision context loaded."_ Do not draft anything yourself. Wait for the human to exit.

## What happens next (for context — not this skill's job)

The target stage session reads `l1_revision` at startup, presents the reason to the human instead of running fresh intake, and revises just the affected content. For L1 targets, it opens a PR (base `planning`, head the revision branch) instead of committing straight to `planning`, and the coordinator waits for human confirmation that the PR is merged before resuming. For a `feature-design` target, it follows the normal Feature Design completion flow (direct commit to the feature branch, no separate PR) since the feature branch was never assumed stable to begin with.

## After an L1 PR is merged

When the human confirms an L1 revision PR is merged (handled by the coordinator's revision gate check, not this skill directly):
1. Clear `l1_revision` in the state file.
2. Run `reconcile-state` to check for feature designs that are now stale (`depends_on_decisions` references a changed decision).
3. For each stale feature design: notify the human and offer to trigger this same workflow again, scoped to that feature (`target: "feature-design"`).
4. Resume building for features that are unaffected.
