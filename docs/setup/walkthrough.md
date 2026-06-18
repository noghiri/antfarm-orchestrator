# End-to-End Walkthrough: Ping Server

This walkthrough traces a minimal project — a single-endpoint HTTP health-check server — through every stage of the Orchestrator workflow. Use it to understand the system or as a validation checklist when smoke-testing.

**Project**: `ping-server`
**GitHub repo**: `your-org/ping-server` (replace with your sandbox repo)
**Language**: Rust (`cargo`)
**Features**: one feature, one work unit

---

## Prerequisites

- `gh` authenticated with write access to the target repo
- `claude` CLI installed (Claude Code — `claude --version` should succeed)
- Orchestrator repo cloned and invoked as `.\orchestrate.ps1`

---

## Stage 0 — Initialize the project

```powershell
# Dry-run first to see what will be created
.\orchestrate.ps1 new -Project ping-server -Repo your-org/ping-server -ProjectDir C:\Projects\ping-server

# Apply
.\orchestrate.ps1 new -Project ping-server -Repo your-org/ping-server -ProjectDir C:\Projects\ping-server -Execute
```

Interactive prompts and expected answers:
```
Display name [Ping Server]:          Ping Server            (accept default)
Base branch [main]:                  main                   (accept default)
Planning branch [planning]:          planning               (accept default)
Escalation target [@you]:            @your-github-username  (accept default)
```

**What gets created by `orchestrate new`:**
- `C:\Projects\ping-server\.orchestrator\project.yaml`
- `C:\Projects\ping-server\.orchestrator\state.json` (stage: `init`)
- Entry in `projects.json` (in the Orchestrator tool directory)

**What gets created on first session start (by the orchestrator agent):**
- 13 GitHub labels in `your-org/ping-server`
- `planning` branch in `your-org/ping-server`

After initialization, add `.orchestrator/` to the project's `.gitignore` (the tool reminds you).

The harness loop starts automatically after initialization. The first session launched is the **charter session** (stage: `planning/charter`).

---

## Stage 1 — Project Charter (`planning/charter`)

The harness launches a **charter session** — a fully interactive top-level Claude Code session. The charter session runs intake, drafts the document collaboratively, and waits for your approval before closing.

**What the charter session produces** (saved to `docs/project/project-charter.md` on the `planning` branch):

```markdown
---
doc_type: project-charter
version: 1
status: draft
created: 2026-04-30
revised: 2026-04-30
revision: 1
---
# Project Charter: Ping Server

## Objectives
Provide a minimal HTTP server with a health-check endpoint suitable for use
as a readiness probe in container orchestration environments.

## Scope
### In Scope
- GET /health endpoint returning {"status": "ok"} with HTTP 200
- Configurable port via environment variable

### Out of Scope
- Authentication
- TLS
- Any other endpoints

## Constraints
- **Technical**: Rust, single binary, no external dependencies beyond std
- **Timeline**: None
- **Resources**: Single developer

## Feasibility Assessment
Straightforward. No external dependencies or research required.

## Success Criteria
- Binary starts and responds to GET /health within 100ms
- Returns correct JSON body and 200 status code
- Port configurable via PORT environment variable (default 8080)

## Open Questions
(none)
```

**Your role**: Review the draft. Ask for changes if needed. When satisfied, approve. The charter session marks the document `status: approved`, commits it to the `planning` branch, and tells you to close the window.

When you close the charter session, the harness launches a **coordinator session** to run the System Design Stage Gate:
```
- [x] project-charter.md is status: approved
- [x] validate-doc passes
- [x] check-staleness passes
- [x] Human has explicitly approved
- [x] Document committed on planning branch
```
The coordinator signals a compaction point, advances stage to `planning/system-design`, and exits. The harness then launches the system design session.

---

## Stage 2 — System Design (`planning/system-design`)

The harness launches a **system design session**. It reads the approved charter, runs intake for architectural decisions and toolchain discovery, drafts the document, and writes the confirmed toolchain values to `project.yaml`.

**What the system design session produces** (`docs/project/system-design.md` on `planning`):

```markdown
---
doc_type: system-design
version: 1
status: draft
...
---
# System Design: Ping Server

## Architecture
Single-binary Rust HTTP server using the standard library's TcpListener.
No frameworks. One file: src/main.rs.

## Components
- **main**: entry point; reads PORT from environment, binds TcpListener
- **handle_connection**: reads HTTP request line, routes GET /health
- **health_handler**: writes HTTP 200 response with JSON body

## Technology Stack
- Language: Rust (stable)
- HTTP: hand-rolled over TcpStream (no dependencies)
- Build: cargo build --release

## Integration Points
None. Standalone binary.
```

