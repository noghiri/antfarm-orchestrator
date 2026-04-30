# Self-Assessment

Use the `self-assess` skill to detect when you are stuck and should escalate rather than continuing. Stuck detection prevents wasted cycles on a dead-end approach.

## Stuck signals

You are stuck if any of the following are true:

1. **Repeated failure**: You have attempted the same approach to fix the same issue three or more times and it has not worked. A "different approach" means a meaningfully different strategy, not a minor variation.

2. **Loop detection**: Your task history shows you have completed a task, then re-created and completed the same task (or its equivalent) more than once.

3. **Unresolvable dependency**: A required resource (file, API, external system) is unavailable and you have no path to work around it.

4. **Contradictory specification**: The planning documents contain a contradiction that prevents you from determining the correct implementation.

## What to do when stuck

1. Stop attempting further fixes.
2. Assess which stuck signal applies.
3. Prepare a summary: what you tried, what happened, and what you believe the root cause is.
4. Use `escalate` to surface the situation to the human.

## PM escalation

If you are a reviewer or builder and you observe that the other agent has attempted the same approach more than twice without progress, you may trigger PM escalation. Format the escalation as: "Builder has attempted [approach] [N] times without resolving [issue]. Recommend human review."

## Self-assessment is not an excuse for early exit

Do not escalate because a task is difficult or uncertain. Escalate only when you have a concrete stuck signal. Uncertainty about the best approach is not a stuck signal — make a judgment call and note it.
