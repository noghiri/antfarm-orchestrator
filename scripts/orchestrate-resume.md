# orchestrate resume — Resume or Switch Projects

Resume a previously started project or switch the active project.

## Usage

```
orchestrate resume --project <project-slug> [--feature <feature-id>]
```

## What it does

1. Look up the project in `projects.json`
2. Read the state file (`state/<project-slug>.json`)
3. Run `reconcile-state` to sync with GitHub Issue state
4. If `--feature` is specified, scope this instance to that feature
5. Start the orchestrator at the current `stage` from the state file

## Listing projects

```
orchestrate list
```

Reads `projects.json` and outputs all registered projects with their current stage.

## Project switching

When switching from one project to another:
1. The current project's state file is saved (no action needed — it persists)
2. The new project's state file is loaded
3. `reconcile-state` is run for the new project
4. The orchestrator resumes at the new project's current stage
