#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Antfarm Orchestrator project management CLI.
.DESCRIPTION
    Manages multi-agent software projects using the Antfarm Orchestrator.
    State is stored in <project-dir>/.orchestrator/ — inside the project repo.
.EXAMPLE
    # Initialize a new project (dry-run by default)
    .\orchestrate.ps1 new -Project my-app -Repo myorg/my-app -ProjectDir C:\Projects\my-app

    # Apply the initialization
    .\orchestrate.ps1 new -Project my-app -Repo myorg/my-app -ProjectDir C:\Projects\my-app -Execute

    # Resume an existing project
    .\orchestrate.ps1 resume -Project my-app

    # Resume scoped to one feature (multi-instance)
    .\orchestrate.ps1 resume -Project my-app -Feature F001

    # List all registered projects
    .\orchestrate.ps1 list
#>

param(
    [Parameter(Position = 0, Mandatory)]
    [ValidateSet('new', 'resume', 'list')]
    [string]$Command,

    [Parameter(HelpMessage = 'Project slug — lowercase alphanumeric with hyphens')]
    [string]$Project,

    [Parameter(HelpMessage = 'Target GitHub repository in owner/repo format')]
    [string]$Repo,

    [Parameter(HelpMessage = 'Absolute path to the local clone of the target project repository')]
    [string]$ProjectDir,

    [Parameter(HelpMessage = 'GitHub username (defaults to authenticated gh user)')]
    [string]$GithubUser,

    [Parameter(HelpMessage = 'Feature ID to scope this instance to (e.g. F001) — for multi-instance use')]
    [string]$Feature,

    [Parameter(HelpMessage = 'Apply changes — omit to preview as dry-run')]
    [switch]$Execute
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Paths ─────────────────────────────────────────────────────────────────────

$Script:Root     = $PSScriptRoot          # Antfarm Orchestrator tool directory
$Script:Registry = Join-Path $Root 'projects.json'

# State lives inside the project: <project-dir>/.orchestrator/
$Script:OrchestratorSubdir = '.orchestrator'
$Script:StateFileName      = 'state.json'
$Script:ConfigFileName     = 'project.yaml'

# ── Helpers ───────────────────────────────────────────────────────────────────

function Assert-Tool([string]$Name, [string]$Hint) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Error "$Name not found on PATH. $Hint"
        exit 1
    }
}

function Get-ProjectStateDir([string]$Dir) {
    Join-Path $Dir $Script:OrchestratorSubdir
}

function Get-StateFile([string]$Dir) {
    Join-Path (Get-ProjectStateDir $Dir) $Script:StateFileName
}

function Get-ConfigFile([string]$Dir) {
    Join-Path (Get-ProjectStateDir $Dir) $Script:ConfigFileName
}

function Read-Registry {
    if (Test-Path $Script:Registry) {
        return Get-Content $Script:Registry -Raw | ConvertFrom-Json -AsHashtable
    }
    return @{ version = 1; projects = @{} }
}

function Write-Registry([hashtable]$Data) {
    $Data | ConvertTo-Json -Depth 10 | Set-Content $Script:Registry -Encoding utf8
}

function Show-DryRun([string[]]$Actions) {
    Write-Host ''
    Write-Host '[dry-run] Would perform:' -ForegroundColor Cyan
    foreach ($a in $Actions) {
        Write-Host "  $a" -ForegroundColor Cyan
    }
    Write-Host ''
    Write-Host 'Run with -Execute to apply.' -ForegroundColor Yellow
    Write-Host ''
}

