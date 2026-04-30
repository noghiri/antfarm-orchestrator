---
description: L1 planning document revision workflow. Invoke explicitly when route-escalations determines a change to docs/project/ is required. Pauses all instances, creates a revision branch and PR, waits for human merge.
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - "Bash(git checkout *)"
  - "Bash(git pull *)"
  - "Bash(git add *)"
  - "Bash(git commit *)"
  - "Bash(gh pr create *)"
  - "Bash(gh issue comment *)"
---
# L1 Revision Workflow

Manage the process of updating L1 planning documents (project charter, system design, feature registry) in response to an escalation. All L1 revisions require a PR on the planning branch and explicit human approval before merging.

## When to trigger

L1 revision is triggered when `route-escalations` determines that an escalation requires changing a document in `docs/project/` (the planning branch). This includes:

- An architectural assumption is wrong and the system design must change
- A new major feature must be added to the feature registry
- A project-level constraint changes (scope, technology, etc.)
- A cross-feature conflict requires re-planning at the feature registry level

## Revision procedure

### 1. Pause all instances

Run `pause-at-boundary` to release all claims and notify all work unit issues:

```
[L1 REVISION IN PROGRESS]
A change to planning documents is required. All work is paused.
Revision: <one-line description of the change>
Tracking issue: #<escalation-issue-number>
```

Update the state file: set `l1_revision.pr_number` to pending, `l1_revision.reason` to the description.

### 2. Create a revision branch

Branch from the current `planning` branch:

```sh
git checkout planning
git pull origin planning
git checkout -b planning-revision-r<N>
```

Where `N` is the current revision number + 1.

### 3. Draft the revision

Work with the human to draft the changes to the affected L1 document(s):
- Use the `system-planner` behavioral mode for this conversation
- Validate the revised document with `validate-doc` before opening the PR
- Do not change `status` to `approved` — that happens after human review

### 4. Open the PR

Use `create-pr`:
- **Base**: `planning`
- **Head**: `planning-revision-r<N>`
- **Title**: `[L1 revision r<N>] <brief description>`
- **Labels**: `planning`, `l1-revision`, `needs-human-review`
- **Body**:
  ```
  ## L1 Revision r<N>

  **Reason**: <escalation summary>
  **Tracking issue**: #<escalation-issue-number>

  ### Changes
  <summary of what changed and why>

  ### Impact on active features
  <which features are affected and how>

  **Human review required before merging.**
  ```

Update the state file: `l1_revision.pr_number = <PR number>`.

### 5. Wait for human review

Do not proceed. Notify the human via the terminal:

```
L1 REVISION PR OPENED: #<PR-number>

Please review the changes at: <PR URL>
When approved, merge the PR and confirm here to resume.
```

### 6. After PR is merged

When the human confirms the PR is merged:
1. Clear `l1_revision` in the state file (`null`)
2. Run `reconcile-state` to check for feature designs that are now stale
3. For each stale feature design: notify the human and offer to re-run the Feature Design stage for that feature
4. Run `pause-at-boundary` in reverse: resume building for features that are unaffected
5. For affected features: re-plan before resuming

### 7. Downstream impact check

After an L1 revision, check whether any feature designs reference the changed decisions (`depends_on_decisions` field). Feature designs that reference changed decisions must be reviewed and potentially re-approved before their work units can resume.
