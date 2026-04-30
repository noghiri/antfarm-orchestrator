---
description: Task lifecycle management using TaskCreate, TaskGet, TaskList, and TaskUpdate. Load when starting a work unit to create and track discrete tasks through pending → in_progress → completed.
user-invocable: false
allowed-tools:
  - TaskCreate
  - TaskGet
  - TaskList
  - TaskUpdate
---
# Task Management

Use TaskCreate, TaskGet, TaskList, and TaskUpdate to manage your work unit task list. These tools are your primary mechanism for tracking progress and signaling state.

## Task lifecycle

```
pending → in_progress → completed
```

Use `deleted` only for tasks created in error that have no history of work.

## Creating tasks

At the start of a work unit, break the work into discrete tasks using TaskCreate. Each task should represent a single verifiable action: "write failing test for X", "implement X", "run linter", not "do feature X".

## Claiming tasks

Before starting any task, call `TaskUpdate` with `status: in_progress`. This prevents another instance from picking up the same work.

## Completing tasks

Call `TaskUpdate` with `status: completed` as soon as the task is done. Do not batch completions at the end of the work unit.

## Checking for new work

After completing a task, call `TaskList` to confirm state and check for newly unblocked tasks before picking up the next one.

## Blocked tasks

If a task cannot be completed due to a blocker:
- Keep it `in_progress`
- Create a new task describing what must be resolved
- Use `escalate` if the blocker requires human input

## Work unit completion check

Before declaring a work unit complete, call `TaskList` and verify every task is `completed`. Any `pending` or `in_progress` task is a signal that work is unfinished.
