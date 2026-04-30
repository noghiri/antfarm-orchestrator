---
description: Structured discovery dialog for planner agents. Load before drafting any planning document. Runs a focused Q&A to surface what the user wants to build, then confirms understanding before proceeding.
user-invocable: false
---
# Intake

Run the intake skill before drafting any planning document (Project Charter, Feature Design, or similar). Its purpose is to establish shared understanding between you and the user before you commit anything to writing.

## When to load

Load this skill as the first action when:
- Starting a Project Charter
- Starting a Feature Design document
- Resuming planning work after a long pause where context may have drifted

## Core rules

- **Never assume.** If you do not know something, ask. Do not fill in gaps with plausible guesses.
- **One question at a time.** Do not present a list of questions. Ask one, wait for the answer, then decide what to ask next based on what you learned.
- **Follow the thread.** Each answer may resolve multiple open questions or open new ones. Adapt accordingly.
- **Stay in scope.** Only ask what you need to draft the document at hand. Do not probe for information that belongs in later stages.

## Intake procedure

### Step 1 — Open the conversation

Introduce yourself and state what you are about to do:

> "Before I draft the [document name], I'd like to make sure I understand what you're building. I'll ask a few questions — one at a time — and once I've got a clear picture I'll summarize it back to you for confirmation."

### Step 2 — Run the discovery dialog

Ask questions iteratively. Use the target document to guide what you need to know:

**For a Project Charter**, you need to establish:
- What the system does and who it is for
- The core problem it solves
- What success looks like (primary outcomes)
- Hard constraints (platform, language, regulatory, performance, etc.)
- What is explicitly out of scope
- Any non-negotiable design decisions already made

**For a Feature Design**, you need to establish:
- What this feature does and why it is needed now
- How it fits into the existing system (entry points, data flow, dependencies)
- Acceptance criteria — how will the user know it is working?
- Edge cases or failure modes that must be handled
- Anything the feature must NOT do

For each question:
1. Ask it plainly. Do not ask multiple sub-questions in the same message.
2. After the user answers, determine: do you have enough to proceed, or is there still a gap?
3. If there is a gap, ask the next most important question.
4. If the answer raises a new concern, address that before moving on.

Stop asking when you have enough to write a complete, accurate first draft — not before, not after.

### Step 3 — Summarize and confirm

Once you have gathered enough information, write a brief summary in plain language:

> "Here's my understanding before I start drafting:
>
> **What it is:** [one or two sentences]
> **Who it's for:** [user / system / audience]
> **Core problem solved:** [one sentence]
> **Success looks like:** [measurable or observable outcomes]
> **Constraints:** [key hard limits]
> **Out of scope:** [explicit exclusions]
>
> Does this capture it accurately? Any corrections before I proceed?"

Wait for explicit confirmation. Do not proceed to drafting until the user says yes (or equivalent).

### Step 4 — Handle corrections

If the user corrects anything:
- Acknowledge the correction specifically
- Update your mental model
- Ask if there is anything else to adjust before you proceed
- Once confirmed, move to drafting

## What to do after intake

Return to the calling workflow and begin drafting the document. The summary you produced in Step 3 is the authoritative source of truth for the draft — do not deviate from it without going back to the user.
