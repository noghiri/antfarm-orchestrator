---
description: Reload orchestrator context from durable state after a compaction or session restart. Load when resuming after /compact or orchestrate resume, or whenever you need to verify your working picture is current.
user-invocable: false
allowed-tools:
  - Read
  - "Bash(gh issue list *)"
  - "Bash(gh issue view *)"
---
# Context Reload

Reload your complete working picture from durable state. This procedure is identical to the startup procedure and is safe to run at any point — it reads from files and GitHub, never from conversation history.

## When to run

- After `/compact` or `orchestrate resume` (automatically, as part of startup)
- When you suspect your in-memory picture of feature or work unit status may be stale
- When resuming after a pause or L1 revision

## Reload procedure

1. **Read the state file** — `<project-dir>/.orchestrator/state.json`
   - Current stage
   - Feature statuses and active claims
   - Pause state and reason (if paused)
   - L1 revision tracking (if active)

2. **Read the project config** — `<project-dir>/.orchestrator/project.yaml`
   - GitHub owner/repo
   - Toolchain (build, test, lint commands)
   - CI settings
   - Escalation target

3. **Inventory planning documents** — check which documents exist in the target repo's planning branch and note their approval status (read frontmatter only via `doc-ops/parse-frontmatter`, do not load full content):

   L1 documents (one per project, in `docs/project/` on the planning branch):
   - `project-charter.md` — exists? status: draft / approved?
   - `system-design.md` — exists? status?
   - `feature-registry.md` — exists? status?

   L2 documents (one per feature, in `docs/features/<feature-id>/`):
   - `feature-design.md` — exists? status? (check for each feature in the registry)

   This inventory tells you what planning work has been completed and which documents sub-agents can be given. Do not load full document content into the orchestrator's own context — pass documents to sub-agents via `workflow-utils/context-assembly` when spawning them.

4. **Run `workflow-utils/reconcile-state`** — sync local state against GitHub Issues
   - Detects abandoned claims from the previous session
   - Detects work units completed by other instances
   - Surfaces pending escalations

5. **Rebuild the feature picture** — if in the building stage:
   - Run `workflow-utils/dependency-graph` to refresh the execution order
   - Note which features are ready (dependencies complete), in progress, or blocked

6. **Surface any pending escalations** to the human before resuming work.

## What you do NOT need to reload

- Conversation history — all critical state is in files and GitHub; the conversation is ephemeral
- Full planning document content — the orchestrator only needs the document inventory (which exist, which are approved). Full content is loaded by sub-agents via `workflow-utils/context-assembly`

## Output

After reload, state aloud:
```
Context reloaded.
  Project: <slug>  Stage: <stage>
  Features: <N ready, N in-progress, N complete>
  Pending escalations: <N>
```

Then resume from the current stage without waiting for human confirmation.
