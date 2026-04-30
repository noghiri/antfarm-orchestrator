---
description: Validate a planning document at a stage gate. Load before any stage completion or PR creation. Checks frontmatter schema, status, placeholder text, and open questions. Failures are hard blocks.
user-invocable: false
allowed-tools:
  - Read
  - Glob
---
# Validate Document

Validate a planning document before a stage completion gate or a PR is opened. Validation failures are hard blocks — do not proceed until they are resolved.

## Validation steps

### 1. Parse frontmatter

Extract the YAML frontmatter using `parse-frontmatter`. If the document has no frontmatter, fail immediately.

### 2. Schema validation

Load the schema from `docs/schemas/<doc_type>.schema.json` where `doc_type` matches the frontmatter field. Validate the frontmatter against the schema. Report every missing required field and every invalid value.

### 3. Status check

The document must be in `approved` status (or `in_progress` / `complete` for feature-design, where appropriate). A `draft` document cannot pass a completion gate. If the status is `draft`, hard block and require human approval.

### 4. Placeholder detection

Scan the entire document body for placeholder text. The following patterns are hard blocks:

- `[PLACEHOLDER]`
- `[TBD]`
- `TODO` (case-insensitive)
- `YYYY-MM-DD` in any date field still set to the template default
- Any section header followed immediately by an empty line and then another section header (empty section)

Report the line number and content of each placeholder found.

### 5. Open questions check

Scan the document for unchecked open questions:

```
- [ ] [any text]
```

Any unchecked `- [ ]` item in an **Open Questions** section is a hard block. Checked items (`- [x]`) are allowed.

### 6. Output

If all checks pass:
```
VALIDATION PASSED: <doc_type> at <path>
```

If any check fails:
```
VALIDATION FAILED: <doc_type> at <path>
  - [schema] Missing required field: feature_id
  - [placeholder] Line 42: "TODO: describe integration"
  - [open-question] Line 88: "- [ ] Should we use gRPC or REST?"
```

Treat each failure line as a separate item to resolve. Do not proceed past this gate until all failures are resolved.
