---
description: Surface a feature or work unit split proposal to the human for approval. Load when a feature has too many work units or a work unit is estimated too large. Never splits unilaterally.
user-invocable: false
---
# Split Proposal

Surface a proposal to split a feature or work unit to the human for approval. Splitting always requires human sign-off — never split unilaterally.

## When to propose a split

**Feature split** (proposed by feature-planner or orchestrator):
- The feature's work units exceed 8–10 items and span multiple clearly separable concerns
- The feature has been discovered to encompass distinct deliverables that should be tracked independently
- A dependency relationship has been discovered between two parts of the same feature

**Work unit split** (proposed by builder):
- The work unit is estimated large (>3 days of work)
- The implementation reveals two independently testable components
- The work unit's test surface is too large for a single review

## Proposal format

Use `escalate` to surface the proposal with the following structure:

```
## Split Proposal

**Subject**: <feature-id>/<work-unit-id or "feature"> — <name>
**Reason**: <why a split is warranted>

**Proposed split**:

Option A (keep together):
- Pros: <benefits of keeping together>
- Cons: <drawbacks>

Option B (split into parts):
- Part 1: <name and scope>
- Part 2: <name and scope>
- New dependency: Part 2 depends on Part 1
- Pros: <benefits>
- Cons: <drawbacks>

**Recommendation**: <which option and why>
```

## After approval

If the human approves a split:
- For feature splits: update the Feature Registry to add the new features, then create new Feature Design documents
- For work unit splits: update the Feature Design to replace the work unit with two new entries, create new GitHub Issues, and close the original issue with a note

All changes to planning documents require the usual validation and human review before proceeding.
