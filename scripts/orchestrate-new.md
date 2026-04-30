# orchestrate new — New Project Setup

The `orchestrate new` command initializes a new project and starts the orchestrator. It is the entry point for the entire system.

## Usage

```
orchestrate new --project <project-slug> --repo <github-owner/repo> --github-user <username>
```

## What it does

### 1. Create the project config

Copy `docs/templates/project.yaml` to `state/projects/<project-slug>/project.yaml`. Prompt the user to fill in:
- `name` — human-readable project name
- `slug` — URL-safe identifier (derived from name by default)
- `github.owner` and `github.repo` — target GitHub repository
- `ci.enabled` / `ci.required` — whether CI must pass
- `toolchain` — language, build, test, lint commands
- `orchestrator.escalation_target` — GitHub username or @handle

### 2. Initialize the local state file

Copy `docs/templates/state-file.json` to `state/<project-slug>.json`. Set:
- `project_slug` — from project config
- `github_username` — from `--github-user` flag or `gh api user --jq .login`
- `instance_id` — `<github-username>-<project-slug>`
- `stage` — `"planning/charter"`
- `escalation_target` — from project config

### 3. Register the project

Add an entry to `projects.json` (in the orchestrator root — gitignored):
```json
{
  "projects": {
    "my-project": {
      "slug": "my-project",
      "config": "state/projects/my-project/project.yaml",
      "state": "state/my-project.json",
      "repo": "github-owner/my-project"
    }
  }
}
```

### 4. Set up GitHub labels in the target repo

Create the required labels in the target GitHub repository using `gh label create`. This requires write access to the repo.

Labels to create (dry-run first, then `--execute` to apply):

```sh
# Status labels
gh label create "status/planned"      --color "0075ca" --description "Work unit not yet started"
gh label create "status/in-progress"  --color "e4e669" --description "Actively being worked"
gh label create "status/blocked"      --color "d93f0b" --description "Waiting on escalation resolution"
gh label create "status/paused"       --color "cfd3d7" --description "Paused due to L1 revision"
gh label create "status/review"       --color "a2eeef" --description "In peer review"
gh label create "status/complete"     --color "0e8a16" --description "Done, peer review passed"
gh label create "status/cancelled"    --color "cfd3d7" --description "Will not be implemented"

# Type labels
gh label create "work-unit"           --color "bfd4f2" --description "Work unit issue"
gh label create "planning"            --color "d4c5f9" --description "Planning document PR"
gh label create "l1-revision"         --color "f9d0c4" --description "L1 planning update PR"
gh label create "escalation-needed"   --color "b60205" --description "Requires human decision"
gh label create "needs-human-review"  --color "f9d0c4" --description "Requires human review before merge"
gh label create "needs-review"        --color "0075ca" --description "Requires peer review"
```

Feature labels (`feature/F001`, etc.) are created when the Feature Registry is approved.

### 5. Set up the planning branch

```sh
cd <target-repo-path>
git checkout -b planning
git push origin planning
```

If the planning branch already exists, skip this step.

### 6. Start the orchestrator

Load the orchestrator system prompt (`prompts/orchestrator.md`) and start a Claude Code session scoped to the target repository:

```
Claude Code session starts with:
  - CLAUDE.md: prompts/orchestrator.md
  - Mode: orchestrator preset
  - Working directory: <target-repo-path>
  - State file: state/<project-slug>.json
```

The orchestrator begins at `stage: planning/charter` and spawns a `system-planner` agent to start the Project Charter conversation.

## Dry-run behavior

Run with `--dry-run` (default) to see what would be created without making any changes:

```
[dry-run] would create:
  - state/my-project.json (local state file)
  - state/projects/my-project/project.yaml (project config)
  - projects.json entry for "my-project"
  - 14 GitHub labels in github-owner/my-project
  - planning branch in github-owner/my-project

Run with --execute to apply.
```
