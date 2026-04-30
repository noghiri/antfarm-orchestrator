---
description: Create a GitHub Issue for a work unit or escalation. Mutating operation — invoke explicitly with dry-run by default and --execute to apply. Requires gh CLI authentication.
disable-model-invocation: true
allowed-tools:
  - "Bash(gh issue create *)"
  - "Bash(gh auth status)"
---
# Create Issue

Create a GitHub Issue using the `gh` CLI. All issue creation is a mutating operation and must respect dry-run mode.

## Prerequisites

- `gh` CLI must be authenticated (`gh auth status` must succeed)
- The working directory must be inside the target repository, or `--repo owner/name` must be specified

## Dry-run (default)

Before creating an issue, output what would be created:

```
[dry-run] would create issue:
  title: <title>
  labels: <labels>
  body: <first 200 chars of body>
```

Do not call `gh issue create` in dry-run mode.

## Live execution

Only when `--execute` is explicitly confirmed:

```sh
gh issue create \
  --title "<title>" \
  --body "<body>" \
  --label "<label1>" \
  --label "<label2>" \
  --assignee "<github-username>"
```

## Work unit issues

When creating an issue for a work unit, include:
- **Title**: `[WU] <feature-id>/<work-unit-id>: <work-unit-name>`
- **Labels**: `work-unit`, `feature/<feature-id>`, `status/planned`
- **Body**: the full work unit spec from the Feature Design document
- **Assignee**: the instance identity username (if claiming immediately)

## Escalation issues

When creating an issue to track an escalation:
- **Title**: `[ESCALATION] <brief description>`
- **Labels**: `escalation-needed`, `feature/<feature-id>` (if feature-scoped)
- **Body**: escalation summary including what was tried and what decision is needed
