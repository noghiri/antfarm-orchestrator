# Orchestrator Setup

This system manages software projects through three stages (Research/Planning, Building, Integration) using a team of specialized Claude agents. This guide covers installing prerequisites and initializing your first project.

## Prerequisites

### 1. Git

Install Git from https://git-scm.com/ or your package manager. Verify:

```sh
git --version
```

### 2. GitHub CLI (`gh`)

Install from https://cli.github.com/ or your package manager. Authenticate:

```sh
gh auth login
gh auth status   # verify
```

The `gh` CLI must have access to the target repository with at minimum:
- **Issues**: read + write (create, edit, label, assign)
- **Pull requests**: read + write
- **Repository contents**: read + write (for pushing branches)

### 3. Claude Code

Install Claude Code following the instructions at your organization's deployment. This system uses Claude Code as the runtime for all agents.

### 4. ANTHROPIC_API_KEY

Set the API key in your environment:

```sh
export ANTHROPIC_API_KEY=sk-ant-...   # Linux/macOS
$env:ANTHROPIC_API_KEY = "sk-ant-..." # PowerShell
```

---

## Installing the plugins

The orchestrator ships as a Claude Code plugin marketplace. Install the plugins once — they are globally available across all projects.

```sh
# Add this repo as a marketplace source (run once)
/plugin marketplace add <github-user>/Orchestrator

# Install each plugin
/plugin install house-style@orchestrator-plugins
/plugin install agent-skills@orchestrator-plugins
/plugin install github-ops@orchestrator-plugins
/plugin install doc-ops@orchestrator-plugins
/plugin install workflow-utils@orchestrator-plugins
/plugin install code-quality@orchestrator-plugins
```

Skills installed this way are stored in `~/.claude/plugins/cache/` and are available in any Claude Code session without repeating the install.

---

## Setting up a new project

### 1. Clone or create the target repository

The target repository is the project you are building — the one that will contain source code and planning documents. It does not need to exist yet (you can point `gh` at an existing repo).

### 2. Initialize the project

From the orchestrator directory:

```sh
# Dry run first (see what would be created)
orchestrate new --project my-project --repo github-user/my-repo --github-user github-user

# Apply
orchestrate new --project my-project --repo github-user/my-repo --github-user github-user --execute
```

This will:
- Create a project config at `state/projects/my-project/project.yaml`
- Create a local state file at `state/my-project.json`
- Register the project in `projects.json`
- Create all required GitHub labels in the target repo
- Create the `planning` branch in the target repo

### 3. Edit the project config

Open `state/projects/my-project/project.yaml` and fill in:

```yaml
name: "My Project"
slug: my-project

github:
  owner: github-user
  repo: my-repo
  base_branch: main
  planning_branch: planning

ci:
  enabled: false   # set to true if using GitHub Actions
  required: false
  provider: none

toolchain:
  language: rust
  build: cargo build
  test: cargo test
  lint: cargo clippy -- -D warnings

orchestrator:
  escalation_target: "@github-user"
  plugins:
    - house-style
    - agent-skills
    - github-ops
    - doc-ops
    - workflow-utils
    - code-quality
```

### 4. Start the orchestrator

```sh
orchestrate resume --project my-project
```

The orchestrator will begin the Project Charter stage — a collaborative conversation to define what you are building.

---

## Resuming a project

```sh
orchestrate resume --project my-project
```

On startup, the orchestrator runs `reconcile-state` to re-sync with GitHub Issue state from any previous session.

## Listing projects

```sh
orchestrate list
```

---

## Multi-instance setup

To run multiple instances in parallel (one per feature):

```sh
# Terminal 1
orchestrate resume --project my-project --feature F001

# Terminal 2
orchestrate resume --project my-project --feature F002
```

Each instance is scoped to a single feature and will only claim work units for that feature. See `plugins/workflow-utils/skills/multi-instance.md` for the full coordination rules.

---

## Directory structure

```
Orchestrator/                  # This repo
  .claude-mode.json            # Agent behavioral presets
  .claude/settings.json        # Hooks (task list reinforcement)
  .claude-plugin/
    marketplace.json           # Plugin marketplace manifest
  plugins/                     # Plugin source
    house-style/
      .claude-plugin/
        plugin.json            # Plugin manifest
      skills/
        <name>/
          SKILL.md             # Skill instruction + frontmatter
    agent-skills/              # (same structure)
    github-ops/
    doc-ops/
    workflow-utils/
    code-quality/
  prompts/                     # Agent system prompts
    orchestrator.md
    system-planner.md
    feature-planner.md
    builder.md
    reviewer.md
  docs/
    schemas/                   # JSON schemas for validation
    templates/                 # Document and config templates
  scripts/                     # orchestrate command documentation
  state/                       # Local state (gitignored)
    <project-slug>.json        # Per-project state file
    projects/<slug>/           # Per-project configs
  projects.json                # Project registry (gitignored)
```

---

## Troubleshooting

**`gh` authentication fails**: Run `gh auth login` and follow the browser prompt.

**Git not found**: Add Git to your PATH. On Windows, Git installs to `C:\Program Files\Git\cmd\` by default.

**Label creation fails**: Verify your GitHub token has `repo` scope with write access to issues and pull requests.

**Agent does not follow house style**: Ensure the `house-style` plugin is installed (`/plugin install house-style@orchestrator-plugins`) and listed in `project.yaml`'s `orchestrator.plugins`.
