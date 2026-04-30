# Orchestrator — Architectural Decisions & Implementation Status

_Last updated: 2026-04-30._

---

## Architectural Decisions

### D1 — `orchestrate` command form
**Decision:** Shell script wrapping `claude-mode <preset>`.

`orchestrate.ps1` (repo root) provides `new`, `resume`, and `list` subcommands. Each initializes or loads project state and invokes `claude-mode orchestrator --modifier orchestrator-role --modifier context-pacing` to start the Claude Code session. Built on `claude-code-modes` (https://github.com/nklisch/claude-code-modes).

**Constraint resolved:** Sub-agents spawned via the `Agent` tool inherit the orchestrator's system prompt, not their own preset. `workflow-utils/context-assembly` now embeds the target role's behavioral instructions (agency/quality/scope) as the first block of every assembled sub-agent prompt. See `agent-skills/spin-agent` and `workflow-utils/context-assembly`.

---

### D2 — Skills are instructions, not automation
**Decision:** SKILL.md files are instruction sets Claude reads and follows using its existing tools. No harness needed. The `Agent` tool is available in all `claude-mode`-wrapped sessions — `claude-mode` only replaces the behavioral layer; Claude Code's tool infrastructure is preserved.

---

### D3 — Operating mode: supervised automation
**Decision:** Building stages run autonomously. Planning stages (charter, system design, feature registry, feature design) are interactive. Stage gates and escalations are hard stops — never bypassed.

- Planning: fully interactive, human and orchestrator co-author documents
- Gate transitions: orchestrator presents stage checklist, waits for explicit human approval
- Building loop: orchestrator claims features, spawns builders/reviewers autonomously
- Escalations: surfaced immediately, orchestrator blocks until resolved
- L1 revisions: all instances pause, human merges revision branch, instances resume

---

### D4 — Dry-run scope and opt-in mechanism
**Decision:** `house-style/dry-run` governs **generated code** (scripts/tools agents write) with destructive side effects. It does NOT govern the orchestrator's own operational mutations.

Orchestrator mutations use **stage-level authorization**: the human's approval at each gate authorizes all mutations for that stage without per-operation confirmation.

`house-style/dry-run` has been updated to reflect this scope.

---

### D5 — Multi-instance: feature-boundary claiming
**Decision:** Multi-instance is a v1 requirement. Each instance is assigned a single feature via `--feature F001` at startup. Feature-boundary exclusion is enforced by `github-ops/claim-work-unit`: before claiming any work unit issue, the skill verifies the issue's `feature/<feature-id>` label matches this instance's assigned feature. Work-unit-level race conditions are structurally prevented.

Residual race (two instances incorrectly assigned the same feature): the alphabetical-yield protocol in `workflow-utils/multi-instance` applies, and the incident is surfaced to the human.

---

### D6 — Smoke-test repo
**Decision:** Deferred. A dedicated sandbox GitHub repo will be created when smoke-testing begins (Task #14). Do not use the Orchestrator repo itself.

---

### D8 — State lives in the project directory
**Decision:** Orchestrator state (state file and project config) lives in `<project-dir>/.orchestrator/`, not in the Orchestrator tool's own directory.

**Rationale:** State belongs to the project being built, not to the tool. Keeping it co-located with the project means the project's local clone is self-contained, the Orchestrator tool directory stays clean across multiple projects, and the `.orchestrator/` directory can be added to the project's `.gitignore` as one logical unit.

**Implementation:**
- `orchestrate.ps1` writes to `<project-dir>/.orchestrator/state.json` and `<project-dir>/.orchestrator/project.yaml`
- `orchestrate new` requires `--ProjectDir <path>` (absolute path to the local project clone)
- `projects.json` stores `{slug, dir, repo}` where `dir` is the absolute path — used to locate state on `resume`
- `Start-Session` passes `project_dir` in the startup context string so the orchestrator agent knows where to read state
- `orchestrate.ps1`'s `Start-Session` pushes to the Orchestrator root before invoking `claude-mode` (so `.claude-mode.json` is found), but the project dir is passed as a context variable, not the CWD
- The Orchestrator repo's `.gitignore` no longer contains `state/` (that directory is gone)
- Post-init output reminds the user to add `.orchestrator/` to the project's `.gitignore`

---

### D7 — Context management
**Decision:** The orchestrator is stateless with respect to conversation history. All critical state lives in durable storage: state file, project config, GitHub Issues, and planning documents (L1 + L2). Context compaction at any point is safe; `workflow-utils/context-reload` fully restores the working picture.

**Implementation:**
- `orchestrate.ps1` launches the orchestrator with `--modifier context-pacing` (auto-pacing from claude-code-modes)
- `prompts/orchestrator.md` has a "Context management" section specifying the stateless principle, compaction signal points (each stage gate, each feature completion), and durable sources
- `workflow-utils/context-reload` (new skill) defines the reload procedure: state file → project config → planning document inventory → reconcile-state → dependency graph
- Planning documents are inventoried by frontmatter only (not loaded in full); full content is passed to sub-agents via `context-assembly`

---

## Completed Work

### Skill infrastructure
- **Cross-reference audit** (Task #11): all 44 skills verified, zero broken references
- **`agent-skills/spin-agent`**: invocation updated to explicitly use `Agent` tool with `subagent_type: general-purpose`; assembled context is the full `prompt` value
- **`workflow-utils/context-assembly`**: added behavioral preset instructions section; updated assembly procedure to embed them as the first block of every sub-agent prompt
- **`workflow-utils/multi-instance`**: feature-boundary claiming is now the primary exclusion model, not a soft convention; added explicit statement that two instances on the same feature is a configuration error
- **`github-ops/claim-work-unit`**: added step 1 — verify feature scope label before claiming
- **`house-style/dry-run`**: scope narrowed to generated code; orchestrator operations explicitly exempted
- **`workflow-utils/context-reload`** (new): reload procedure from durable state
- **`workflow-utils/context-assembly`**: behavioral preset instructions per role; planning document full content reserved for sub-agents

### Entry point
- **`orchestrate.ps1`** (repo root): implements `new`, `resume`, `list`
  - `new`: requires `--ProjectDir <path>`; interactive prompts, dry-run by default, `-Execute` to apply; creates `.orchestrator/` in the project dir with `state.json` and `project.yaml`; creates GitHub labels (idempotent with `--force`), planning branch; launches orchestrator session
  - `resume`: looks up `dir` from `projects.json`, validates project exists, launches session with optional `--Feature` scope
  - `list`: reads `projects.json` and state files from each registered `dir`, prints table
  - State at `<project-dir>/.orchestrator/state.json`; config at `<project-dir>/.orchestrator/project.yaml`; `projects.json` stores `{slug, dir, repo}`
- **`.claude-mode.json`**: added `modifiers` section registering all 5 role prompts (`./prompts/*.md`) for use with `--modifier <role>-role`

### Prompts
- **`prompts/orchestrator.md`**: added "Context management" section (stateless principle, compaction signal points, durable sources including L1/L2 planning documents); registered `workflow-utils/context-reload`
- **`prompts/feature-planner.md`**: step 4 updated with per-language contract test location and naming conventions; fail-immediately stub requirement made explicit

### Code quality
- **`code-quality/run-contract-tests`**: fixed Rust convention (function name prefix `contract_`, not comment); added Go; added per-language table with file location, naming, and run command
- **`docs/templates/ci-workflow.yml`** (new): GitHub Actions CI template with build/test/lint jobs, triggers on `feature/**` and `planning` branches; setup blocks for Rust/Node/Python/Go
- **`SETUP.md`**: added CI setup step referencing the template

### Documentation
- **`docs/setup/walkthrough.md`** (new): full end-to-end walkthrough of the Ping Server example project through all stages; doubles as the smoke-test validation checklist

---

## Remaining Work

### Task #14 — Smoke-test (blocked on sandbox repo)

Once a dedicated sandbox GitHub repo is available, run the orchestrator through the full planning stage using the Ping Server example from `docs/setup/walkthrough.md`:

1. `.\orchestrate.ps1 new --Project ping-server --Repo <sandbox-org>/ping-server --ProjectDir <path-to-local-clone> --Execute`
2. Full planning stage: charter → system design → feature registry → feature design
3. Validate against the checklist table at the bottom of `docs/setup/walkthrough.md`

This is the acceptance test for "usable." Do not proceed to building-stage automation until planning stage passes.
