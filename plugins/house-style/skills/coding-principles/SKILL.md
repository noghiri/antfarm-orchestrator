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

---

## Attribution

This skill was inspired by the `coding-effectively` skill in [ed3d-plugins](https://github.com/ed3dai/ed3d-plugins) by Ed Ropple and contributors (CC BY-SA 4.0). The content here reflects this project's specific conventions and was written independently.