**Your role**: Approve when satisfied. Close the session window.

The harness launches a coordinator session for the Feature Registry Stage Gate, then launches the feature registry session.

---

## Stage 3 — Feature Registry (`planning/feature-registry`)

The harness launches a **feature registry session**. It reads the approved charter and system design, proposes the feature list, computes the dependency execution order, and drafts the registry.

**What the feature registry session produces** (`docs/project/feature-registry.md` on `planning`):

```markdown
---
doc_type: feature-registry
version: 1
status: draft
...
---
# Feature Registry: Ping Server

## Summary

| ID   | Name            | Status  | Priority | Depends On |
|------|-----------------|---------|----------|------------|
| F001 | Health Endpoint | planned | high     | —          |

## Feature Details

### F001: Health Endpoint

**Status**: planned
**Priority**: high
**Depends On**: []
**Branch**: feature/F001-health-endpoint
**GitHub Label**: feature/F001

**Description**: Implement the GET /health endpoint that returns HTTP 200
with body {"status": "ok"}.

**Acceptance Criteria**:
- GET /health returns HTTP 200
- Response body is {"status": "ok"}
- Content-Type header is application/json
- Server starts on PORT env var (default 8080)
```

**Your role**: Approve. Close the session window.

The coordinator gate check runs `dependency-graph` (result: F001 has no dependencies, ready to design), populates `feature_design_queue`, sets `current_feature: F001`, and launches the first feature design session.

---

## Stage 4 — Feature Design (`planning/feature-design`)

The harness launches a **feature design session** scoped to F001 (read from `current_feature` in the state file).

**What the feature design session produces** (`docs/features/F001/feature-design.md` on `planning`):

```markdown
---
doc_type: feature-design
feature_id: F001
feature_name: "Health Endpoint"
version: 1
status: draft
...
depends_on_decisions: []
---
# Feature Design: F001 — Health Endpoint

## Objective
Implement a minimal Rust HTTP server with a single GET /health endpoint.

## Acceptance Criteria
- [ ] GET /health returns HTTP 200
- [ ] Response body is exactly {"status": "ok"} (no trailing newline)
- [ ] Content-Type: application/json
- [ ] Server binds to PORT env var, defaulting to 8080
- [ ] Server starts without error on a clean machine with no config

## Output Contracts

```rust
// Contract: health endpoint response
// GET /health → HTTP 200
// Body: {"status":"ok"}
// Header: Content-Type: application/json
fn handle_health() -> HttpResponse;
```

## Contract Tests

- `test_health_returns_200`: send GET /health, assert status code 200
- `test_health_body`: assert response body equals `{"status":"ok"}`
- `test_health_content_type`: assert Content-Type header is application/json
- `test_port_default`: server binds to 8080 when PORT is unset
- `test_port_env`: server binds to custom port when PORT=9090

## Work Units

### WU-001: Implement GET /health handler

**GitHub Issue**: #1 (created after approval)
**Toolchain**: rust / cargo
**Estimated size**: small
**Depends On**: []

**Description**: Write src/main.rs implementing the HTTP server and /health handler.

**Implementation Notes**:
- Use std::net::TcpListener, no external crates
- Parse only the first line of the HTTP request to identify the route
- Return 404 for all other routes

**Tests**:
- `test_health_returns_200`
- `test_health_body`
- `test_health_content_type`
- `test_port_default`
- `test_port_env`

## Integration Notes
Standalone feature. No cross-feature dependencies.

## Open Questions
(none)
```

**What the feature design session also does** before closing:
- Commits the contract test stubs to the `feature/F001-health-endpoint` branch (empty tests that fail)
- These are the failing tests the builder will make pass

**Feature Design Stage Gate:**
```
- [x] feature-design.md is status: approved
- [x] validate-doc passes
- [x] depends_on_decisions is empty
- [x] Output Contracts fully specified
- [x] Contract Tests list present (5 tests)
- [x] Contract test stubs committed on feature branch
- [x] Human approved
- [x] GitHub Issue #1 created for WU-001 with labels: work-unit, feature/F001, status/planned
```

**Your role**: Review the feature design, check the contract tests are sensible. Approve. Close the session window.

The coordinator gate check validates the feature design, finds `feature_design_queue` empty, creates GitHub Issues for all work units, signals a compaction point, and advances to `building`.

---

## Stage 5 — Building: WU-001

### 5a. Orchestrator claims the feature

