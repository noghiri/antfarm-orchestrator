# Task 5 — Redesign Planning Stage for Per-Stage Interactive Sessions

## Why this change is being made

During a smoketest, the system-planner agent skipped the intake conversation entirely and jumped straight to drafting a project charter with assumed requirements. Root cause investigation (Task 4) confirmed this is an architectural constraint, not a prompt quality problem:

- Sub-agents spawned via the Claude Code `Agent` tool are **fire-and-forget**. They run autonomously and return a single result.
- `AskUserQuestion` is **not available to sub-agents** — it is stripped regardless of configuration because it depends on the main session's UI state.
- The `intake/SKILL.md` procedure (ask → wait → ask → wait → summarize → confirm → draft) **cannot execute inside a sub-agent**. There is no mechanism for mid-flight human interaction.

The intake skill improvements made in Task 3 are correct and should be kept — but they only take effect once intake runs at a level where human interaction is possible.

## Decisions made

| Decision | Choice | Rationale |
|---|---|---|
| Per-stage sessions vs. long-running orchestrator | Per-stage sessions | Only top-level sessions support interactive back-and-forth |
| Stage advancement trigger | Harness blocks on child process exit, reads state file, auto-chains | Simple, no watchers, failure mode is graceful (state always in file, `resume` always works) |
| Coordination logic placement | Thin coordinator session between work sessions | Keeps intelligence in Claude; harness stays simple; escalation routing is natural in an interactive session |
| Sub-agent role | Builder and reviewer only | Planning stages moved to top-level work sessions; only autonomous work remains as sub-agents |
| Stage-to-stage personality | Different agents per stage is acceptable | User explicitly confirmed this is fine |
| Context between stages | Clear context, invoke fresh session with new prompt | User explicitly confirmed this is fine |

## Architecture

### Harness loop (`orchestrate.ps1`)

```
loop:
    launch coordinator session (Start-Process -Wait)
    read state file → next_session field
    if next_session == "done": break
    launch work session for next_session (Start-Process -Wait)
    read state file (work session may have updated stage)
    continue loop
```

The harness is the only thing that persists across the full project lifecycle. It alternates between coordinator sessions and work sessions until the project is complete.

### Session types

**Coordinator session**
- Short-lived between planning stages; long-lived during building.
- System prompt: `prompts/coordinator.md` (new, slimmed from current `orchestrator.md`).
- Responsibilities:
  - On startup: read state file, run `reconcile-state`, surface pending escalations.
  - Between planning stages: run stage gate checklist, validate doc approval, advance `stage` in state file, write `next_session` to state file, exit.
  - During building: own the full build loop — read dependency graph, claim work units, spawn builder as sub-agent, spawn reviewer as sub-agent, mark complete, loop until all features done.
- Spawns: builder and reviewer as sub-agents only (autonomous — fine).
- Does NOT spawn any planning work sessions (harness does that).

**Charter work session**
- System prompt: `prompts/charter.md` (new).
- Runs `agent-skills/intake` inline (works — top-level session).
- Drafts project charter using `doc-ops/write-doc`.
- When approved by human: updates doc frontmatter to `status: approved`, writes `next_session: "coordinator"` to state file, tells human to close the session to continue, exits.

**System Design work session**
- System prompt: `prompts/system-design.md` (new).
- Reads approved project charter as context.
- Runs intake inline, then architecture option presentation, then toolchain Q&A (carry forward from current `system-planner.md` lines 47–68).
- Drafts system design, writes toolchain values to `project.yaml`.
- On approval: signals completion, exits.

**Feature Registry work session**
- System prompt: `prompts/feature-registry.md` (new).
- Reads approved charter + system design.
- Proposes feature list interactively, confirms with human, computes dependency order.
- Drafts feature registry.
- On approval: signals completion, exits.

**Feature Design work session**
- System prompt: `prompts/feature-design.md` (new).
- Invoked once per feature (in dependency order — coordinator writes the queue to state file before exiting).
- Reads charter, system design, feature registry, and previously approved feature designs.
- Reads `current_feature` from state file to know which feature to work on.
- Runs intake per feature, drafts feature design.
- On approval: signals completion, exits. Harness launches coordinator, which pops next feature from `feature_design_queue`; if queue empty, advances to building.

**Builder / Reviewer**
- Unchanged. Sub-agents of coordinator during building loop.

### State file additions

Add three fields to `state.json`:

```json
{
  "next_session": "charter",
  "feature_design_queue": ["F001", "F002"],
  "current_feature": "F001"
}
```

- `next_session`: written by coordinator before it exits; read by harness to determine what to launch. Values: `"charter"`, `"system-design"`, `"feature-registry"`, `"feature-design"`, `"building"`, `"done"`.
- `feature_design_queue`: list of feature IDs still needing a design session; coordinator pops the head and writes it to `current_feature` before each feature design session.
- `current_feature`: the feature ID the current feature-design session is working on.

## Implementation tasks (in order)

### 1. State file schema
- Add `next_session`, `feature_design_queue`, and `current_feature` fields to `docs/templates/state-file.json`.
- Update `orchestrate.ps1` `Invoke-New` to write `"next_session": "charter"` in the initial state file (alongside `"stage": "init"`).

### 2. `orchestrate.ps1` — harness loop
- Replace `Start-Session` (current single-session launcher) with a loop:
  - Launch coordinator session, block until exit.
  - Read `next_session` from state file.
  - If `next_session` is a work session type, launch that session, block until exit.
  - If `next_session == "done"`, print completion message and exit loop.
