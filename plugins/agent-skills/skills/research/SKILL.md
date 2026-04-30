---
description: External information lookup for completing tasks. Load when you need to verify an API, library, or protocol not in your training data, or to confirm a technical assumption before implementing.
user-invocable: false
allowed-tools:
  - WebSearch
  - WebFetch
---
# Research

Use the `research` skill to look up external information needed to complete a task. Research results are returned directly to your context — no separate document is produced.

## When to use research

- You need to understand an API, library, or protocol that is not in your training data or is likely updated since your knowledge cutoff
- A planning document references an external system you need to understand
- You need to verify a technical assumption before implementing

## When not to use research

- When the information is already in the planning documents
- When the information is stable, well-known, and within your training data
- When you are trying to avoid making a decision — research is for facts, not for deferring judgment

## How to use research

1. Formulate a specific question. Vague searches produce vague answers.
2. Use WebSearch or WebFetch to retrieve information.
3. Extract only the relevant facts — do not dump raw search results into your context.
4. If relevant, add a brief **Research Notes** section to the planning document you are working with.
5. Cite the source in any note you add.

## Research scope

Research is scoped to the immediate task. Do not research tangential topics. If your research reveals a significant new risk or constraint, surface it via `escalate` rather than acting on it unilaterally.

---

## Attribution

This skill was inspired by the `researching-on-the-internet` skill in [ed3d-plugins](https://github.com/ed3dai/ed3d-plugins) by Ed Ropple and contributors (CC BY-SA 4.0). The content here was written independently for this project's workflow.