The orchestrator (scoped to F001 via `--feature F001`) calls `claim-work-unit` on issue #1:
```
[applying] claim issue #1 (WU-001: Implement GET /health handler)
  add labels: claimed-by/you-ping-server-f001, status/in-progress
  remove labels: status/planned
  assignee: your-github-username
```

Updates `state/ping-server.json`:
```json
"active_features": {
  "F001": {
    "status": "building",
    "active_work_unit": "WU-001",
    "claimed_issue": 1
  }
}
```

### 5b. Builder agent

The coordinator spawns a builder agent via the `Agent` tool with the assembled context (project config + system design + feature design + issue #1 body).

**Builder workflow (TDD):**

1. Reads the work unit spec from issue #1 and the feature design
2. Writes **failing tests** first in `src/main_test.rs` (or `tests/health.rs`):
   ```rust
   #[test]
   fn test_health_returns_200() {
       // starts server on random port, sends GET /health, asserts 200
   }
   // ... (all 5 tests)
   ```
3. Runs `cargo test` → all 5 tests fail (expected)
4. Implements `src/main.rs`
5. Runs `cargo test` → all pass
6. Runs `cargo clippy -- -D warnings` → no warnings
7. Runs `cargo build --release` → success
8. Checks all acceptance criteria from the feature design: ✓

**Builder Work Unit Completion Gate:**
```
- [x] All tasks completed
- [x] cargo build passes
- [x] cargo test passes (5/5)
- [x] cargo clippy passes
- [x] All acceptance criteria met
- [x] No TODO comments in implementation
- [x] Tests colocated with implementation
- [x] PR created: "feat(F001): implement GET /health handler" → feature/F001 branch
- [x] Issue #1 updated to status/review
```

Builder posts result back to the orchestrator.

### 5c. Reviewer agent

The orchestrator spawns a reviewer with the same context plus the PR diff.

**Reviewer checks:**
- Implementation matches spec: ✓ (GET /health → 200, correct body and headers)
- Tests cover acceptance criteria: ✓
- House style (coding-principles): ✓ minimal, no abstractions, no speculative error handling
- Defense in depth: ✓ (no external input beyond HTTP line, no injection surface)
- Dry-run: N/A (no destructive operations in this feature)

**Reviewer Completion Gate:**
```
- [x] Spec compliance verified
- [x] Tests cover acceptance criteria
- [x] House style checked
- [x] No security issues
- [x] Last work unit for F001 — contract tests pass (cargo test)
- [x] PR approved
- [x] Review result posted as comment on issue #1
- [x] Issue #1 updated to status/complete
- [x] Issue #1 closed
```

Reviewer posts approval back to the orchestrator.

---

## Stage 6 — Feature Integration Gate (F001)

All work units for F001 are `status/complete`. The orchestrator runs the Feature Integration Gate:

```
- [x] All work unit issues for F001 are closed
- [x] run-contract-tests passes (5/5)
- [x] CI: N/A (ci_required: false)
- [x] Feature branch PR created: feature/F001-health-endpoint → main
- [ ] Human review of integration PR  ← your action
```

**Your role**: Review and merge the feature branch PR on GitHub. Signal to the orchestrator: `"F001 merged."`

The orchestrator updates `active_features.F001.status` to `complete`.

---

## Stage 7 — Project complete

All features complete. The orchestrator:
1. Verifies no unclaimed work units remain
2. Confirms all feature integration PRs are merged
3. Reports to the human: `"Project ping-server is complete. All features integrated."`

---

## Validation checklist (smoke test)

Use this list when running the system for the first time to confirm each piece works:

| Check | Expected |
|-------|----------|
| `orchestrate new` dry-run | Prints planned actions, makes no changes |
| `orchestrate new --Execute` | Creates state files, labels, planning branch |
| `orchestrate list` | Shows `ping-server` with stage `planning/charter` |
| Charter session launched by harness | Charter session opens interactively; document appears on `planning` branch after approval |
| Coordinator gate check runs after charter | Gate checklist validated; stage advances to `planning/system-design` |
| Compaction signal after charter gate | Coordinator mentions `/compact` |
| `orchestrate resume` after `/compact` | Reads state file, reconciles, resumes at correct stage |
| Feature design gate blocks without contract tests | Gate checklist fails the contract-tests item |
| Builder spawned with correct context | Builder's opening message references WU-001 spec |
| Builder writes failing tests first | `cargo test` fails before implementation |
| Builder completion gate blocks on failing tests | Gate is not passed until all tests green |
| Reviewer blocks on spec mismatch | If implementation diverges from spec, reviewer escalates |
| Feature integration gate requires all issues closed | Gate fails if any WU is open |
| `orchestrate list` after completion | Shows stage `building` → eventually no active work units |
