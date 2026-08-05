---
description: Write a validated planning document to its canonical path and commit it. Invoke explicitly — always validates before writing, verifies correct branch, and commits with standard message.
allowed-tools:
  - Write
  - Edit
  - Read
  - "Bash(git checkout *)"
  - "Bash(git add *)"
  - "Bash(git commit *)"
  - "Bash(git branch *)"
---
# Write Document

Write a planning document to its canonical path. Always validates the document before writing. On the planning branch, ensures the correct branch is checked out before writing.

## Canonical paths

| Document type | Branch | Path |
|---------------|--------|------|
| `project-charter` | `planning` or `planning-revision-r<N>` | `docs/project/project-charter.md` |
| `system-design` | `planning` or `planning-revision-r<N>` | `docs/project/system-design.md` |
| `feature-registry` | `planning` or `planning-revision-r<N>` | `docs/project/feature-registry.md` |
| `feature-design` | `feature/<feature-id>-<slug>` | `docs/features/<feature-id>/feature-design.md` |

The `planning-revision-r<N>` form is only valid when the state file's `l1_revision.branch` names that exact branch — i.e., during an active L1 revision session (see `l1-revision`). Outside of that, only `planning` is valid for the three L1 document types.

## Write procedure

1. Validate the document using `validate-doc`. If validation fails, abort — do not write.
2. Verify the current git branch matches the expected branch for this document type (`planning`, or the exact `l1_revision.branch` value if an L1 revision is active per the state file).
   - If on the wrong branch, abort and report which branch is required.
3. Write the document to its canonical path.
4. Stage and commit the file:
   ```sh
   git add <path>
   git commit -m "[docs] <doc_type>: <brief description> (r<revision>)"
   ```

## Commit message convention

`[docs] <doc_type>: <brief description> (r<revision>)`

Examples:
- `[docs] project-charter: initial draft (r1)`
- `[docs] feature-design: add WU-003 for API rate limiting (r2)`
- `[docs] system-design: update component list after L1 revision (r3)`

## Updating an existing document

When updating an existing document:
1. Increment the `revision` field in the frontmatter.
2. Update the `revised` date to today.
3. Validate and write as above.

## Draft vs. approved

Documents can be written in `draft` status during authoring. Status must be changed to `approved` (by human review) before the document can be used as input to the next stage. Use `validate-doc` explicitly at stage gates.
