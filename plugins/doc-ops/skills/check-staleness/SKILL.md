---
description: Check whether a planning document is stale relative to its upstream dependencies. Load when a document may have been superseded by an upstream change. Staleness warnings surface for human review.
user-invocable: false
allowed-tools:
  - Read
  - "Bash(git log *)"
---
# Check Staleness

Determine whether a planning document is stale relative to its upstream dependencies. A stale document is one whose dependencies have changed since it was last revised.

## Staleness logic

1. Read the document's `revised` date from its frontmatter.
2. Identify the document's dependencies:
   - A Feature Design depends on: project-charter, system-design, feature-registry
   - A system-design depends on: project-charter
   - A feature-registry depends on: project-charter, system-design
3. For each dependency, find the calendar date of the last commit that modified it:
   ```sh
   git log -1 --format="%cd" --date=short -- <dependency-path>
   ```
   `--date=short` truncates to `YYYY-MM-DD`, matching the frontmatter `revised` field's granularity. Do not use `%ci`/`%cI` (full timestamp) here — comparing a full timestamp against a date-only `revised` value makes same-day edits register as "after" the document (any commit time is later than implied midnight), producing a false-positive staleness warning on the very common case of a document and its dependency being drafted in the same session.
4. Compare the dependency's last-commit date to the document's `revised` date as calendar dates (both are now `YYYY-MM-DD`).
5. If any dependency's last-commit date is strictly later than the document's `revised` date, the document is potentially stale. A dependency modified on the same calendar date as the document's `revised` date is not stale.

## Output

**Not stale**:
```
STALENESS CHECK PASSED: <doc_type> at <path>
  All dependencies last modified before revised date (YYYY-MM-DD)
```

**Potentially stale**:
```
STALENESS WARNING: <doc_type> at <path>
  Dependency modified after document revision:
    - <dependency-path> last modified YYYY-MM-DD (document revised YYYY-MM-DD)
```

## How to handle staleness

A staleness warning does not automatically block. Surface the warning to the relevant agent (feature-planner for L2 docs, orchestrator for L1 docs) and determine whether the upstream change affects this document. If it does, the document must be revised and re-approved before the stage proceeds.
