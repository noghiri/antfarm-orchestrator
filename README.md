# Orchestrator

A multi-agent system for building software projects with Claude. The Orchestrator manages a team of specialized Claude agents through structured planning and building stages, using GitHub Issues as the coordination layer and requiring explicit human approval at every stage gate.

---

## How it works

Projects move through two phases:

**Planning** (interactive, collaborative)

The human and the system co-author four documents, one stage at a time. Each document must be explicitly approved before the next stage begins.

```
Project Charter → System Design → Feature Registry → Feature Designs (one per feature)
```

Each stage produces a validated, committed Markdown document on the `planning` branch. Approval gates are hard stops — the system will not advance without explicit sign-off.

**Building** (autonomous, supervised)

Once all feature designs are approved, the orchestrator runs autonomously: it claims features, dispatches builder agents to implement work units (test-first), and dispatches reviewer agents to verify each one before marking it complete. Escalations and integration gates surface to the human as needed.

```
Claim feature → Spawn builder (TDD) → Builder gate → Spawn reviewer → Reviewer gate → Feature integration gate
```

The system is **stateless with respect to conversation history**. All state lives in the local state file, project config, GitHub Issues, and planning documents — sessions can be compacted and resumed at any time without losing progress.

---

## Agents

Five specialized agents, each with a distinct behavioral preset from [claude-code-modes](https://github.com/nklisch/claude-code-modes):

| Agent | Preset | Responsibility |
|-------|--------|----------------|
| **Orchestrator** | autonomous / pragmatic / narrow | Manages stages, enforces gates, spawns sub-agents, routes escalations |
| **System Planner** | collaborative / architect / unrestricted | Authors the Project Charter, System Design, and Feature Registry with the human |
| **Feature Planner** | collaborative / architect / adjacent | Authors Feature Design documents; breaks features into work units; writes contract test stubs |
| **Builder** | autonomous / pragmatic / narrow | Implements a single work unit following TDD; runs build, test, and lint gates |
| **Reviewer** | collaborative / architect / narrow | Adversarially verifies spec compliance, security, and house style; runs contract tests |

---

## Plugins

Six plugin packages loaded into every session:

| Plugin | What it provides |
|--------|-----------------|
| `house-style` | Coding standards, comment discipline, TDD, dry-run compliance, defense in depth, task list discipline |
| `agent-skills` | Escalation protocol, external research, task lifecycle, sub-agent spawning, stuck detection |
| `github-ops` | Issue and PR operations via `gh`; work unit claiming with feature-boundary locking |
| `doc-ops` | Planning document validation, staleness checks, validated writes, stage gate checklists |
| `workflow-utils` | Dependency graph, context assembly, state reconciliation, context reload, multi-instance coordination, CI checks |
| `code-quality` | Build, lint, test, and contract test runners; all failures are hard blocks |

---

## Prerequisites

- [Git](https://git-scm.com/)
- [GitHub CLI (`gh`)](https://cli.github.com/) — authenticated with read/write access to the target repo
- [Claude Code](https://claude.ai/code)
- [claude-code-modes](https://github.com/nklisch/claude-code-modes) — `claude-mode` must be on PATH
- `ANTHROPIC_API_KEY` set in your environment
- PowerShell 7+ (`pwsh`) for the `orchestrate.ps1` entry point

---

## Quick start

```powershell
# 1. Install plugins (one-time, from inside a Claude Code session)
/plugin marketplace add <your-github-user>/Orchestrator
/plugin install house-style@orchestrator-plugins
/plugin install agent-skills@orchestrator-plugins
/plugin install github-ops@orchestrator-plugins
/plugin install doc-ops@orchestrator-plugins
/plugin install workflow-utils@orchestrator-plugins
/plugin install code-quality@orchestrator-plugins

# 2. Initialize a new project (dry-run to preview, then apply)
.\orchestrate.ps1 new --Project my-project --Repo github-user/my-repo
.\orchestrate.ps1 new --Project my-project --Repo github-user/my-repo --Execute

# 3. The orchestrator session starts automatically after initialization.
#    Work through the planning stages interactively.

# 4. Resume in a later session
.\orchestrate.ps1 resume --Project my-project

# Multi-instance: one session per feature
.\orchestrate.ps1 resume --Project my-project --Feature F001  # terminal 1
.\orchestrate.ps1 resume --Project my-project --Feature F002  # terminal 2

# List all registered projects
.\orchestrate.ps1 list
```

---

## Project structure

```
Orchestrator/
  orchestrate.ps1          # Entry point: new / resume / list
  .claude-mode.json        # Agent behavioral presets + role prompt modifiers
  plugins/                 # Six plugin packages (skills)
    house-style/
    agent-skills/
    github-ops/
    doc-ops/
    workflow-utils/
    code-quality/
  prompts/                 # Agent system prompts (loaded as modifiers at launch)
    orchestrator.md
    system-planner.md
    feature-planner.md
    builder.md
    reviewer.md
  docs/
    schemas/               # JSON schemas for all document types and state files
    templates/             # Document templates and CI workflow template
    setup/                 # Setup guide, walkthrough, and decision log
  state/                   # Local state (gitignored)
    <project-slug>.json
    projects/<slug>/project.yaml
  projects.json            # Project registry (gitignored)
```

---

## Further reading

- **[SETUP.md](SETUP.md)** — prerequisites, plugin installation, project initialization, CI setup
- **[docs/setup/walkthrough.md](docs/setup/walkthrough.md)** — end-to-end example tracing a minimal project through every stage; use as a smoke-test checklist
- **[docs/setup/decisions.md](docs/setup/decisions.md)** — architectural decisions, implementation status, and context for future sessions
