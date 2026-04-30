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

Select the agent preset based on the stage:

| Stage | Preset |
|-------|--------|
| System Design | `system-planner` |
| Feature Design | `feature-planner` |
| Implementation | `builder` |
| Peer Review | `reviewer` |
| Orchestration | `orchestrator` |

## Context assembly

Before spawning a sub-agent, assemble its context using `workflow-utils/context-assembly`. The assembled context must include:
- Relevant approved planning documents (project charter, system design, feature design)
- The work unit spec (for builder and reviewer)
- Loaded skills appropriate to the agent's role
- The project config (for toolchain and CI settings)

## Invocation

Spawn the sub-agent with:
1. The selected preset applied (via `--mode` or equivalent)
2. The assembled context included
3. The work unit GitHub Issue number in the prompt
4. The instance identity set in the session config

## After invocation

Monitor the sub-agent's output for escalation signals. If the sub-agent surfaces an escalation, route it to the human before proceeding.
