# Orchestrator Setup

This system manages software projects through two phases (Planning and Building) using a team of specialized Claude agents. This guide covers installing prerequisites and initializing your first project. New to the system? See [README.md § In plain terms](README.md#in-plain-terms) for a plain-language explanation first.

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
/plugin marketplace add <github-user>/antfarm-orchestrator

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

```powershell
# Dry run first (see what would be created)
.\orchestrate.ps1 new -Project my-project -Repo github-user/my-repo -ProjectDir C:\path\to\my-repo

# Apply
.\orchestrate.ps1 new -Project my-project -Repo github-user/my-repo -ProjectDir C:\path\to\my-repo -Execute
```

This will:
- Create a project config at `<project-dir>\.orchestrator\project.yaml`
- Create a local state file at `<project-dir>\.orchestrator\state.json` (stage: `init`)
- Register the project in `projects.json` (in the Orchestrator tool directory)
- Launch an orchestrator session, which creates GitHub labels and the `planning` branch on first run

Initialization creates or updates the project's `.gitignore` automatically, adding `.orchestrator/` so local state is never committed to the target repo.

### 3. Edit the project config

Open `<project-dir>\.orchestrator\project.yaml` and confirm the GitHub settings and escalation target are correct. The `toolchain` and `ci` sections will be filled in by the system design session during planning — leave them as initialized.

```yaml
name: "My Project"
slug: my-project

github:
  owner: github-user
  repo: my-repo
  base_branch: main
  planning_branch: planning

ci:
  enabled: false    # filled in by system design session
  required: false
  provider: none

toolchain:
  language: null    # filled in by system design session
  build: null
  test: null
  lint: null

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

### 4. (Optional) Enable CI

If you want the orchestrator to enforce CI at each Work Unit Completion Gate, copy the workflow template to your target repository and fill in your toolchain commands:

```sh
mkdir -p <target-repo>/.github/workflows
cp docs/templates/ci-workflow.yml <target-repo>/.github/workflows/ci.yml
# Edit ci.yml: replace BUILD_COMMAND, TEST_COMMAND, LINT_COMMAND
```

Then set in `<project-dir>\.orchestrator\project.yaml`:
```yaml
ci:
  enabled: true
  required: true
  provider: github-actions
```

The orchestrator's `check-ci` skill queries `gh run list --branch <branch>` to verify CI before merging each work unit.

### 5. Start the orchestrator

The harness loop starts automatically at the end of `orchestrate new`. To resume in a later session:

```powershell
.\orchestrate.ps1 resume -Project my-project
```

The harness will launch a coordinator session to check state, then launch the appropriate work session (charter, system design, feature registry, or feature design) based on where you left off.

---

## Resuming a project

```powershell
.\orchestrate.ps1 resume -Project my-project
```

On startup, the orchestrator runs `reconcile-state` to re-sync with GitHub Issue state from any previous session.

## Listing projects

```powershell
.\orchestrate.ps1 list
```

---

## Multi-instance setup

To run multiple instances in parallel (one per feature):

```powershell
# Terminal 1
.\orchestrate.ps1 resume -Project my-project -Feature F001

# Terminal 2
.\orchestrate.ps1 resume -Project my-project -Feature F002
```

Each instance is scoped to a single feature and will only claim work units for that feature. See `plugins/workflow-utils/skills/multi-instance/SKILL.md` for the full coordination rules.

---

## Directory structure

```
Orchestrator/                  # This repo
  .claude-mode.json            # Preset reference (not used at runtime — see prompts/assembled/)
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
  prompts/                     # Agent base prompts (combined with fragments → assembled/)
    coordinator.md
    charter.md
    system-design.md
    feature-registry.md
    feature-design.md
    builder.md
    reviewer.md
  prompts/assembled/           # Ready-to-use system prompts (fragment header + base prompt)
    coordinator.md
    charter.md
    system-design.md
    feature-registry.md
    feature-design.md
    builder.md
    reviewer.md
  docs/
    schemas/                   # JSON schemas for validation
    templates/                 # Document and config templates
  scripts/                     # orchestrate command documentation
  projects.json                # Project registry (gitignored)
```

---

## Troubleshooting

**`gh` authentication fails**: Run `gh auth login` and follow the browser prompt.

**Git not found**: Add Git to your PATH. On Windows, Git installs to `C:\Program Files\Git\cmd\` by default.

**Label creation fails**: Verify your GitHub token has `repo` scope with write access to issues and pull requests.

**Agent does not follow house style**: Ensure the `house-style` plugin is installed (`/plugin install house-style@orchestrator-plugins`) and listed in `project.yaml`'s `orchestrator.plugins`.
