---
description: Create a GitHub Pull Request for a work unit branch or planning revision. Mutating, publicly visible operation — invoke explicitly with dry-run by default and --execute to apply.
disable-model-invocation: true
allowed-tools:
  - "Bash(gh pr create *)"
---
# Create Pull Request

Create a GitHub Pull Request using the `gh` CLI. This is a mutating, visible operation — always dry-run by default.

## Dry-run (default)

Output what would be created:

```
[dry-run] would create PR:
  title: <title>
  base: <base-branch>
  head: <head-branch>
  labels: <labels>
  body: <first 200 chars of body>
```

## Live execution

Only when `--execute` is explicitly confirmed:

```sh
gh pr create \
  --title "<title>" \
  --body "<body>" \
  --base "<base-branch>" \
  --head "<head-branch>" \
  --label "<label>"
```

## Planning branch PRs (L1 updates)

When creating a PR for a planning branch L1 update:
- **Base**: `planning`
- **Head**: `planning-revision-r<N>` (or equivalent)
- **Title**: `[L1 revision r<N>] <brief description of change>`
- **Labels**: `planning`, `l1-revision`, `needs-human-review`
- **Body**: summary of what changed and why; link to the triggering escalation issue

Human review is required before merging. Do not auto-merge planning branch PRs.

## Feature branch PRs (code)

When creating a PR for a completed work unit:
- **Base**: `feature/<feature-id>-<feature-slug>` (or `main` if this is the final integration)
- **Head**: work unit branch
- **Title**: `[<feature-id>/WU-<N>] <work-unit-name>`
- **Labels**: `work-unit`, `feature/<feature-id>`, `needs-review`
- **Body**: links to the work unit issue, summary of implementation, test results

Two-key gate: peer review approval AND tests passing before merge.
