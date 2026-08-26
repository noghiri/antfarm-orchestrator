---
description: Sub-agent spawning for the orchestrator role. Invoke explicitly to delegate a stage to a specialized agent (system-planner, feature-planner, builder, reviewer). Requires context assembly before invocation.
disable-model-invocation: true
allowed-tools:
  - Agent
---
# Spin Agent

Use the `spin-agent` skill when you (as the orchestrator) need to delegate a stage to a specialized sub-agent. This skill handles preset selection, context assembly, and invocation.

## When to use

- You are the orchestrator and need to start a planning stage (system-planner, feature-planner)
- You are the orchestrator and need to dispatch a work unit (builder, reviewer)
- A previous stage has produced approved documents and the next stage is ready to begin

## Preset selection

Model tiering per role is not owned by this skill — it lives in the invoking prompt (e.g. `coordinator.md`'s `building` stage spells out `model: "sonnet"` for `builder` and `model: "opus"` for `reviewer` on the `Agent` tool call; `feature-registry.md` and `feature-design.md` do the same for their own adversarial review sub-agents). Use whatever model the invoking stage's instructions specify. Do not hardcode a model or model ID here — a second copy of that mapping is how it drifted out of sync with the real tiering before.

## Context assembly

Before spawning a sub-agent, assemble its context using `workflow-utils:context-assembly`. The assembled context must include:
- Relevant approved planning documents (project charter, system design, feature design)
- The work unit spec (for builder and reviewer)
- Loaded skills appropriate to the agent's role
- The project config (for toolchain and CI settings)

## Invocation

Spawn the sub-agent using the Claude Code `Agent` tool with `subagent_type: "general-purpose"` and the `model` value specified by the invoking stage's instructions (see Preset selection above). The `prompt` argument is the assembled context returned by `workflow-utils:context-assembly` — it already contains the role's behavioral preset instructions, all relevant documents, and the skills list, so no additional wrapping is needed.

The assembled context must be the entire `prompt` value. Do not summarize or paraphrase it; pass it in full so the sub-agent has the complete spec.

Example structure of the `prompt` value (assembled by `context-assembly`):
```
[Behavioral preset]
You are a builder agent. Act autonomously...

[Loaded skills]
<content of each required SKILL.md>

[Project config]
<contents of project.yaml>

[Documents]
<contents of each required planning document>

[Work unit]
Issue #42: ...
```

## After invocation

The `Agent` tool returns the sub-agent's complete output when it finishes. Read it for:
- An explicit escalation signal (look for the phrase "ESCALATION:" or a call to `agent-skills:escalate`)
- A completion signal ("work unit complete", "review complete", etc.)

If an escalation is present, route it to the human via `agent-skills:escalate` before spawning the next sub-agent.
