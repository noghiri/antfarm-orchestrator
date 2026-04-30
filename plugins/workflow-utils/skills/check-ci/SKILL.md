---
description: Check CI status for a branch using the gh CLI. Load at work unit completion gates when ci_required is true in project.yaml. Blocks on CI failure; skips when CI is not configured.
user-invocable: false
allowed-tools:
  - "Bash(gh run list *)"
  - "Bash(gh run watch *)"
  - Read
---
# Check CI

Check the CI status for a branch or commit using the `gh` CLI. Used at the work unit completion gate when `ci_required` is true in the project config.

## When CI is relevant

CI checking is only performed when `ci.enabled: true` and `ci.required: true` in `project.yaml`. If either is false, skip this check and note that CI was not verified.

## Usage

```sh
# Check status of the most recent run on a branch
gh run list --branch <branch-name> --limit 1 --json status,conclusion,url

# Wait for the current run to complete (with timeout)
gh run watch <run-id> --exit-status
```

## Status interpretation

- `completed` + `conclusion: success` → CI passes, proceed
- `completed` + `conclusion: failure` → CI fails, block; report failures to the builder
- `completed` + `conclusion: cancelled` → Trigger a new run if possible; escalate if not
- `in_progress` or `queued` → Wait (with a reasonable timeout); report if timeout exceeded

## Output

**CI passes**:
```
CI STATUS: pass
  Run: <run-url>
  Branch: <branch>
  Duration: <duration>
```

**CI fails**:
```
CI STATUS: fail
  Run: <run-url>
  Branch: <branch>
  Failed jobs: <job names>
  
  This is a hard block. Resolve CI failures before merging.
```

## CI not configured

```
CI STATUS: skipped (ci.required: false in project.yaml)
```

## Reporting

Always include the CI status (even if skipped) in the work unit completion checklist comment posted to the GitHub Issue.
