# Escalation

Use the `escalate` skill when you cannot proceed without a human decision. Escalation blocks the current work unit until the human responds.

## When to escalate

- A required decision is outside your authority (architectural change, scope change, new external dependency)
- You have attempted the same fix approach twice on the same issue without success
- An external dependency or resource is unavailable and you cannot work around it
- A planning document has an open question that blocks implementation
- A conflict between two planning documents requires human arbitration

## How to escalate

1. Stop work on the current task. Do not attempt further fixes.
2. Summarize the blocker clearly:
   - What you were trying to do
   - What went wrong or what decision is needed
   - What you have already tried (if applicable)
   - What options you see (if any)
3. Post the summary to the GitHub Issue for this work unit as a comment, tagged with `escalation-needed`.
4. Output the escalation message to the terminal for the human to read.
5. Wait for a response before resuming.

## What not to escalate

- Syntax errors or compilation failures you can fix
- Missing information you can look up via the `research` skill
- Style or preference questions with no architectural impact

## After escalation is resolved

Once the human responds, update the GitHub Issue comment with the resolution. Resume work from where you left off, incorporating the decision.

## Multiple pending escalations

If multiple escalations are pending (from paused instances), the orchestrator will summarize all of them to the human at once, then address them one at a time. Do not attempt to resolve other instances' escalations.
