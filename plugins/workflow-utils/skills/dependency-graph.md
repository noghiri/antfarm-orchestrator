# Dependency Graph

Build a feature dependency map from the Feature Registry. Used by the orchestrator to determine execution order and identify parallelizable features.

## Input

Read `docs/project/feature-registry.md` from the planning branch. Parse the `Depends On` field for each feature in the Feature Details section.

## Graph construction

Build a directed acyclic graph (DAG) where:
- Each node is a feature ID (e.g., `F001`)
- Each edge `F001 → F002` means F002 depends on F001 (F001 must complete first)

Detect cycles and report them as hard errors — cycles cannot be resolved without human intervention (use `escalate`).

## Output

Report the dependency graph in two formats:

**Execution layers** (features that can run in parallel at each layer):
```
Layer 1 (no dependencies): F001, F003
Layer 2 (depends on layer 1): F002, F004
Layer 3 (depends on layer 2): F005
```

**Full dependency list** (for reference):
```
F002 depends on: F001
F004 depends on: F001, F003
F005 depends on: F002, F004
```

## Usage by orchestrator

The orchestrator uses the dependency graph to:
1. Identify which features can begin implementation immediately
2. Block feature planning for F002 until F001's feature design is approved
3. Determine which features can run in parallel (same layer)
4. Surface the execution plan to the human for review at the start of the Building stage
