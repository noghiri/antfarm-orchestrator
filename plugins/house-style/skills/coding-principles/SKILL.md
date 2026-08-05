---
description: Coding standards for all agents. Load when writing any code: minimal footprint, no speculative error handling, comment discipline, colocated tests, TDD. Applies regardless of language or toolchain.
user-invocable: false
---
# Coding Principles

These principles apply to all code you write in this project, regardless of language or toolchain.

## Minimal footprint

Do not add features, refactor, or introduce abstractions beyond what the task requires. A bug fix does not need surrounding cleanup. A one-shot operation does not need a helper. Do not design for hypothetical future requirements.

Three similar lines is better than a premature abstraction. No half-finished implementations.

## No speculative error handling

Do not add error handling, fallbacks, or validation for scenarios that cannot happen. Trust internal code and framework guarantees. Only validate at system boundaries: user input and external APIs. Do not use feature flags or backwards-compatibility shims when you can just change the code.

## Comments only when the WHY is non-obvious

Write no comments by default. Add one only when the WHY is non-obvious: a hidden constraint, a subtle invariant, a workaround for a specific external bug, or behavior that would surprise a reader. If removing the comment would not confuse a future reader, do not write it.

Never write multi-line comment blocks or docstrings that describe WHAT the code does. Well-named identifiers already do that. Never reference the current task, fix, or callers in comments — those belong in commit messages.

## Colocated tests

Place tests in the same file or directory as the code they test, following the idioms of the language:
- Rust: `#[cfg(test)]` module at the bottom of each source file
- Other languages: `<module>.test.<ext>` next to the source file

Do not create a separate top-level `tests/` directory unless the framework requires it.

## Tests before implementation

When given a work unit spec with an output contract, write the tests first. Only proceed to implementation once the test structure is in place and failing for the right reason.

## No backwards-compatibility hacks

Do not rename unused variables with a leading underscore, re-export removed types, or add `// removed` comments for deleted code. If something is confirmed unused, delete it entirely.

## No emojis

Do not add emojis to code, comments, commit messages, or any written output unless the user explicitly requests them.

## Build before infra/ops assessment

The same minimal-footprint reasoning applies to project sequencing, not just code. Default to building core functionality first. Do not recommend an upfront infrastructure/ops assessment pass (deployment automation, monitoring, scaling work) as a prerequisite to building features, unless the System Design already flagged it as a hard blocking dependency — i.e., a feature genuinely cannot be built or tested without it. Absent that, ops/infra work is deferred until a concrete need for it exists, the same way speculative error handling or premature abstractions are deferred.

## Don't assume shipping readiness prematurely

Treat "not all work units are complete" as a hard signal that the project is not ready to ship or go live — never plan, discuss, or make decisions as though it were. This applies especially during planning stages (System Design, Feature Registry, Feature Design), where a passing mention of a future capability (e.g. "if this ever needs to accept payments") can tempt a premature detour into production-readiness or deployment discussion, or into deciding a concrete vendor/processor choice, for something that doesn't exist yet. If a future capability comes up, note it and move on — do not treat the project as deployable or monetizable until the work units that actually deliver it are built.

---

## Attribution

This skill was inspired by the `coding-effectively` skill in [ed3d-plugins](https://github.com/ed3dai/ed3d-plugins) by Ed Ropple and contributors (CC BY-SA 4.0). The content here reflects this project's specific conventions and was written independently.
