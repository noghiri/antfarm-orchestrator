---
description: Task list discipline for work unit execution. Load when starting or executing any work unit. Covers task creation, in-progress marking, completion rules, and end-of-unit verification.
user-invocable: false
---
# Task List Management

Maintain an active task list at all times during work unit execution. This skill defines how to use the task list correctly.

## Creating tasks

Break your work unit into discrete, completable tasks before starting. Use TaskCreate for each task. Tasks should be small enough that you can verify completion — not "implement feature X" but "write failing test for X" then "implement X to pass test."

## Marking tasks in progress

Use TaskUpdate to set a task to `in_progress` as soon as you begin it. Never work on a task without marking it in progress first.

## Marking tasks complete

Mark a task `completed` as soon as the work is done. Do not batch completions. Do not mark a task complete if:
- Tests are failing
- Implementation is partial
- You hit an unresolved blocker
- You cannot find a required file or dependency

## Checking the task list

Use TaskList to review your task list after each completed task. Confirm no task was missed before declaring the work unit done.

## When blocked

If a task is blocked and cannot be completed, do not mark it complete. Create a new task describing what needs to be resolved. If the blocker requires human input, use the `escalate` skill.

## End of work unit

Before signaling that a work unit is complete, verify:
- All tasks are in `completed` state
- No tasks are `in_progress` or `pending`
- The task list matches the work done in the commit history