- Keep `-Feature` scoping for building phase (multi-instance unchanged).
- Keep existing `new`, `list`, `resume` command structure — `resume` enters the loop.

### 3. Coordinator prompt (`prompts/coordinator.md`)
- Start from current `orchestrator.md` and strip out all planning stage spawning logic (the `planning/charter`, `planning/system-design`, etc. sections that currently say "spawn a system-planner agent").
- Replace those sections with: run gate check → validate doc approval → write `next_session` to state file → exit.
- Keep: init GitHub setup, reconcile-state procedure, escalation routing, building loop, context management, stateless design principles.
- Remove: `agent-skills/spin-agent` and `workflow-utils/context-assembly` from skills list (coordinator no longer spawns planning agents).

### 4. Per-stage work session prompts (four new files)
For each: `prompts/charter.md`, `prompts/system-design.md`, `prompts/feature-registry.md`, `prompts/feature-design.md`.

Each prompt must include:
- Role description and behavioral preset (collaborative agency, architect quality, unrestricted scope).
- Skills loaded: `agent-skills/intake`, `agent-skills/escalate`, `agent-skills/research`, `doc-ops/write-doc`, `doc-ops/validate-doc`, `house-style/*`.
- What context to read on startup (which docs, which config).
- Stage-specific procedure (intake → draft → iterate → approval → write completion signal → exit instruction).
- Completion signal procedure: write `next_session: "coordinator"` to state file using the `Write` tool, then tell human to close the session.

Carry forward from current `system-planner.md`:
- Toolchain discovery Q&A (lines 47–68) → into `prompts/system-design.md`.
- Feature Registry procedure (lines 72–78) → into `prompts/feature-registry.md`.

### 5. Check for prompt assembly build script
- Before creating assembled prompts, check whether a build script exists that concatenates `prompts/fragments/` + base prompts into `prompts/assembled/`.
- If one exists, update it to include the new prompts and exclude the old ones.
- If not, assemble manually by prepending the appropriate fragment files (agency, quality, scope axes from `prompts/fragments/`) to each base prompt.

### 6. Assembled prompts
- Rebuild `prompts/assembled/coordinator.md` from new coordinator base + fragments.
- Create `prompts/assembled/charter.md`, `prompts/assembled/system-design.md`, `prompts/assembled/feature-registry.md`, `prompts/assembled/feature-design.md`.
- Delete `prompts/assembled/system-planner.md` and `prompts/assembled/feature-planner.md` (superseded).

### 7. Remove obsolete base prompts
- Delete `prompts/system-planner.md` and `prompts/feature-planner.md`.

### 8. Docs update
- `docs/setup/decisions.md` — add D14 recording this architectural change and its rationale.
- `docs/setup/walkthrough.md` — update Stage 0 and all planning stage descriptions to reflect per-session model.
- `SETUP.md` — update architecture overview.
- `README.md` — update agent roles table (system-planner and feature-planner become per-stage session names; orchestrator renamed to coordinator).

## Files changed (summary)

| File | Action |
|---|---|
| `orchestrate.ps1` | Replace single-session launch with harness loop |
| `docs/templates/state-file.json` | Add `next_session`, `feature_design_queue`, `current_feature` fields |
| `prompts/coordinator.md` | New (from orchestrator.md, stripped of planning delegation) |
| `prompts/charter.md` | New |
| `prompts/system-design.md` | New |
| `prompts/feature-registry.md` | New |
| `prompts/feature-design.md` | New |
| `prompts/assembled/coordinator.md` | New |
| `prompts/assembled/charter.md` | New |
| `prompts/assembled/system-design.md` | New |
| `prompts/assembled/feature-registry.md` | New |
| `prompts/assembled/feature-design.md` | New |
| `prompts/assembled/system-planner.md` | Delete (superseded) |
| `prompts/assembled/feature-planner.md` | Delete (superseded) |
| `prompts/system-planner.md` | Delete (superseded) |
| `prompts/feature-planner.md` | Delete (superseded) |
| `docs/setup/decisions.md` | Add D14 |
| `docs/setup/walkthrough.md` | Update planning stage descriptions |
| `SETUP.md` | Update architecture overview |
| `README.md` | Update agent roles |

## What is explicitly NOT changing

- Building loop logic (builder and reviewer sub-agents unchanged).
- `intake/SKILL.md` improvements from Task 3 (carry forward as-is).
- Plugin system, skill files, GitHub ops, doc-ops skills (unchanged).
- Multi-instance coordination for building phase (unchanged).
- State file fields other than the three additions above.
- `orchestrate.ps1` `new`, `list` commands (unchanged).

## Success criteria

1. `.\orchestrate.ps1 resume -Project foo` enters the harness loop.
2. Coordinator session launches, runs init GitHub setup (if needed), writes `next_session: "charter"`, exits.
3. Harness detects exit, launches charter session.
4. Charter session opens with an interactive intake conversation — human answers questions, agent does not assume.
5. Charter is approved, session exits.
6. Harness detects exit, launches coordinator.
7. Coordinator runs gate check, advances stage, writes `next_session: "system-design"`, exits.
8. Process repeats through all planning stages.
9. Building loop runs in coordinator session; builder and reviewer spawn as sub-agents autonomously.
10. If terminal dies mid-stage, `.\orchestrate.ps1 resume` re-enters the loop from wherever the state file left off — no progress lost.
