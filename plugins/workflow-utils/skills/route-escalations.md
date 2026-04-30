# Route Escalations

Collect all pending escalations, present a summary to the human, and address them one at a time. Determines whether any escalation requires an L1 revision (which triggers a full pause).

## Collecting escalations

Use `list-issues` to find all open issues with the `escalation-needed` label:

```sh
gh issue list --label "escalation-needed" --state open --json number,title,body,labels
```

## Triage: L1 vs. L2 escalations

For each escalation, determine its scope:

**L1 escalation** — requires changing a planning document that affects multiple features:
- Change to project charter, system design, or feature registry
- Discovery that a core architectural assumption is wrong
- A cross-feature conflict that can only be resolved by re-planning

→ Trigger `pause-at-boundary` for all instances before presenting to the human.

**L2 escalation** — scoped to a single feature or work unit:
- Ambiguity in a feature spec
- Missing information that can be resolved without changing L1 docs
- A work unit that turned out to be larger than estimated (split proposal)

→ Do not pause other instances. Address in the context of the affected feature only.

## Presenting to the human

**If there are multiple escalations**, present a summary first:

```
## Pending Escalations (N)

1. [L1] #42 — <title>: <one-line summary>
2. [L2] #48 — <title>: <one-line summary>
3. [L2] #51 — <title>: <one-line summary>

I will address these one at a time. Starting with #1 (L1 — highest priority).
```

Then present each escalation in detail and wait for a response before proceeding to the next.

**If there is one escalation**, present it directly without a summary preamble.

## Addressing an escalation

For each escalation:
1. Present the full context (from the GitHub Issue body)
2. Present the options (if the agent already identified options) or ask the human how to proceed
3. Wait for the human's response
4. Record the decision on the GitHub Issue as a comment
5. Remove the `escalation-needed` label
6. If L2: resume the affected work unit with the new information
7. If L1: open an L1 revision PR (see task #50 — L1 revision PR workflow)

## Order of priority

Address escalations in this order:
1. L1 escalations (highest impact — resolved first to unblock everything)
2. L2 escalations with work units in `status/blocked` (unblock waiting agents)
3. L2 escalations with no waiting agents