function Start-Session([string]$ProjectSlug, [string]$AbsProjectDir, [string]$FeatureScope = '') {
    $startupContext = "Orchestrator startup context -- project_slug: $ProjectSlug  project_dir: $AbsProjectDir"
    if ($FeatureScope) { $startupContext += "  feature_scope: $FeatureScope" }

    # Assemble the orchestrator system prompt from the pre-built template, substituting
    # environment variables, then write to a temp file for --system-prompt-file.
    $templatePath = Join-Path $Script:Root 'prompts\assembled\orchestrator.md'
    $template     = Get-Content $templatePath -Raw -Encoding utf8

    $isGit     = if (Test-Path (Join-Path $AbsProjectDir '.git')) { 'true' } else { 'false' }
    $gitStatus = ''
    if ($isGit -eq 'true') {
        $gitStatus = (git -C $AbsProjectDir status --short 2>&1) -join "`n"
        if (-not $gitStatus) { $gitStatus = 'clean' }
    }

    $prompt = $template `
        -replace '\{\{CWD\}\}',              $AbsProjectDir `
        -replace '\{\{IS_GIT\}\}',           $isGit `
        -replace '\{\{PLATFORM\}\}',         'win32' `
        -replace '\{\{SHELL\}\}',            'PowerShell' `
        -replace '\{\{OS_VERSION\}\}',       ([System.Environment]::OSVersion.VersionString) `
        -replace '\{\{MODEL_NAME\}\}',       'Sonnet 4.6' `
        -replace '\{\{MODEL_ID\}\}',         'claude-sonnet-4-6' `
        -replace '\{\{KNOWLEDGE_CUTOFF\}\}', 'August 2025' `
        -replace '\{\{GIT_STATUS\}\}',       $gitStatus

    $prompt += "`n`n$startupContext"

    $tmpFile = [System.IO.Path]::GetTempFileName()
    try {
        Set-Content $tmpFile -Value $prompt -Encoding utf8
        & claude --system-prompt-file $tmpFile --model claude-sonnet-4-6
    }
    finally {
        Remove-Item $tmpFile -ErrorAction SilentlyContinue
    }
}

# ── list ──────────────────────────────────────────────────────────────────────

function Invoke-List {
    $reg = Read-Registry
    if ($reg.projects.Count -eq 0) {
        Write-Host 'No projects registered.' -ForegroundColor Yellow
        return
    }

    $fmt = '{0,-22} {1,-32} {2,-28} {3}'
    Write-Host ($fmt -f 'SLUG', 'REPO', 'STAGE', 'PAUSED') -ForegroundColor White
    Write-Host ('-' * 88)

    foreach ($slug in ($reg.projects.Keys | Sort-Object)) {
        $entry     = $reg.projects[$slug]
        $stateFile = Get-StateFile $entry.dir
        if (Test-Path $stateFile) {
            $s      = Get-Content $stateFile -Raw | ConvertFrom-Json
            $paused = if ($s.paused) { 'yes' } else { 'no' }
            Write-Host ($fmt -f $slug, $entry.repo, $s.stage, $paused)
        }
        else {
            Write-Host ($fmt -f $slug, $entry.repo, '(state file missing)', '') -ForegroundColor Yellow
        }
    }
}

# ── resume ────────────────────────────────────────────────────────────────────

function Invoke-Resume {
    if (-not $Project) { Write-Error '-Project is required for resume.'; exit 1 }

    $reg = Read-Registry
    if (-not $reg.projects.ContainsKey($Project)) {
        Write-Error "Project '$Project' not found. Run '.\orchestrate.ps1 new' first."
        exit 1
    }

    Assert-Tool 'claude' 'Install Claude Code from https://claude.ai/code'

    $entry      = $reg.projects[$Project]
    $absDir     = $entry.dir
    $stateFile  = Get-StateFile $absDir
    $configFile = Get-ConfigFile $absDir

    if (-not (Test-Path $stateFile)) {
        Write-Error "State file missing: $stateFile"
        exit 1
    }
    if (-not (Test-Path $configFile)) {
        Write-Error "Config file missing: $configFile"
        exit 1
    }

    $s = Get-Content $stateFile -Raw | ConvertFrom-Json
    Write-Host ''
    Write-Host "Resuming '$Project' at stage: $($s.stage)" -ForegroundColor Green
    Write-Host "  Project dir: $absDir" -ForegroundColor DarkGray
    if ($Feature) { Write-Host "  Feature scope: $Feature" -ForegroundColor Green }
    Write-Host ''

    Start-Session -ProjectSlug $Project -AbsProjectDir $absDir -FeatureScope $Feature
}

# ── new ───────────────────────────────────────────────────────────────────────

function Invoke-New {
    # Validate required flags
    if (-not $Project) { Write-Error '-Project is required.'; exit 1 }
    if ($Project -notmatch '^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$') {
        Write-Error "-Project must be a lowercase alphanumeric slug (e.g. my-app). Got: '$Project'"
        exit 1
    }
    if (-not $Repo) { Write-Error '-Repo is required (format: owner/repo).'; exit 1 }
    if ($Repo -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') {
        Write-Error "-Repo must be in owner/repo format. Got: '$Repo'"
        exit 1
    }
    if (-not $ProjectDir) { Write-Error '-ProjectDir is required — provide the path to the local clone of the target repository.'; exit 1 }

    $absProjectDir = (Resolve-Path $ProjectDir -ErrorAction SilentlyContinue)?.Path
    if (-not $absProjectDir) {
        Write-Error "-ProjectDir '$ProjectDir' does not exist. Clone the target repository first."
        exit 1
    }

    Assert-Tool 'gh'     'Install from https://cli.github.com/'
    Assert-Tool 'claude' 'Install Claude Code from https://claude.ai/code'

    # Resolve GitHub username and profile (name/email for git identity)
    $ghUser     = $GithubUser
    $ghGitName  = $GithubUser
    $ghGitEmail = ''
    if (-not $ghUser) {
        Write-Host 'Resolving GitHub user profile...'
        $ghProfile = gh api user 2>&1
        if ($LASTEXITCODE -ne 0 -or -not $ghProfile) {
            Write-Error 'Could not resolve GitHub user profile. Pass -GithubUser explicitly or run gh auth login.'
            exit 1
        }
        $ghProfileObj = $ghProfile | ConvertFrom-Json
        $ghUser     = $ghProfileObj.login
        $ghGitName  = if ($ghProfileObj.name)  { $ghProfileObj.name }  else { $ghUser }
        $ghGitEmail = if ($ghProfileObj.email) { $ghProfileObj.email } else { "$ghUser@users.noreply.github.com" }
    }
    if (-not $ghGitEmail) { $ghGitEmail = "$ghUser@users.noreply.github.com" }

    $repoParts = $Repo -split '/', 2
    $repoOwner = $repoParts[0]
    $repoName  = $repoParts[1]

    # ── Interactive prompts ────────────────────────────────────────────────────
    Write-Host ''
    Write-Host "New project: $Project  ($Repo)" -ForegroundColor Green
    Write-Host "  Project dir: $absProjectDir" -ForegroundColor DarkGray
    Write-Host 'Press Enter to accept defaults shown in [brackets].' -ForegroundColor DarkGray
    Write-Host ''

    $defaultName = (Get-Culture).TextInfo.ToTitleCase(($Project -replace '-', ' '))
    $projectName = Read-Host "Display name [$defaultName]"
    if (-not $projectName) { $projectName = $defaultName }

    $baseBranch = Read-Host 'Base branch [main]'
    if (-not $baseBranch) { $baseBranch = 'main' }

    $planningBranch = Read-Host 'Planning branch [planning]'
    if (-not $planningBranch) { $planningBranch = 'planning' }

    $defaultEscalation = "@$ghUser"
    $escalationTarget  = Read-Host "Escalation target GitHub handle [$defaultEscalation]"
    if (-not $escalationTarget) { $escalationTarget = $defaultEscalation }
    if ($escalationTarget -notmatch '^@') { $escalationTarget = "@$escalationTarget" }

    # ── Derived paths ──────────────────────────────────────────────────────────
    $orchestratorDir = Get-ProjectStateDir $absProjectDir
    $configFile      = Get-ConfigFile $absProjectDir
    $stateFile       = Get-StateFile $absProjectDir

    # Check for existing project
    $reg = Read-Registry
    if ($reg.projects.ContainsKey($Project)) {
        $overwrite = (Read-Host "Project '$Project' is already registered. Overwrite? [y/N]").Trim().ToLower()
        if ($overwrite -ne 'y') { Write-Host 'Aborted.'; exit 0 }
    }

    # ── Dry-run preview ────────────────────────────────────────────────────────
    Show-DryRun @(
        "Set:    git config user.name/user.email in $absProjectDir (if not already set)"
        "Create: $configFile"
        "Create: $stateFile"
        "Update: projects.json"
        "Note:   add .orchestrator/ to $absProjectDir\.gitignore (manual step)"
        "Launch: orchestrator session (GitHub labels + planning branch created by agent on first run)"
    )

    if (-not $Execute) { return }

    # ── Apply ──────────────────────────────────────────────────────────────────
    Write-Host 'Applying...' -ForegroundColor Green

    # 0. Git identity — set in project repo if not already configured
    if (Test-Path (Join-Path $absProjectDir '.git')) {
        $existingName  = git -C $absProjectDir config --get user.name 2>&1
        $nameIsSet     = ($LASTEXITCODE -eq 0) -and $existingName
        $existingEmail = git -C $absProjectDir config --get user.email 2>&1
        $emailIsSet    = ($LASTEXITCODE -eq 0) -and $existingEmail
        if (-not $nameIsSet) {
            git -C $absProjectDir config user.name $ghGitName | Out-Null
            Write-Host "  + git config user.name = $ghGitName" -ForegroundColor Green
        }
        if (-not $emailIsSet) {
            git -C $absProjectDir config user.email $ghGitEmail | Out-Null
            Write-Host "  + git config user.email = $ghGitEmail" -ForegroundColor Green
        }
    }

    # 1. Create .orchestrator/ directory in project repo
    if (-not (Test-Path $orchestratorDir)) {
        New-Item -ItemType Directory -Path $orchestratorDir -Force | Out-Null
    }

@"
name: "$projectName"
slug: $Project

github:
  owner: "$repoOwner"
  repo: "$repoName"
  base_branch: $baseBranch
  planning_branch: $planningBranch

ci:
  enabled: false
  required: false
  provider: none

toolchain:
  language: null
  build: null
  test: null
  lint: null

orchestrator:
  escalation_target: "$escalationTarget"
  plugins:
    - house-style
    - agent-skills
    - github-ops
    - doc-ops
    - workflow-utils
    - code-quality
"@ | Set-Content $configFile -Encoding utf8
    Write-Host "  + $configFile" -ForegroundColor Green

    # 2. State file
    $instanceId = "$ghUser-$Project"
@"
{
  "version": 1,
  "project_slug": "$Project",
  "instance_id": "$instanceId",
  "github_username": "$ghUser",
  "stage": "init",
  "escalation_target": "$escalationTarget",
  "paused": false,
  "pause_reason": null,
  "active_features": {},
  "l1_revision": null
}
"@ | Set-Content $stateFile -Encoding utf8
    Write-Host "  + $stateFile" -ForegroundColor Green

    # 3. Register project (store absolute project dir)
    $reg.projects[$Project] = @{
        slug = $Project
        dir  = $absProjectDir
        repo = $Repo
    }
    Write-Registry -Data $reg
    Write-Host "  + projects.json" -ForegroundColor Green

    Write-Host ''
    Write-Host "Project '$Project' initialized." -ForegroundColor Green
    Write-Host ''
    Write-Host 'IMPORTANT: add .orchestrator/ to your project .gitignore to prevent' -ForegroundColor Yellow
    Write-Host "           committing local runtime state:" -ForegroundColor Yellow
    Write-Host "           echo '.orchestrator/' >> $absProjectDir\.gitignore" -ForegroundColor Yellow
    Write-Host ''
    Write-Host 'Starting orchestrator session...' -ForegroundColor Green
    Write-Host ''

    # 6. Launch orchestrator
    Start-Session -ProjectSlug $Project -AbsProjectDir $absProjectDir
}

# ── Dispatch ───────────────────────────────────────────────────────────────────

switch ($Command) {
    'new'    { Invoke-New }
    'resume' { Invoke-Resume }
    'list'   { Invoke-List }
}
