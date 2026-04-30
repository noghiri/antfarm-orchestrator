---
description: Assemble the relevant documents and skills for a given agent role before spawning a sub-agent. Load when preparing to invoke system-planner, feature-planner, builder, or reviewer. Manages context size.
user-invocable: false
allowed-tools:
  - Read
  - Glob
---
# Context Assembly

Assemble the relevant documents and configuration for a given agent role and stage. The assembled context is passed to the spawned agent to give it everything it needs without flooding it with irrelevant content.

## Context by agent role

**system-planner** (System Design stage):
- `project.yaml` (project config)
- `docs/project/project-charter.md` (approved)
- Loaded skills: house-style (all), agent-skills (escalate, research, task-manage, self-assess), doc-ops (write-doc, validate-doc)

**feature-planner** (Feature Design stage for feature F00N):
- `project.yaml`
- `docs/project/project-charter.md` (approved)
- `docs/project/system-design.md` (approved)
- `docs/project/feature-registry.md` (approved) — feature F00N entry only
- Loaded skills: house-style (all), agent-skills (escalate, research, task-manage, self-assess), doc-ops (all), workflow-utils (split-proposal)

**builder** (Implementation stage for work unit WU-N):
- `project.yaml`
- `docs/project/system-design.md` (approved)
- `docs/features/F00N/feature-design.md` (approved) — full document
- GitHub Issue body for this work unit (full spec)
- Loaded skills: house-style (all), agent-skills (escalate, task-manage, self-assess), github-ops (claim-work-unit, release-work-unit, post-comment, update-issue), code-quality (all)

**reviewer** (Peer Review stage for work unit WU-N):
- Same context as builder (they need the full spec to review against)
- Additionally: the diff of changes made in the work unit branch
- Loaded skills: house-style (all), agent-skills (escalate, task-manage, self-assess), github-ops (post-comment, update-issue, label-ops)

**orchestrator** (between stages):
- `project.yaml`
- `docs/project/` — all L1 documents (approved)
- `docs/features/` — feature design documents for active features
- Local state file
- Loaded skills: agent-skills (all), github-ops (all), doc-ops (validate-doc, check-staleness), workflow-utils (all)

## Behavioral preset instructions

Sub-agents spawned via the `Agent` tool inherit the orchestrator's system prompt, not their own `claude-mode` preset. Embed these directives as the first section of every assembled context so the sub-agent knows its behavioral role.

**system-planner:**
> You are a system-planner agent collaborating with the human to author planning documents. Ask questions, present options, and seek explicit approval before finalizing any document. Apply architect-level quality standards: the design must be complete, internally consistent, and free of ambiguities. Your scope is unrestricted — you may reference any part of the project. Never finalize a document without explicit human approval.

**feature-planner:**
> You are a feature-planner agent collaborating with the human to author a feature design document and break the feature into work units. Apply architect-level quality standards. Your scope is this feature and its direct dependencies — do not redesign the overall system. Seek human approval before finalizing the document.

**builder:**
> You are a builder agent implementing a single work unit. Act autonomously — do not ask permission for implementation decisions that fall within the work unit spec. Apply pragmatic quality standards: working, tested code is the goal. Stay strictly within narrow scope: only change files required by this work unit. Do not refactor surrounding code or expand scope beyond what the spec requires.

**reviewer:**
> You are a reviewer agent adversarially reviewing a completed work unit. Your job is to find problems, not to rubber-stamp. Apply architect-level quality standards: check correctness, security, house style, and spec compliance. Stay within narrow scope: review only the changes in this work unit's branch. If you find issues requiring human judgment, surface them as escalations.

## Assembly procedure

1. Identify the agent role and current stage from the local state file.
2. Write the behavioral preset instructions for the target role (from the section above) as the first block of the assembled context.
3. Load the documents listed for that role. Skip any that do not yet exist (planning stages create them).
4. For feature-specific context, identify the feature ID and load only that feature's documents.
5. Construct the skills list by reading the installed plugin skills and loading the specified skill manifests as inline content (not just names — include the full SKILL.md text so the sub-agent can follow them).
6. Return the assembled context as a single structured prompt string, ordered: behavioral preset → skills → project config → documents → work unit spec.

## Context size management

If the assembled context exceeds a reasonable size (approximately 100,000 tokens), trim lower-priority items:
1. Remove the Feature Registry (summary is sufficient in most cases)
2. Truncate the system design to the components relevant to this feature
3. Surface the truncation to the orchestrator for review

Do not truncate the work unit spec or the feature design — these are the primary inputs.
